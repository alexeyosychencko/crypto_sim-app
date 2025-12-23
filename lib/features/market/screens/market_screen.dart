import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/market_provider.dart';
import '../widgets/ticker_list_item.dart';

class MarketScreen extends ConsumerWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTickers = ref.watch(tickerStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Market')),
      body: asyncTickers.when(
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
      ),
    );
  }
}
