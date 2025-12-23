import 'package:crypto_sim/features/market/screens/market_screen.dart';
import 'package:crypto_sim/features/market/providers/market_provider.dart';
import 'package:crypto_sim/shared/models/ticker_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MarketScreen displays tickers', (WidgetTester tester) async {
    // Create a stream to control the data
    final tickers = [
      TickerData(
        symbol: 'BTCUSDT',
        lastPrice: 50000.0,
        priceChangePercent: 5.0,
        volume: 1000.0,
      ),
      TickerData(
        symbol: 'ETHUSDT',
        lastPrice: 3000.0,
        priceChangePercent: -2.0,
        volume: 5000.0,
      ),
    ];

    // Override the provider to return our fixed data
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tickerStreamProvider.overrideWith((ref) => Stream.value(tickers)),
        ],
        child: const MaterialApp(home: MarketScreen()),
      ),
    );

    // Initial pump
    await tester.pump();

    // Wait for async data to resolve? Stream.value emits immediately but we might need a frame.
    await tester.pump();

    // Verify loading indicator is gone and list is shown
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('BTCUSDT'), findsOneWidget);
    expect(find.text('\$50000.00'), findsOneWidget);
    expect(find.text('+5.00%'), findsOneWidget); // Green

    expect(find.text('ETHUSDT'), findsOneWidget);
    expect(find.text('\$3000.00'), findsOneWidget);
    expect(find.text('-2.00%'), findsOneWidget); // Red
  });
}
