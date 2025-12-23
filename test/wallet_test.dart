import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:crypto_sim/shared/models/wallet.dart';
import 'package:crypto_sim/shared/services/wallet_service.dart';
import 'package:crypto_sim/features/wallet/providers/wallet_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  test('Wallet Logic Verification', () async {
    // Initialize Hive for tests
    Hive.init('test_hive_box');
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(WalletAdapter());
    }

    // We need to properly mock or initialize the service box since it uses a static box name
    // For unit testing Hive boxes, usually we open them.
    // WalletService uses openBox with 'wallet'.
    await Hive.openBox<Wallet>('wallet');

    final service = WalletService();
    // await service.init(); // Removed

    // Reset to known state
    await service.resetWallet();

    var wallet = service.getWallet();
    expect(wallet.balance, 3000.0);
    expect(wallet.invested, 0.0);

    // Test Provider
    final container = ProviderContainer(
      overrides: [walletServiceProvider.overrideWithValue(service)],
    );

    // Read initial state
    var state = container.read(walletProvider);
    expect(state.balance, 3000.0);

    // Invest
    print('Investing 500...');
    await container.read(walletProvider.notifier).invest(500.0);

    state = container.read(walletProvider);
    expect(state.balance, 2500.0);
    expect(state.invested, 500.0);

    // Release
    print('Releasing 600 (500 + 100 profit)...');
    await container.read(walletProvider.notifier).release(600.0);

    state = container.read(walletProvider);
    // invested: 500 - 600 = -100 (Based on our simple logic)
    // balance: 2500 + 600 = 3100
    // As per implementation discussions, simple logic was requested.
    expect(state.balance, 3100.0);
    expect(state.invested, -100.0); // Confirming the simple subtraction logic

    await Hive.deleteFromDisk();
  });
}
