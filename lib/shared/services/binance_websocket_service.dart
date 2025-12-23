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

  Stream<List<TickerData>> get stream => _tickerController.stream;

  void connect() {
    if (_isConnected) return;

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
    try {
      final json = jsonDecode(data);
      // Binance stream returns a single object for single streams or combined stream wrapper
      // For direct URL combination like /ws/btcusdt@ticker/ethusdt@ticker, it returns individual JSON objects per event

      final ticker = TickerData.fromJson(json);
      // In a real app we might buffer these or manage state better,
      // but matching the requirement "Expose Stream<List<TickerData>>".
      // Since the stream sends one ticker at a time, we wrap it in a list.
      // Alternatively, we could accumulate a map of latest prices and emit the full list.
      // Let's emit the single update for now, but wrapped as List since that was requested,
      // OR better, we likely want the full state.
      // Let's stick to emitting what we get but satisfying the signature or check intent.
      // Requirement: "Expose Stream<List<TickerData>>"
      // If I receive one update, should I emit a list of one?
      // Or should I maintain the state of all 3 symbols and emit the latest state of all 3?
      // Usually UI wants the latest state of all or just the update.
      // Given "Stream<List<TickerData>>", imply emitting snapshots or updates.
      // I will emit a list containing just the updated ticker for now to keep it efficient,
      // checking if the user wants full state management here.
      // Actually, standard pattern is often just Stream<TickerData>, but user asked for List.
      // Let's assume they might want to support multiple updates or I should accumulate.
      // I'll emit a list of 1 for now to be safe and simple.

      _tickerController.add([ticker]);
    } catch (e) {
      print('Parse Error: $e');
    }
  }

  void _reconnect() {
    _isConnected = false;
    _channel?.sink.close();

    // Simple backoff
    Future.delayed(const Duration(seconds: 3), () {
      print('Attempting to reconnect...');
      connect();
    });
  }

  void disconnect() {
    _isConnected = false;
    _channel?.sink.close();
  }

  void dispose() {
    disconnect();
    _tickerController.close();
  }
}
