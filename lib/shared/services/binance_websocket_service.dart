import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/ticker_data.dart';

class BinanceWebsocketService {
  WebSocketChannel? _channel;
  final StreamController<List<TickerData>> _tickerController =
      StreamController.broadcast();
  final List<String> _symbols = [
    'btcusdt',
    'ethusdt',
    'bnbusdt',
    'solusdt',
    'xrpusdt',
    'adausdt',
    'dogeusdt',
    'avaxusdt',
    'dotusdt',
    'polusdt',
  ];
  final String _baseUrl = 'wss://stream.binance.com:9443/stream';
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
          print('WebSocket Error: $error');
          _reconnect();
        },
        onDone: () {
          print('WebSocket Disconnected');
          _reconnect();
        },
      );

      // Initial load: wait 2 seconds to collect all ticker data, then emit
      _initialLoadTimer = Timer(const Duration(seconds: 2), () {
        if (_tickers.isNotEmpty && !_tickerController.isClosed) {
          print('Initial load: emitting ${_tickers.length} tickers');
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
      print('Connection Error: $e');
      _reconnect();
    }
  }

  void _handleMessage(dynamic data) {
    if (_isDisposed || _tickerController.isClosed) return;

    try {
      final json = jsonDecode(data);
      // Handle combined stream response format: {"stream": "...", "data": {...}}
      final tickerData = json.containsKey('data') ? json['data'] : json;
      final ticker = TickerData.fromJson(tickerData);

      print('Received ticker: ${ticker.symbol}');
      print('Total tickers: ${_tickers.length}');

      if (_isDisposed || _tickerController.isClosed) return;

      // Update local cache immediately (keep data fresh)
      _tickers[ticker.symbol] = ticker;
      // UI updates handled by initial timer (2s) then periodic timer (5s)
    } catch (e) {
      print('Parse/Stream Error: $e');
    }
  }

  void _reconnect() {
    if (_isDisposed) return;

    _isConnected = false;
    _channel?.sink.close();

    // Simple backoff
    Future.delayed(const Duration(seconds: 3), () {
      if (_isDisposed) return;
      print('Attempting to reconnect...');
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
