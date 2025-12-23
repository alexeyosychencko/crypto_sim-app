import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/binance_websocket_service.dart';
import '../../../shared/models/ticker_data.dart';

// Provider that returns the BinanceWebsocketService instance.
// Using autoDispose so it closes the connection when not in use (if we want that).
// For a core market data feed, we might want it to stay alive, but let's stick to autoDispose for safety/cleanliness unless reqs change.
final binanceServiceProvider = Provider.autoDispose<BinanceWebsocketService>((
  ref,
) {
  final service = BinanceWebsocketService();
  ref.onDispose(() => service.dispose());
  return service;
});

// StreamProvider that exposes the list of ticker data.
final tickerStreamProvider = StreamProvider.autoDispose<List<TickerData>>((
  ref,
) {
  final service = ref.watch(binanceServiceProvider);
  service.connect();
  return service.stream;
});
