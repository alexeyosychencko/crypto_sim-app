import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../shared/models/trade.dart';

class TradeHistoryCard extends StatelessWidget {
  final Trade trade;

  const TradeHistoryCard({super.key, required this.trade});

  @override
  Widget build(BuildContext context) {
    final isLong = trade.type.toLowerCase() == 'long';
    final isPositive = trade.pnl >= 0;
    final pnlColor = isPositive ? Colors.green : Colors.red;
    final pnlPrefix = isPositive ? '+' : '';
    final dateFormat = DateFormat('MMM d, HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trade.symbol,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      dateFormat.format(trade.closedAt),
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$pnlPrefix\$${trade.pnl.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: pnlColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '$pnlPrefix${trade.pnlPercent.toStringAsFixed(2)}%',
                      style: TextStyle(color: pnlColor, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoBadge(
                  isLong ? 'LONG' : 'SHORT',
                  isLong ? Colors.green : Colors.red,
                ),
                Text(
                  '${trade.leverage}x',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
