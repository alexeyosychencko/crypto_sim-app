import 'package:flutter/material.dart';
import '../../../shared/models/position.dart';

class PositionCard extends StatelessWidget {
  final Position position;
  final double currentPrice;

  const PositionCard({
    super.key,
    required this.position,
    required this.currentPrice,
  });

  @override
  Widget build(BuildContext context) {
    final isLong = position.type.toLowerCase() == 'long';
    final entryPrice = position.entryPrice;
    final leverage = position.leverage;
    final amount = position.amount;

    // Calculate PnL
    double pnl = 0;
    double pnlPercentage = 0;

    if (currentPrice > 0) {
      if (isLong) {
        pnl = (currentPrice - entryPrice) / entryPrice * amount * leverage;
        pnlPercentage =
            (currentPrice - entryPrice) / entryPrice * 100 * leverage;
      } else {
        pnl = (entryPrice - currentPrice) / entryPrice * amount * leverage;
        pnlPercentage =
            (entryPrice - currentPrice) / entryPrice * 100 * leverage;
      }
    }

    final isPositive = pnl >= 0;
    final pnlColor = isPositive ? Colors.green : Colors.red;
    final pnlPrefix = isPositive ? '+' : '';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Header: Symbol + Type Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  position.symbol,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isLong
                        ? Colors.green.withValues(alpha: 0.2)
                        : Colors.red.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isLong ? Colors.green : Colors.red,
                    ),
                  ),
                  child: Text(
                    position.type.toUpperCase(),
                    style: TextStyle(
                      color: isLong ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Middle Row: Entry Price | Current Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn(
                  context,
                  'Entry Price',
                  '\$${entryPrice.toStringAsFixed(2)}',
                ),
                _buildInfoColumn(
                  context,
                  'Current Price',
                  '\$${currentPrice.toStringAsFixed(2)}',
                  alignRight: true,
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Bottom Row: Amount | PnL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoColumn(
                  context,
                  'Amount',
                  '${amount.toStringAsFixed(0)} USDT x$leverage',
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'PnL',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$pnlPrefix\$${pnl.toStringAsFixed(2)} ($pnlPrefix${pnlPercentage.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        color: pnlColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(
    BuildContext context,
    String label,
    String value, {
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment: alignRight
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
