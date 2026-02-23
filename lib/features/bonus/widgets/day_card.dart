import 'package:flutter/material.dart';

class DayCard extends StatelessWidget {
  final int day;
  final int reward;
  final String status; // 'claimed', 'available', 'locked'

  const DayCard({
    super.key,
    required this.day,
    required this.reward,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    // Styling based on status
    final isClaimed = status == 'claimed';
    final isAvailable = status == 'available';

    Color borderColor = Colors.grey.withValues(alpha: 0.3);
    Color backgroundColor = Theme.of(context).cardColor.withValues(alpha: 0.45);
    double opacity = 1.0;

    if (isClaimed) {
      borderColor = Colors.green;
      backgroundColor = Colors.green.withValues(alpha: 0.1);
      opacity = 0.7;
    } else if (isAvailable) {
      borderColor = Colors.amber;
      backgroundColor = Colors.amber.withValues(alpha: 0.1);
    }

    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: isAvailable ? 2 : 1),
          boxShadow: isAvailable
              ? [
                  BoxShadow(
                    color: Colors.amber.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Day $day',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            _buildIcon(),
            const SizedBox(height: 4),
            Text(
              '\$$reward',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (status == 'claimed') {
      return const Icon(Icons.check_circle, color: Colors.green, size: 24);
    } else if (status == 'locked') {
      return const Icon(Icons.lock, color: Colors.grey, size: 24);
    } else {
      return const Icon(Icons.card_giftcard, color: Colors.amber, size: 24);
    }
  }
}
