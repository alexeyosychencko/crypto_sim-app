import 'package:hive/hive.dart';

part 'bonus_data.g.dart';

@HiveType(typeId: 3)
class BonusData {
  @HiveField(0)
  final DateTime? lastClaimDate;

  @HiveField(1)
  final int currentStreak;

  BonusData({this.lastClaimDate, this.currentStreak = 0});

  BonusData copyWith({DateTime? lastClaimDate, int? currentStreak}) {
    return BonusData(
      lastClaimDate: lastClaimDate ?? this.lastClaimDate,
      currentStreak: currentStreak ?? this.currentStreak,
    );
  }
}
