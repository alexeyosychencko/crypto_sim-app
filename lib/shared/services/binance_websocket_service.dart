import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/logger.dart';
import '../models/ticker_data.dart';

class BinanceWebsocketService {
  WebSocketChannel? _channel;
  final StreamController<List<TickerData>> _tickerController =
      StreamController.broadcast();
  final List<String> _symbols = AppConstants.cryptoSymbols;
  final String _baseUrl = AppConstants.binanceWebSocketUrl;
  bool _isConnected = false;
  // Map to accumulate tickers
  final Map<String, TickerData> _tickers = {};
  bool _isDisposed = false;
  // Timer for throttled emissions
  Timer? _emitTimer;
  Timer? _initialLoadTimer;

  Stream<List<TickerData>> get stream => _tickerController.stream;

  void connect() {
    if (_isConnected || _isDisposed) return;

    try {
      final streams = _symbols.map((s) => '$s@ticker').join('/');
      final uri = Uri.parse('$_baseUrl?streams=$streams');

      _channel = WebSocketChannel.connect(uri);
      _isConnected = true;

      _channel!.stream.listen(
        (data) {
          _handleMessage(data);
        },
        onError: (error) {
          AppLogger.error('WebSocket Error', error: error);
          _reconnect();
        },
        onDone: () {
          AppLogger.info('WebSocket Disconnected');
          _reconnect();
        },
      );

      // Initial load: wait 2 seconds to collect all ticker data, then emit
      _initialLoadTimer = Timer(const Duration(seconds: 2), () {
        if (_tickers.isNotEmpty && !_tickerController.isClosed) {
          AppLogger.info('Initial load: emitting ${_tickers.length} tickers');
          _tickerController.add(_tickers.values.toList());
        }

        // After initial load, setup periodic emit timer (every 5 seconds)
        _emitTimer = Timer.periodic(const Duration(seconds: 5), (_) {
          if (_tickers.isNotEmpty && !_tickerController.isClosed) {
            _tickerController.add(_tickers.values.toList());
          }
        });
      });
    } catch (e) {
      AppLogger.error('Connection Error', error: e);
      _reconnect();
    }
  }

  Future<void> _handleMessage(dynamic data) async {
    if (_isDisposed || _tickerController.isClosed) return;

    try {
      // Offload parsing to an isolate
      final ticker = await Isolate.run(() {
        final json = jsonDecode(data);
        // Handle combined stream response format: {"stream": "...", "data": {...}}
        final tickerData = json.containsKey('data') ? json['data'] : json;
        return TickerData.fromJson(tickerData);
      });

      if (_isDisposed || _tickerController.isClosed) return;

      // Update local cache immediately (keep data fresh)
      _tickers[ticker.symbol] = ticker;
      // UI updates handled by initial timer (2s) then periodic timer (5s)
    } catch (e) {
      AppLogger.error('Parse/Stream Error', error: e);
    }
  }

  void _reconnect() {
    if (_isDisposed) return;

    _isConnected = false;
    _channel?.sink.close();

    // Simple backoff
    Future.delayed(const Duration(seconds: 3), () {
      if (_isDisposed) return;
      AppLogger.info('Attempting to reconnect...');
      connect();
    });
  }

  void disconnect() {
    _isConnected = false;
    _initialLoadTimer?.cancel();
    _emitTimer?.cancel();
    _channel?.sink.close();
  }

  void dispose() {
    _isDisposed = true;
    _initialLoadTimer?.cancel();
    _emitTimer?.cancel();
    disconnect();
    _tickerController.close();
  }
}
