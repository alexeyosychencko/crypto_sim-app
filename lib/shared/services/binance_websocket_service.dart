import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/ticker_data.dart';

class BinanceWebsocketService {
  WebSocketChannel? _channel;
  final StreamController<List<TickerData>> _tickerController =
      StreamController.broadcast();
  final List<String> _symbols = ['btcusdt', 'ethusdt', 'bnbusdt'];
  final String _baseUrl = 'wss://stream.binance.com:9443/ws';
  bool _isConnected = false;
  bool _isDisposed = false;

  Stream<List<TickerData>> get stream => _tickerController.stream;

  void connect() {
    if (_isConnected || _isDisposed) return;

    try {
      final streams = _symbols.map((s) => '$s@ticker').join('/');
      final uri = Uri.parse('$_baseUrl/$streams');

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
    } catch (e) {
      print('Connection Error: $e');
      _reconnect();
    }
  }

  void _handleMessage(dynamic data) {
    if (_isDisposed || _tickerController.isClosed) return;

    try {
      final json = jsonDecode(data);
      final ticker = TickerData.fromJson(json);

      if (_isDisposed || _tickerController.isClosed) return;

      _tickerController.add([ticker]);
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
    _channel?.sink.close();
  }

  void dispose() {
    _isDisposed = true;
    disconnect();
    _tickerController.close();
  }
}
