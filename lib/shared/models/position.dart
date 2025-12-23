import 'package:hive/hive.dart';

part 'position.g.dart';

@HiveType(typeId: 1)
class Position extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String symbol;

  @HiveField(2)
  final String type; // 'long' or 'short'

  @HiveField(3)
  final double entryPrice;

  @HiveField(4)
  final double amount;

  @HiveField(5)
  final int leverage;

  @HiveField(6)
  final DateTime openedAt;

  Position({
    required this.id,
    required this.symbol,
    required this.type,
    required this.entryPrice,
    required this.amount,
    required this.leverage,
    required this.openedAt,
  });
}
