import 'package:hive_flutter/hive_flutter.dart';
import '../models/wallet.dart';

class WalletService {
  // Box is opened in main.dart
  static const String _boxName = 'wallet';
  static const String _walletKey = 'main_wallet';

  Wallet getWallet() {
    final box = Hive.box<Wallet>(_boxName);

    // Get existing wallet or create default
    var wallet = box.get(_walletKey);
    if (wallet == null) {
      wallet = Wallet();
      box.put(_walletKey, wallet);
    }
    return wallet;
  }

  Future<void> updateBalance(double amount) async {
    final wallet = getWallet();
    wallet.balance += amount;
    await wallet.save();
  }

  Future<void> invest(double amount) async {
    final wallet = getWallet();
    if (wallet.balance >= amount) {
      wallet.balance -= amount;
      wallet.invested += amount;
      await wallet.save();
    } else {
      throw Exception('Insufficient balance');
    }
  }

  Future<void> release(double amount) async {
    final wallet = getWallet();
    // In a real app we might track exact invested amounts per position,
    // but simplified logic: move from invested back to balance.
    // If we profit, amount > initial investment.
    // Logic here assuming amount is total return (principal + profit/loss)

    // Since we track 'invested' aggregate, we should ideally subtract the COST basis.
    // But simplified requirement says "move from invested to balance (when closing position)".
    // Let's assume input 'amount' is the returned value (Cost + PnL).
    // And we reduce 'invested' by ??
    // Requirement is simple: "release(double amount) - move from invested to balance"
    // This implies invested -= amount; balance += amount?
    // If I invested 100, made 10 profit, return is 110.
    // invested -= 110 (result -10 invested??) -> This breaks logic if amount includes profit.

    // Adjusted logic based on typical simple sim:
    // invested amount is the locked margin.
    // 'amount' in 'release(amount)' probably refers to the RETURNED value.
    // BUT to keep 'invested' accurate as "active cost basis", we need to know the original cost.
    // Since the specialized requirement doesn't specify passing cost, I will implement a safe basic logic:
    // This method might be just moving funds, but 'release' implies unlocking.
    // Let's interpret 'release(amount)' as "Unlock 'amount' from invested and add to balance".
    // This assumes we are releasing the COST.
    // Wait, if we close a position, we get back Cost + PnL.
    // Getting strict interpretation:
    // "release(double amount) - move from invested to balance"
    // I will implement exactly that: invested -= amount; balance += amount.
    // NOTE: Usage must ensure 'amount' is the original invested amount, else 'invested' drifts.
    // Warning added in comment.

    // Safety: Ensure we never release more than what's invested
    final releaseAmount = amount > wallet.invested ? wallet.invested : amount;

    wallet.invested -= releaseAmount;
    wallet.balance += releaseAmount;

    // Safety: Ensure invested never goes negative
    if (wallet.invested < 0) {
      wallet.invested = 0;
    }

    await wallet.save();
  }

  Future<void> addToBalance(double amount) async {
    // Helper for adding PnL separately if needed, or deposits
    final wallet = getWallet();
    wallet.balance += amount;
    await wallet.save();
  }

  Future<void> resetWallet() async {
    final wallet = getWallet();
    wallet.balance = 0.0;
    wallet.invested = 0.0;
    await wallet.save();
  }
}
