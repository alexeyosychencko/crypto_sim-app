import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_fortune_wheel/flutter_fortune_wheel.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../wallet/providers/wallet_provider.dart';

class LuckySpinScreen extends ConsumerStatefulWidget {
  const LuckySpinScreen({super.key});

  @override
  ConsumerState<LuckySpinScreen> createState() => _LuckySpinScreenState();
}

class _LuckySpinScreenState extends ConsumerState<LuckySpinScreen> {
  final StreamController<int> controller = StreamController<int>();
  static const int spinCost = 3000;
  bool isSpinning = false;
  int selectedIndex = 0;

  final List<SpinItem> items = [
    SpinItem(amount: 100, color: Colors.grey, label: '\$100'),
    SpinItem(
      amount: 250,
      color: const Color(0xFFCD7F32),
      label: '\$250',
    ), // Bronze
    SpinItem(
      amount: 500,
      color: const Color(0xFFC0C0C0),
      label: '\$500',
    ), // Silver
    SpinItem(
      amount: 1000,
      color: const Color(0xFFFFD700),
      label: '\$1,000',
    ), // Gold
    SpinItem(amount: 2500, color: Colors.blue, label: '\$2,500'),
    SpinItem(amount: 5000, color: Colors.purple, label: '\$5,000'),
    SpinItem(amount: 10000, color: Colors.red, label: '\$10,000'),
    SpinItem(amount: 0, color: Colors.grey.shade800, label: 'Try Again'),
  ];

  @override
  void dispose() {
    controller.close();
    super.dispose();
  }

  void _spin() {
    final wallet = ref.read(walletProvider);
    if (wallet.balance < spinCost) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Not enough balance!')));
      return;
    }

    if (isSpinning) return;

    setState(() {
      isSpinning = true;
    });

    // Deduct cost
    ref.read(walletProvider.notifier).updateBalance(-spinCost.toDouble());

    // Generate random index with weights
    // Weights corresponding to items indices: 0..7
    // $100(30%), $250(25%), $500(20%), $1000(12%), $2500(7%), $5000(4%), $10000(1%), $0(1%)
    final weights = [30, 25, 20, 12, 7, 4, 1, 1];
    int randomPercent = Random().nextInt(100);
    int currentIndex = 0;
    int cumulativeWeight = 0;

    for (int i = 0; i < weights.length; i++) {
      cumulativeWeight += weights[i];
      if (randomPercent < cumulativeWeight) {
        currentIndex = i;
        break;
      }
    }

    selectedIndex = currentIndex;
    controller.add(selectedIndex);
  }

  void _onAnimationEnd() {
    setState(() {
      isSpinning = false;
    });

    final wonItem = items[selectedIndex];
    if (wonItem.amount > 0) {
      ref
          .read(walletProvider.notifier)
          .updateBalance(wonItem.amount.toDouble());
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(wonItem.amount > 0 ? 'Congratulations!' : 'So Close!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (wonItem.amount > 1000)
              const Icon(Icons.celebration, size: 50, color: Colors.yellow),
            const SizedBox(height: 16),
            Text(
              wonItem.amount > 0
                  ? 'You won \$${wonItem.amount}!'
                  : 'Better luck next time!',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _spin();
            },
            child: const Text('Spin Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lucky Spin'),
        backgroundColor: Colors.transparent,
        actions: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Text(
                '\$${wallet.balance.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            'Your Balance: \$${wallet.balance.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: FortuneWheel(
                selected: controller.stream,
                items: [
                  for (var item in items)
                    FortuneItem(
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white, // Contrast text color
                        ),
                      ),
                      style: FortuneItemStyle(
                        color: item.color,
                        borderColor: Colors.black,
                        borderWidth: 2,
                      ),
                    ),
                ],
                animateFirst: false,
                onAnimationEnd: _onAnimationEnd,
              ),
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: ElevatedButton(
              onPressed: (isSpinning || wallet.balance < spinCost)
                  ? null
                  : _spin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
                textStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              child: Text(
                isSpinning
                    ? 'Spinning...'
                    : 'Spin for \$${spinCost.toString()}',
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class SpinItem {
  final int amount;
  final Color color;
  final String label;

  SpinItem({required this.amount, required this.color, required this.label});
}
