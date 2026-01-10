import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import '../../market/providers/market_provider.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../providers/position_provider.dart';
import '../../../shared/models/ticker_data.dart';
import '../../../shared/models/position.dart';
import '../../../shared/models/trade.dart';
import '../providers/trade_provider.dart';
import '../providers/price_history_provider.dart';
import '../widgets/trade_history_card.dart';

import '../../../core/constants/crypto_names.dart';
import '../providers/kline_provider.dart';
import '../widgets/candlestick_chart.dart';

class TradingDetailScreen extends ConsumerStatefulWidget {
  final TickerData ticker;
  final bool isTutorial;

  const TradingDetailScreen({
    super.key,
    required this.ticker,
    this.isTutorial = false,
  });

  @override
  ConsumerState<TradingDetailScreen> createState() =>
      _TradingDetailScreenState();
}

class _TradingDetailScreenState extends ConsumerState<TradingDetailScreen> {
  final TextEditingController _amountController = TextEditingController();
  int _selectedLeverage = 10;
  final List<int> _leverageOptions = [5, 10, 20, 50, 100];

  final GlobalKey _chartKey = GlobalKey();
  final GlobalKey _longButtonKey = GlobalKey();
  final GlobalKey _shortButtonKey = GlobalKey();
  bool _showcaseStarted = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _placeOrder(bool isLong) {
    if (_amountController.text.isEmpty) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final wallet = ref.read(walletProvider);
    if (wallet.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient balance'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final typeString = isLong ? 'Long' : 'Short';
    final symbol = widget.ticker.symbol;
    final price = widget.ticker.lastPrice;

    // Create new position
    final position = Position(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      symbol: symbol,
      type: isLong ? 'long' : 'short',
      entryPrice: price,
      amount: amount,
      leverage: _selectedLeverage,
      openedAt: DateTime.now(),
    );

    // Open position
    ref.read(positionsProvider.notifier).open(position);

    // Deduct balance
    ref.read(walletProvider.notifier).invest(amount);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Opened $typeString $symbol @ \$${price.toStringAsFixed(2)} | $amount USDT x$_selectedLeverage',
        ),
        backgroundColor: isLong ? Colors.green : Colors.red,
      ),
    );
    _amountController.clear();
  }

  void _closePosition(Position position, double currentPrice) {
    if (position.symbol != widget.ticker.symbol) {
      return; // Should not happen if filtered
    }

    // Calculate PnL
    final isLong = position.type == 'long';
    final double pnlPercent = isLong
        ? (currentPrice - position.entryPrice) / position.entryPrice
        : (position.entryPrice - currentPrice) / position.entryPrice;

    final double pnl = pnlPercent * position.amount * position.leverage;

    // Create Trade object
    final trade = Trade(
      id: position.id,
      symbol: position.symbol,
      type: position.type,
      entryPrice: position.entryPrice,
      exitPrice: currentPrice,
      amount: position.amount,
      leverage: position.leverage,
      pnl: pnl,
      pnlPercent: pnlPercent * 100,
      openedAt: position.openedAt,
      closedAt: DateTime.now(),
    );

    // Save to history
    ref.read(tradesProvider.notifier).addTrade(trade);

    // Close position
    ref.read(positionsProvider.notifier).close(position.id);

    // Correct wallet logic:
    // 1. Release ONLY the original investment from invested back to balance
    ref.read(walletProvider.notifier).release(position.amount);

    // 2. Add PnL to balance separately (can be positive or negative)
    ref.read(walletProvider.notifier).updateBalance(pnl);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Position Closed. PnL: \$${pnl.toStringAsFixed(2)}'),
        backgroundColor: pnl >= 0 ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cryptoName =
        cryptoNames[widget.ticker.symbol] ?? widget.ticker.symbol;

    // Watch the specific ticker for real-time updates
    final asyncTickers = ref.watch(tickerStreamProvider);
    final currentTicker =
        asyncTickers.value?.firstWhere(
          (t) => t.symbol == widget.ticker.symbol,
          orElse: () => widget.ticker,
        ) ??
        widget.ticker;

    // Watch wallet for balance
    final wallet = ref.watch(walletProvider);

    // Initialize price history provider (watching it ensures it's created)
    ref.watch(priceHistoryProvider);

    // Watch positions
    final positions = ref.watch(positionsProvider);
    // Filter positions for this symbol
    final myPositions = positions
        .where((p) => p.symbol == widget.ticker.symbol)
        .toList();

    // Watch trades
    final allTrades = ref.watch(tradesProvider);
    // Filter trades for this symbol
    final myTrades = allTrades
        .where((t) => t.symbol == widget.ticker.symbol)
        .toList();

    return ShowCaseWidget(
      builder: (context) {
        if (widget.isTutorial && !_showcaseStarted) {
          _showcaseStarted = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ShowCaseWidget.of(
              context,
            ).startShowCase([_chartKey, _longButtonKey, _shortButtonKey]);
          });
        }

        return DefaultTabController(
          length: 3,
          child: Scaffold(
            appBar: AppBar(
              title: Text(cryptoName),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: const Icon(Icons.currency_bitcoin), // Placeholder icon
                ),
              ],
              bottom: const TabBar(
                tabs: [
                  Tab(text: 'Trading'),
                  Tab(text: 'Trades'),
                  Tab(text: 'Orders'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                _buildTradingTab(currentTicker, wallet.balance),
                _buildTradesTab(myTrades),
                _buildOrdersTab(myPositions, currentTicker),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOrdersTab(List<Position> positions, TickerData currentTicker) {
    if (positions.isEmpty) {
      return const Center(child: Text('No active positions'));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: positions.length,
      itemBuilder: (context, index) {
        final pos = positions[index];
        final isLong = pos.type == 'long';

        // PnL Calc
        final double pnlPercent = isLong
            ? (currentTicker.lastPrice - pos.entryPrice) / pos.entryPrice
            : (pos.entryPrice - currentTicker.lastPrice) / pos.entryPrice;
        final double pnl = pnlPercent * pos.amount * pos.leverage;
        final pnlColor = pnl >= 0 ? Colors.green : Colors.red;

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${pos.symbol} ${pos.leverage}x',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      isLong ? 'LONG' : 'SHORT',
                      style: TextStyle(
                        color: isLong ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Entry: \$${pos.entryPrice.toStringAsFixed(2)}'),
                        Text('Invested: \$${pos.amount.toStringAsFixed(2)}'),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'PnL: \$${pnl.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: pnlColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${(pnlPercent * 100 * pos.leverage).toStringAsFixed(2)}%',
                          style: TextStyle(color: pnlColor),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () =>
                        _closePosition(pos, currentTicker.lastPrice),
                    child: const Text('Close Position'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTradingTab(TickerData ticker, double balance) {
    final priceChangeColor = ticker.priceChangePercent >= 0
        ? Colors.green
        : Colors.red;

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Price Section
                Center(
                  child: Column(
                    children: [
                      Text(
                        '\$${ticker.lastPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${ticker.priceChangePercent >= 0 ? '+' : ''}${ticker.priceChangePercent.toStringAsFixed(2)}%',
                        style: TextStyle(
                          color: priceChangeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Price Chart
                // Price Chart
                Showcase(
                  key: _chartKey,
                  title: 'Price Chart',
                  description: 'Analyze real-time market movements here.',
                  textColor: Colors.white,
                  tooltipBackgroundColor: Colors.blueGrey.shade900,
                  tooltipPadding: const EdgeInsets.all(12),
                  descTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                  titleTextStyle: const TextStyle(
                    color: Colors.amber,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  child: Consumer(
                    builder: (context, ref, child) {
                      final klineAsync = ref.watch(
                        klineProvider(ticker.symbol),
                      );
                      return klineAsync.when(
                        data: (klines) => CandlestickChart(candles: klines),
                        loading: () => const SizedBox(
                          height: 300,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (error, stack) => const SizedBox(
                          height: 300,
                          child: Center(child: Text('Failed to load chart')),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Order Form
                Text(
                  'Place Order',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Available: ${balance.toStringAsFixed(2)} USDT',
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 16),

                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Amount (USDT)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                const Text('Leverage'),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _leverageOptions.map((lev) {
                      final isSelected = _selectedLeverage == lev;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text('${lev}x'),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _selectedLeverage = lev;
                              });
                            }
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            border: Border(
              top: BorderSide(color: Theme.of(context).dividerColor),
            ),
          ),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: Showcase(
                    key: _longButtonKey,
                    title: 'Go Long',
                    description: 'Profit if the price goes UP.',
                    textColor: Colors.white,
                    tooltipBackgroundColor: Colors.blueGrey.shade900,
                    tooltipPadding: const EdgeInsets.all(12),
                    descTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    titleTextStyle: const TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _placeOrder(true),
                      child: const Text('Long'),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Showcase(
                    key: _shortButtonKey,
                    title: 'Go Short',
                    description: 'Profit if the price goes DOWN.',
                    textColor: Colors.white,
                    tooltipBackgroundColor: Colors.blueGrey.shade900,
                    tooltipPadding: const EdgeInsets.all(12),
                    descTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    titleTextStyle: const TextStyle(
                      color: Colors.amber,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () => _placeOrder(false),
                      child: const Text('Short'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTradesTab(List<Trade> trades) {
    if (trades.isEmpty) {
      return Center(child: Text('No trades for ${widget.ticker.symbol}'));
    }

    return ListView.builder(
      itemCount: trades.length,
      itemBuilder: (context, index) {
        final trade = trades[index];
        return TradeHistoryCard(trade: trade);
      },
    );
  }
}
