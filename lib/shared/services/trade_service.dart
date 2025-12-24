import 'package:hive/hive.dart';
import '../models/trade.dart';

class TradeService {
  static const String _boxName = 'trades';

  Box<Trade> get _box => Hive.box<Trade>(_boxName);

  Future<void> saveTrade(Trade trade) async {
    await _box.add(trade);
  }

  List<Trade> getTrades() {
    final trades = _box.values.toList();
    trades.sort((a, b) => b.closedAt.compareTo(a.closedAt));
    return trades;
  }

  Future<void> clearHistory() async {
    await _box.clear();
  }
}
