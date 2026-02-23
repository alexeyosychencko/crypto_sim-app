import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'shared/widgets/app_shell.dart';
import 'shared/models/wallet.dart';
import 'shared/models/position.dart';
import 'shared/models/trade.dart';
import 'shared/models/bonus_data.dart';
import 'shared/providers/theme_provider.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'features/onboarding/screens/welcome_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(PositionAdapter());
  Hive.registerAdapter(TradeAdapter());
  Hive.registerAdapter(BonusDataAdapter());

  // Open the box once before the app starts
  await Hive.openBox<Wallet>('wallet');
  await Hive.openBox<Position>('positions');
  await Hive.openBox<Trade>('trades');
  await Hive.openBox<BonusData>('bonus');

  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  runApp(ProviderScope(child: MyApp(isFirstLaunch: isFirstLaunch)));
}

class MyApp extends ConsumerWidget {
  final bool isFirstLaunch;
  const MyApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    const colorSchemeLight = ColorScheme.light(
      primary: Color(0xFFFFD700),
      secondary: Colors.blueAccent,
    );
    const colorSchemeDark = ColorScheme.dark(
      primary: Color(0xFFFFD700),
      secondary: Colors.blueAccent,
    );

    return MaterialApp(
      title: 'Crypto Sim',
      themeMode: themeMode,
      theme: ThemeData.light(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
        ),
        colorScheme: colorSchemeLight,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
        ),
        colorScheme: colorSchemeDark,
      ),
      home: isFirstLaunch ? const WelcomeScreen() : const AppShell(),
    );
  }
}
