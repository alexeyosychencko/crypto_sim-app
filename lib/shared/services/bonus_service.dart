import 'package:hive/hive.dart';
import '../../core/constants/bonus_rewards.dart';
import '../models/bonus_data.dart';

class BonusService {
  final Box<BonusData> _box;

  BonusService(this._box);

  BonusData getBonusData() {
    return _box.get('bonus_data', defaultValue: BonusData())!;
  }

  bool canClaimToday() {
    final data = getBonusData();
    if (data.lastClaimDate == null) return true;

    final now = DateTime.now();
    final last = data.lastClaimDate!;

    // Check if claimed today (ignoring time)
    return !(last.year == now.year &&
        last.month == now.month &&
        last.day == now.day);
  }

  bool _wasClaimedYesterday(DateTime lastClaim) {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    return lastClaim.year == yesterday.year &&
        lastClaim.month == yesterday.month &&
        lastClaim.day == yesterday.day;
  }

  int getNextReward() {
    final data = getBonusData();
    if (data.lastClaimDate == null) {
      return dailyBonusRewards[1]!;
    }

    if (canClaimToday()) {
      // If claimed yesterday, next is streak + 1
      if (_wasClaimedYesterday(data.lastClaimDate!)) {
        final nextStreak = data.currentStreak + 1;
        return dailyBonusRewards[nextStreak > 7 ? 7 : nextStreak] ??
            dailyBonusRewards[7]!;
      } else {
        // Streak broken
        return dailyBonusRewards[1]!;
      }
    } else {
      // Already claimed today, show next day's potential reward
      final nextStreak = data.currentStreak + 1;
      return dailyBonusRewards[nextStreak > 7 ? 7 : nextStreak] ??
          dailyBonusRewards[7]!;
    }
  }

  Future<int> claimBonus() async {
    if (!canClaimToday()) {
      throw Exception('Bonus already claimed today');
    }

    final data = getBonusData();
    int newStreak = 1;

    if (data.lastClaimDate != null &&
        _wasClaimedYesterday(data.lastClaimDate!)) {
      newStreak = data.currentStreak + 1;
      if (newStreak > 7) {
        newStreak =
            7; // Cap at 7 days for reward purposes, or keep incrementing?
      }
      // Context says "7 days streak with increasing rewards", usually implies max reward at 7.
      // We will loop cycle or cap logic.
      // Requirement says "7 days streak...". Let's assume day 7 is max and it stays there or loops?
      // Usually "missed a day - streak resets".
      // Let's cap reward at 7, but maybe we can keep streak number high?
      // For simplicity and typical behavior: if day 7 claimed, next day is 7 again or 1?
      // "7 days streak with increasing rewards".
      // Let's cap streak at 7 for now to match keys.
      if (newStreak > 7) newStreak = 7;
    }

    // Actually, "7 days streak" might mean it resets after 7 days too?
    // "If missed a day - streak resets". didn't say it resets after 7.
    // I will assume it caps at 7 for reward value.

    final reward = dailyBonusRewards[newStreak]!;

    final newData = BonusData(
      lastClaimDate: DateTime.now(),
      currentStreak: newStreak,
    );

    await _box.put('bonus_data', newData);
    return reward;
  }

  String getDayStatus(int day) {
    final data = getBonusData();
    if (day > 7) return 'locked';

    // This is tricky. Status depends on current streak.
    // If current streak is 3 (claimed 3 days).
    // Day 1, 2, 3: Claimed.
    // Day 4: Available (if today not claimed) or Locked (if need to wait).

    // Simplification for UI:
    // If streak is N.
    // Days <= N are 'claimed' (unless claiming today upgrades N to N+1).
    // Actually, if I have streak 2 (claimed yesterday).
    // Today I can claim. Streak will become 3.
    // So currently Day 1, 2 are done. Day 3 is 'current/available'. Day 4+ locked.

    // If I claimed today. Streak is 3.
    // Day 1, 2, 3 done. Day 4 locked (available tomorrow).

    // So logic:
    // If claimed today:
    //   days <= currentStreak -> claimed
    //   days > currentStreak -> locked

    // If NOT claimed today:
    //   Streak is essentially for yesterday.
    //   days <= currentStreak -> claimed
    //   day == currentStreak + 1 -> available
    //   days > currentStreak + 1 -> locked

    // But wait, if streak broken?
    // If broken, streak resets to 0 effectively for 'next claim'.
    // If last claim was 2 days ago. Streak is stored as 5. But practically it is broken.
    // So if I claim now, it becomes 1.

    bool broken = isStreakBroken();

    if (broken) {
      if (day == 1) {
        return canClaimToday()
            ? 'available'
            : 'claimed'; // If broken, we start at 1.
      }
      return 'locked';
    }

    final streak = data.currentStreak;
    final claimedToday = !canClaimToday();

    if (claimedToday) {
      if (day <= streak) return 'claimed';
      return 'locked';
    } else {
      if (day <= streak) return 'claimed';
      if (day == streak + 1) return 'available';
      return 'locked';
    }
  }

  bool isStreakBroken() {
    final data = getBonusData();
    if (data.lastClaimDate == null) {
      return false; // First time logic handled elsewhere or treated as not broken (start at 1)
    }

    return !canClaimToday()
        ? false
        : !_wasClaimedYesterday(data.lastClaimDate!);
  }
}
