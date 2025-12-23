import 'package:flutter/material.dart';
import 'package:crypto_sim/shared/models/ticker_data.dart';

class TradingDetailScreen extends StatelessWidget {
  final TickerData ticker;

  const TradingDetailScreen({super.key, required this.ticker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(ticker.symbol)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Price: \$${ticker.lastPrice}'),
            const SizedBox(height: 20),
            const Text('Chart coming soon'),
          ],
        ),
      ),
    );
  }
}
