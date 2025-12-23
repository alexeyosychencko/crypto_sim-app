import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../market/providers/market_provider.dart';
import '../../market/widgets/ticker_list_item.dart';

class TradingScreen extends ConsumerWidget {
  const TradingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTickers = ref.watch(tickerStreamProvider);

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          const TabBar(
            isScrollable: true,
            indicatorColor: Color(0xFFFFD700),
            labelColor: Color(0xFFFFD700),
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Market'),
              Tab(text: 'Portfolio'),
              Tab(text: 'Trades'),
              Tab(text: 'Orders'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Market Tab
                asyncTickers.when(
                  data: (tickers) {
                    if (tickers.isEmpty) {
                      return const Center(child: Text('Waiting for data...'));
                    }
                    // Sort alphabetically by symbol (using simple sort for MVP)
                    // Note: In real app better to sort by volume/market cap usually
                    // or use the cryptoNames map for sorting by Name
                    final sortedTickers = [...tickers];
                    sortedTickers.sort((a, b) => a.symbol.compareTo(b.symbol));

                    return ListView.builder(
                      itemCount: sortedTickers.length,
                      itemBuilder: (context, index) {
                        final ticker = sortedTickers[index];
                        return TickerListItem(ticker: ticker);
                      },
                    );
                  },
                  error: (error, stack) => Center(child: Text('Error: $error')),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                ),

                // Placeholders
                const Center(child: Text('No open positions')),
                const Center(child: Text('No trade history')),
                const Center(child: Text('No active orders')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
