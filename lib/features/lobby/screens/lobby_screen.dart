import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../wallet/providers/wallet_provider.dart';
import '../widgets/feature_button.dart';
import '../../bonus/screens/daily_bonus_screen.dart';
import '../../bonus/screens/lucky_spin_screen.dart';
import '../../trading/screens/trading_detail_screen.dart';
import '../../../shared/models/ticker_data.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
      onFinish: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => TradingDetailScreen(
              ticker: TickerData(
                symbol: 'BTCUSDT',
                lastPrice: 98000.0,
                priceChangePercent: 2.5,
                volume: 1000.0,
              ),
              isTutorial: true,
            ),
          ),
        );
      },
      builder: (context) => const _LobbyScreenContent(),
    );
  }
}

class _LobbyScreenContent extends ConsumerStatefulWidget {
  const _LobbyScreenContent();

  @override
  ConsumerState<_LobbyScreenContent> createState() =>
      _LobbyScreenContentState();
}

class _LobbyScreenContentState extends ConsumerState<_LobbyScreenContent> {
  final GlobalKey _balanceKey = GlobalKey();
  final GlobalKey _bonusKey = GlobalKey();
  final GlobalKey _spinKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _checkAndStartShowcase(),
    );
  }

  Future<void> _checkAndStartShowcase() async {
    final prefs = await SharedPreferences.getInstance();
    final tutorialShown = prefs.getBool('lobby_tutorial_shown') ?? false;

    if (!tutorialShown && mounted) {
      ShowCaseWidget.of(
        context,
      ).startShowCase([_balanceKey, _bonusKey, _spinKey]);
      await prefs.setBool('lobby_tutorial_shown', true);
    }
  }

  String _formatCurrency(double value) {
    final intValue = value.toInt();
    final stringValue = intValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '\$$stringValue';
  }

  @override
  Widget build(BuildContext context) {
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
          // _buildBonusBanner(),
          const SizedBox(height: 16),

          // 3. Balance Section
          Showcase(
            key: _balanceKey,
            title: 'Your Balance',
            description: 'Here you can see your virtual and invested funds.',
            textColor: Colors.white,
            tooltipBackgroundColor: Colors.blueGrey.shade900,
            tooltipPadding: const EdgeInsets.all(12),
            descTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
            titleTextStyle: const TextStyle(
              color: Colors.amber,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            targetPadding: const EdgeInsets.all(4),
            child: _buildBalanceSection(
              wallet.balance,
              wallet.invested,
              totalBalance,
            ),
          ),
          const SizedBox(height: 16),

          // 4. Feature Buttons
          _buildFeatureButtons(context),
        ],
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
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
            children: [
              Text(
                'Trader',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 4),
              const Text(
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
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            _formatCurrency(total),
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
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
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
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
              Container(width: 1, height: 40, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.24)),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(invested),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
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

  Widget _buildFeatureButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: FeatureButton(
            label: '500 for\nvideo',
            icon: Icons.play_circle_fill,
            gradientColors: const [Colors.red, Colors.orange],
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Coming soon - Watch ad to earn \$500'),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Showcase(
            key: _bonusKey,
            title: 'Daily Rewards',
            description: 'Check in every day to get free money!',
            textColor: Colors.white,
            tooltipBackgroundColor: Colors.blueGrey.shade900,
            tooltipPadding: const EdgeInsets.all(12),
            descTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
            titleTextStyle: const TextStyle(
              color: Colors.amber,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            targetPadding: const EdgeInsets.all(4),
            child: FeatureButton(
              label: 'Daily\nbonus',
              icon: Icons.card_giftcard,
              gradientColors: const [Colors.amber, Colors.orangeAccent],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DailyBonusScreen(),
                  ),
                );
              },
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Showcase(
            key: _spinKey,
            title: 'Feeling Lucky?',
            description: 'Spin the wheel to win big prizes.',
            textColor: Colors.white,
            tooltipBackgroundColor: Colors.blueGrey.shade900,
            tooltipPadding: const EdgeInsets.all(12),
            descTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
            titleTextStyle: const TextStyle(
              color: Colors.amber,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            targetPadding: const EdgeInsets.all(4),
            child: FeatureButton(
              label: 'Lucky\nSpin',
              icon: Icons.casino,
              gradientColors: const [Colors.deepPurple, Colors.blue],
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LuckySpinScreen(),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
