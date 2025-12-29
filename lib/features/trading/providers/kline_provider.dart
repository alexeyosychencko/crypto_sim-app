import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/kline_data.dart';
import '../../../shared/services/kline_service.dart';

final klineServiceProvider = Provider<KlineService>((ref) {
  return KlineService();
});

final klineProvider = FutureProvider.family
    .autoDispose<List<KlineData>, String>((ref, symbol) async {
      final service = ref.watch(klineServiceProvider);

      // Auto-refresh every 30 seconds
      final timer = Timer(const Duration(seconds: 30), () {
        // This will trigger a re-fetch
        ref.invalidateSelf();
      });

      // Ensure timer is cancelled when provider is disposed
      ref.onDispose(() => timer.cancel());

      return service.getKlines(symbol, interval: '1m', limit: 100);
    });
