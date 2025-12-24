import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../market/providers/market_provider.dart';
import '../../market/widgets/ticker_list_item.dart';
import '../providers/position_provider.dart';
import '../providers/trade_provider.dart';
import '../widgets/position_card.dart';
import '../widgets/trade_history_card.dart';

class TradingScreen extends ConsumerWidget {
  const TradingScreen({super.key});

  double _getPriceForSymbol(List<dynamic> tickers, String symbol) {
    // tickers is likely List<TickerData>, but using dynamic to be safe if generic type is lost
    // in the call site, though we know it's List<TickerData> from provider.
    // Finding ticker by symbol
    try {
      final ticker = tickers.firstWhere((t) => t.symbol == symbol);
      return ticker.lastPrice;
    } catch (_) {
      return 0.0;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTickers = ref.watch(tickerStreamProvider);
    final positions = ref.watch(positionsProvider);
    final trades = ref.watch(tradesProvider);

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

                // Portfolio Tab
                positions.isEmpty
                    ? const Center(child: Text('No open positions'))
                    : asyncTickers.when(
                        data: (tickers) {
                          return ListView.builder(
                            itemCount: positions.length,
                            itemBuilder: (context, index) {
                              final position = positions[index];
                              final currentPrice = _getPriceForSymbol(
                                tickers,
                                position.symbol,
                              );
                              return PositionCard(
                                position: position,
                                currentPrice: currentPrice,
                              );
                            },
                          );
                        },
                        // Show positions even if market data is loading/error, with 0 price
                        error: (error, stack) => ListView.builder(
                          itemCount: positions.length,
                          itemBuilder: (context, index) {
                            return PositionCard(
                              position: positions[index],
                              currentPrice: 0.0,
                            );
                          },
                        ),
                        loading: () => ListView.builder(
                          itemCount: positions.length,
                          itemBuilder: (context, index) {
                            return PositionCard(
                              position: positions[index],
                              currentPrice: 0.0,
                            );
                          },
                        ),
                      ),

                // Placeholders
                // Trades History Tab
                trades.isEmpty
                    ? const Center(child: Text('No trade history'))
                    : ListView.builder(
                        itemCount: trades.length,
                        itemBuilder: (context, index) {
                          return TradeHistoryCard(trade: trades[index]);
                        },
                      ),
                const Center(child: Text('No active orders')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
