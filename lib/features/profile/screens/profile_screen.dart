import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import '../../wallet/providers/wallet_provider.dart';
import '../../trading/providers/trade_provider.dart';
import '../../trading/providers/position_provider.dart';

// Import models for type safety
import '../../../shared/models/wallet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final trades = ref.watch(tradesProvider);
    final positions = ref.watch(positionsProvider);

    // Calculate stats
    final totalTrades = trades.length;
    final winningTrades = trades.where((t) => t.pnl > 0).length;
    final losingTrades = trades.where((t) => t.pnl < 0).length;
    final winRate = totalTrades > 0
        ? (winningTrades / totalTrades * 100).toStringAsFixed(1)
        : '0.0';

    double totalPnL = 0;
    for (var trade in trades) {
      totalPnL += trade.pnl;
    }

    double bestTrade = 0;
    double worstTrade = 0;
    if (trades.isNotEmpty) {
      bestTrade = trades.map((t) => t.pnl).reduce(max);
      worstTrade = trades.map((t) => t.pnl).reduce(min);
    }

    final totalInvestedPositions = positions.fold<double>(
      0,
      (sum, p) => sum + p.amount,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Info Card
            _buildUserInfoCard(),
            const SizedBox(height: 16),

            // Balance Card
            _buildBalanceCard(wallet),
            const SizedBox(height: 16),

            // Trading Statistics Card
            _buildTradingStatsCard(
              totalTrades,
              winningTrades,
              losingTrades,
              winRate,
              totalPnL,
              bestTrade,
              worstTrade,
            ),
            const SizedBox(height: 16),

            // Open Positions Summary
            _buildOpenPositionsCard(positions.length, totalInvestedPositions),
            const SizedBox(height: 24),

            // Reset Button
            _buildResetButton(context, ref),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const CircleAvatar(radius: 30, child: Icon(Icons.person, size: 30)),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Trader',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Your rating: 0',
                  style: TextStyle(color: Colors.grey[400]),
                ),
                Text(
                  'Member since: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
                  style: TextStyle(color: Colors.grey[400], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(Wallet wallet) {
    final totalBalance = wallet.balance + wallet.invested;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Total Balance', style: TextStyle(color: Colors.grey)),
            Text(
              '\$${totalBalance.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    const Text('Free', style: TextStyle(color: Colors.grey)),
                    Text(
                      '\$${wallet.balance.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text(
                      'Invested',
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      '\$${wallet.invested.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradingStatsCard(
    int total,
    int winning,
    int losing,
    String winRate,
    double totalPnL,
    double best,
    double worst,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trading Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatRow('Total Trades', total.toString()),
            _buildStatRow(
              'Winning Trades',
              winning.toString(),
              color: Colors.green,
            ),
            _buildStatRow(
              'Losing Trades',
              losing.toString(),
              color: Colors.red,
            ),
            _buildStatRow('Win Rate', '$winRate%'),
            _buildStatRow(
              'Total PnL',
              '\$${totalPnL.toStringAsFixed(2)}',
              color: totalPnL >= 0 ? Colors.green : Colors.red,
            ),
            const Divider(),
            _buildStatRow(
              'Best Trade',
              '\$${best.toStringAsFixed(2)}',
              color: Colors.green,
            ),
            _buildStatRow(
              'Worst Trade',
              '\$${worst.toStringAsFixed(2)}',
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildOpenPositionsCard(int count, double totalInvested) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$count Open Positions',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Invested: \$${totalInvested.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  Widget _buildResetButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.withValues(alpha: 0.1),
          foregroundColor: Colors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () => _showResetConfirmation(context, ref),
        child: const Text('Reset Account'),
      ),
    );
  }

  Future<void> _showResetConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Account?'),
        content: const Text(
          'This will reset your balance to \$3000 and clear all trade history and open positions. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Reset'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(walletProvider.notifier).reset();
      await ref.read(positionsProvider.notifier).reset();
      await ref.read(tradesProvider.notifier).clearHistory();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account reset successfully')),
        );
      }
    }
  }
}
