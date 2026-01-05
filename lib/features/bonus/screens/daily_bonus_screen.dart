import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/bonus_provider.dart';
import '../widgets/day_card.dart';
import '../../../core/constants/bonus_rewards.dart';

class DailyBonusScreen extends ConsumerWidget {
  const DailyBonusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bonusData = ref.watch(bonusDataProvider);
    final bonusService = ref.watch(bonusServiceProvider);

    final canClaim = bonusService.canClaimToday();
    final currentStreak = bonusData.currentStreak;

    // Calculate next reward amount
    int nextReward = 0;
    if (canClaim) {
      // Logic duplicated from service for display purposes or use service method if available/public
      // Using service logic: if claimed yesterday, next is streak + 1. If broken, reset to 1.
      // Actually service.getNextReward() does this logic.
      nextReward = bonusService.getNextReward();
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A), // Dark background
      appBar: AppBar(
        title: const Text('Daily Bonus'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header Section
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.card_giftcard,
                  size: 80,
                  color: Colors.amber,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Daily Bonus',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              if (currentStreak > 0 && !bonusService.isStreakBroken())
                Text(
                  'Day $currentStreak in a row',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.amber,
                    fontWeight: FontWeight.w500,
                  ),
                )
              else
                const Text(
                  'Start your streak today!',
                  style: TextStyle(fontSize: 16, color: Colors.white70),
                ),

              const SizedBox(height: 8),
              const Text(
                'Come back tomorrow to keep your streak!',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),

              const SizedBox(height: 32),

              // Days Grid
              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final reward = dailyBonusRewards[day] ?? 0;
                    final status = bonusService.getDayStatus(day);

                    return DayCard(day: day, reward: reward, status: status);
                  },
                ),
              ),

              // Claim Button
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: canClaim
                      ? () async {
                          try {
                            final reward = await ref
                                .read(bonusDataProvider.notifier)
                                .claim();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Claimed \$$reward!',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                    disabledBackgroundColor: Colors.grey.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    canClaim ? 'Get \$$nextReward' : 'Come back tomorrow',
                    style: TextStyle(
                      color: canClaim ? Colors.black : Colors.white54,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
