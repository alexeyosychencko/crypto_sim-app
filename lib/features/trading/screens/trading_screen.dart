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

  // Static list of supported symbols - always show these in UI
  static const List<String> _supportedSymbols = [
    'ADAUSDT',
    'AVAXUSDT',
    'BNBUSDT',
    'BTCUSDT',
    'DOGEUSDT',
    'DOTUSDT',
    'ETHUSDT',
    'POLUSDT', // Changed from MATICUSDT - Polygon rebranded to POL
    'SOLUSDT',
    'XRPUSDT',
  ];

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
      length: 3,
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
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Market Tab - Always show all supported symbols
                Builder(
                  builder: (context) {
                    final asyncTickers = ref.watch(tickerStreamProvider);
                    final Map<String, dynamic> tickerMap = {};

                    // Build map of available ticker data
                    asyncTickers.whenData((tickers) {
                      for (var ticker in tickers) {
                        tickerMap[ticker.symbol] = ticker;
                      }
                    });

                    // Always show all symbols, even if data not loaded yet
                    return ListView.builder(
                      itemCount: _supportedSymbols.length,
                      itemBuilder: (context, index) {
                        final symbol = _supportedSymbols[index];
                        final ticker = tickerMap[symbol];

                        if (ticker != null) {
                          // Ticker data available - show it
                          return TickerListItem(ticker: ticker);
                        } else {
                          // Data not yet loaded - show placeholder
                          return _buildLoadingTickerItem(symbol);
                        }
                      },
                    );
                  },
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build a placeholder ticker item while data is loading
  Widget _buildLoadingTickerItem(String symbol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade800, width: 0.5),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  symbol,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Loading...',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
