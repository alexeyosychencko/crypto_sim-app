import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../wallet/providers/wallet_provider.dart';

class LobbyScreen extends ConsumerWidget {
  const LobbyScreen({super.key});

  String _formatCurrency(double value) {
    // Basic currency formatting with commas
    // e.g. 3000.0 -> $3,000
    // Using RegExp for simplicity without external intl package dependency if not present
    // But for a clean solution ensuring $ and commas:
    final intValue = value.toInt();
    final stringValue = intValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '\$$stringValue';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final totalBalance = wallet.balance + wallet.invested;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. User Info Card
          _buildUserInfoCard(),
          const SizedBox(height: 16),

          // 2. Bonus Banner
          _buildBonusBanner(),
          const SizedBox(height: 16),

          // 3. Balance Section
          _buildBalanceSection(wallet.balance, wallet.invested, totalBalance),
          const SizedBox(height: 16),

          // 4. Extra Features Placeholder
          _buildExtraFeaturesPlaceholder(),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E), // Dark card background
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 24,
            backgroundColor: Colors.blueGrey,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Trader',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Your rating: 0',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBonusBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700), // Gold/Yellow
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: const [
          Text(
            '\$5,500 For registration',
            style: TextStyle(
              color: Colors.black, // Dark text on yellow
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Icon(Icons.arrow_forward, color: Colors.black),
        ],
      ),
    );
  }

  Widget _buildBalanceSection(
    double freeBalance,
    double invested,
    double total,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            _formatCurrency(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your Virtual Balance',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _formatCurrency(freeBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Free',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(invested),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Invested',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExtraFeaturesPlaceholder() {
    return Container(
      height: 100,
      width: double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: const Text(
        'Additional features coming soon',
        style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
      ),
    );
  }
}
