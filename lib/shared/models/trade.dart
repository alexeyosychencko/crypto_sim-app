import 'package:hive/hive.dart';

part 'trade.g.dart';

@HiveType(typeId: 2)
class Trade {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String symbol;

  @HiveField(2)
  final String type; // "long" or "short"

  @HiveField(3)
  final double entryPrice;

  @HiveField(4)
  final double exitPrice;

  @HiveField(5)
  final double amount;

  @HiveField(6)
  final int leverage;

  @HiveField(7)
  final double pnl;

  @HiveField(8)
  final double pnlPercent;

  @HiveField(9)
  final DateTime openedAt;

  @HiveField(10)
  final DateTime closedAt;

  Trade({
    required this.id,
    required this.symbol,
    required this.type,
    required this.entryPrice,
    required this.exitPrice,
    required this.amount,
    required this.leverage,
    required this.pnl,
    required this.pnlPercent,
    required this.openedAt,
    required this.closedAt,
  });
}
