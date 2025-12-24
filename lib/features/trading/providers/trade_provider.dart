import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/services/trade_service.dart';
import '../../../shared/models/trade.dart';

final tradeServiceProvider = Provider<TradeService>((ref) {
  return TradeService();
});

class TradesNotifier extends Notifier<List<Trade>> {
  late final TradeService _service;

  @override
  List<Trade> build() {
    _service = ref.watch(tradeServiceProvider);
    return _service.getTrades();
  }

  Future<void> addTrade(Trade trade) async {
    await _service.saveTrade(trade);
    state = _service.getTrades();
  }

  Future<void> clearHistory() async {
    await _service.clearHistory();
    state = _service.getTrades();
  }
}

final tradesProvider = NotifierProvider<TradesNotifier, List<Trade>>(
  TradesNotifier.new,
);
