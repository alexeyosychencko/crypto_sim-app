import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:crypto_sim/features/market/providers/market_provider.dart';
import 'package:crypto_sim/shared/models/ticker_data.dart';

void main() {
  test('market provider stream verification', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final completer = Completer<List<TickerData>>();

    print('Listening to tickerStreamProvider...');
    final subscription = container.listen<AsyncValue<List<TickerData>>>(
      tickerStreamProvider,
      (previous, next) {
        next.whenData((data) {
          if (data.isNotEmpty && !completer.isCompleted) {
            print('Received data: ${data.length} tickers');
            completer.complete(data);
          }
        });
      },
      onError: (err, stack) {
        if (!completer.isCompleted) completer.completeError(err, stack);
      },
    );

    // Initial read to trigger creation if needed (though listen does it)
    // container.read(tickerStreamProvider);

    final tickers = await completer.future.timeout(const Duration(seconds: 15));

    expect(tickers, isNotEmpty);
    for (var ticker in tickers) {
      print('Provider Update: ${ticker.symbol} \$${ticker.lastPrice}');
    }

    subscription.close();
  });
}
