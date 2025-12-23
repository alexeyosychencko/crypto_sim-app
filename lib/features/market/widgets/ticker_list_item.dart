import 'package:flutter/material.dart';
import '../../../shared/models/ticker_data.dart';

class TickerListItem extends StatelessWidget {
  final TickerData ticker;

  const TickerListItem({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    // Format price to 2 decimal places
    final price = ticker.lastPrice.toStringAsFixed(2);

    // Determine color based on price change
    final isPositive = ticker.priceChangePercent >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;
    final changePrefix = isPositive ? '+' : '';
    final changePercent =
        '${changePrefix}${ticker.priceChangePercent.toStringAsFixed(2)}%';

    return ListTile(
      title: Text(
        ticker.symbol.toUpperCase(),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$$price',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Text(
            changePercent,
            style: TextStyle(
              color: changeColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
