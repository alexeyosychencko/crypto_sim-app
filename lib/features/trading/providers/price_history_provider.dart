import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/price_point.dart';
import '../../../shared/models/ticker_data.dart';
import '../../market/providers/market_provider.dart';

// State class for price history
class PriceHistoryState {
  final Map<String, List<PricePoint>> history;
  static const int maxPoints = 50; // Keep last 50 price points

  PriceHistoryState({Map<String, List<PricePoint>>? history})
    : history = history ?? {};

  PriceHistoryState copyWith({Map<String, List<PricePoint>>? history}) {
    return PriceHistoryState(history: history ?? this.history);
  }

  List<PricePoint> getHistory(String symbol) {
    return history[symbol] ?? [];
  }
}

// Notifier to manage price history for all symbols
class PriceHistoryNotifier extends Notifier<PriceHistoryState> {
  @override
  PriceHistoryState build() {
    // Listen to ticker updates
    ref.listen<AsyncValue<List<TickerData>>>(tickerStreamProvider, (
      previous,
      next,
    ) {
      next.whenData((tickers) {
        for (final ticker in tickers) {
          _addPricePoint(ticker.symbol, ticker.lastPrice);
        }
      });
    });

    return PriceHistoryState();
  }

  void _addPricePoint(String symbol, double price) {
    final currentHistory = state.history[symbol] ?? [];
    final newPoint = PricePoint(timestamp: DateTime.now(), price: price);

    // Add new point and keep only the last maxPoints
    final updatedHistory = [...currentHistory, newPoint];
    if (updatedHistory.length > PriceHistoryState.maxPoints) {
      updatedHistory.removeAt(0); // Remove oldest point
    }

    state = state.copyWith(history: {...state.history, symbol: updatedHistory});
  }
}

// Provider for price history
final priceHistoryProvider =
    NotifierProvider<PriceHistoryNotifier, PriceHistoryState>(
      () => PriceHistoryNotifier(),
    );
