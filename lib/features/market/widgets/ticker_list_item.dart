import 'package:flutter/material.dart';
import '../../../shared/models/ticker_data.dart';
import '../../../core/constants/crypto_names.dart';
import '../../trading/screens/trading_detail_screen.dart';

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
        '$changePrefix${ticker.priceChangePercent.toStringAsFixed(2)}%';

    // Get friendly name
    final name = cryptoNames[ticker.symbol] ?? ticker.symbol;

    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TradingDetailScreen(ticker: ticker),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            // Icon Placeholder
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.blueGrey.withOpacity(0.2),
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Name and Symbol
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    ticker.symbol,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Price and Change
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '\$$price',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
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
          ],
        ),
      ),
    );
  }
}
