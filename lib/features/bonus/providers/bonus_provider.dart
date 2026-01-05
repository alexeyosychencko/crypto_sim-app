import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../../../shared/models/bonus_data.dart';
import '../../../shared/services/bonus_service.dart';
import '../../wallet/providers/wallet_provider.dart';

// Service provider
final bonusServiceProvider = Provider<BonusService>((ref) {
  // Box should be opened in main.dart with name 'bonus'
  final box = Hive.box<BonusData>('bonus');
  return BonusService(box);
});

class BonusNotifier extends Notifier<BonusData> {
  late final BonusService _service;

  @override
  BonusData build() {
    _service = ref.watch(bonusServiceProvider);
    return _service.getBonusData();
  }

  Future<void> refresh() async {
    state = _service.getBonusData();
  }

  Future<int> claim() async {
    try {
      final reward = await _service.claimBonus();

      // Update local state
      state = _service.getBonusData();

      // Update wallet balance
      // Accessing the notifier directly to call the method
      await ref.read(walletProvider.notifier).updateBalance(reward.toDouble());

      return reward;
    } catch (e) {
      rethrow;
    }
  }
}

final bonusDataProvider = NotifierProvider<BonusNotifier, BonusData>(
  BonusNotifier.new,
);
