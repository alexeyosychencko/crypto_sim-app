import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/wallet.dart';
import '../../../shared/services/wallet_service.dart';

// Service provider
final walletServiceProvider = Provider<WalletService>((ref) {
  return WalletService();
});

// Notifier to exposing Wallet state using Riverpod 3.x Notifier
class WalletNotifier extends Notifier<Wallet> {
  late final WalletService _service;

  @override
  Wallet build() {
    _service = ref.watch(walletServiceProvider);
    return _service.getWallet();
  }

  Future<void> invest(double amount) async {
    await _service.invest(amount);
    state = _service.getWallet(); // Force refresh state
  }

  Future<void> release(double amount) async {
    await _service.release(amount);
    state = _service.getWallet();
  }

  Future<void> updateBalance(double amount) async {
    await _service.updateBalance(amount);
    state = _service.getWallet();
  }

  Future<void> reset() async {
    await _service.resetWallet();
    state = _service.getWallet();
  }
}

final walletProvider = NotifierProvider<WalletNotifier, Wallet>(
  WalletNotifier.new,
);
