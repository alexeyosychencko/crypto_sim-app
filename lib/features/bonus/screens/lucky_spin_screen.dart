import 'package:flutter/material.dart';

class LuckySpinScreen extends StatelessWidget {
  const LuckySpinScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lucky Spin'),
        backgroundColor: Colors.transparent,
      ),
      body: const Center(
        child: Text(
          'Lucky Spin Screen',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
