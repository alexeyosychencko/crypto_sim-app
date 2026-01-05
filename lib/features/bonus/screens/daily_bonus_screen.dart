import 'package:flutter/material.dart';

class DailyBonusScreen extends StatelessWidget {
  const DailyBonusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Bonus'),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Text(
          'Daily Bonus Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
