import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../market/providers/market_provider.dart';
import '../../market/widgets/ticker_list_item.dart';

class TradingScreen extends ConsumerWidget {
  const TradingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTickers = ref.watch(tickerStreamProvider);

    return asyncTickers.when(
      data: (tickers) {
        if (tickers.isEmpty) {
          return const Center(child: Text('Waiting for data...'));
        }
        return ListView.builder(
          itemCount: tickers.length,
          itemBuilder: (context, index) {
            final ticker = tickers[index];
            return TickerListItem(ticker: ticker);
          },
        );
      },
      error: (error, stack) => Center(child: Text('Error: $error')),
      loading: () => const Center(child: CircularProgressIndicator()),
    );
  }
}
