import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../market/providers/market_provider.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../providers/position_provider.dart';
import '../../../shared/models/ticker_data.dart';
import '../../../shared/models/position.dart';
import '../../../core/constants/crypto_names.dart';

class TradingDetailScreen extends ConsumerStatefulWidget {
  final TickerData ticker;

  const TradingDetailScreen({super.key, required this.ticker});

  @override
  ConsumerState<TradingDetailScreen> createState() =>
      _TradingDetailScreenState();
}

class _TradingDetailScreenState extends ConsumerState<TradingDetailScreen> {
  final TextEditingController _amountController = TextEditingController();
  int _selectedLeverage = 10;
  final List<int> _leverageOptions = [5, 10, 20, 50, 100];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _placeOrder(bool isLong) {
    if (_amountController.text.isEmpty) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) return;

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

    final type = isLong ? 'Long' : 'Short';
    final symbol = widget.ticker.symbol;

    // Create new position
    final position = Position(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      symbol: symbol,
      type: isLong ? 'long' : 'short',
      entryPrice:
          widget.ticker.lastPrice, // Ideally use current real-time price
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
          'Order placed: $type $symbol $amount USDT x$_selectedLeverage',
        ),
        backgroundColor: isLong ? Colors.green : Colors.red,
      ),
    );
    _amountController.clear();
  }

  void _closePosition(Position position, double currentPrice) {
    if (position.symbol != widget.ticker.symbol)
      return; // Should not happen if filtered

    // Calculate PnL
    final isLong = position.type == 'long';
    final double pnlPercent = isLong
        ? (currentPrice - position.entryPrice) / position.entryPrice
        : (position.entryPrice - currentPrice) / position.entryPrice;

    final double pnl = pnlPercent * position.amount * position.leverage;
    final double returnAmount = position.amount + pnl;

    // Close position
    ref.read(positionsProvider.notifier).close(position.id);

    // Release funds (Original investment + PnL) specifically
    // Wallet logic "release" adds amount to balance.
    // If we lost everything (returnAmount < 0), we might need to handle it.
    // Assuming simple logic:

    if (returnAmount > 0) {
      ref.read(walletProvider.notifier).release(returnAmount);
    } else {
      // Total loss, nothing returned? or negative balance?
      // Simplest: just don't release anything if < 0.
    }

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

    // Watch positions
    final positions = ref.watch(positionsProvider);
    // Filter positions for this symbol
    final myPositions = positions
        .where((p) => p.symbol == widget.ticker.symbol)
        .toList();

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
            const Center(child: Text('Trades History')),
            _buildOrdersTab(myPositions, currentTicker),
          ],
        ),
      ),
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

    return SingleChildScrollView(
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
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
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

          // Chart Placeholder
          Container(
            height: 250,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.withOpacity(0.2)),
            ),
            child: const Center(
              child: Text(
                'Chart coming soon',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Order Form
          Text('Place Order', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Available: ${balance.toStringAsFixed(2)} USDT',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

          Row(
            children: [
              Expanded(
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
              const SizedBox(width: 16),
              Expanded(
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
            ],
          ),
        ],
      ),
    );
  }
}
