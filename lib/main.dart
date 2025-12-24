import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'shared/widgets/app_shell.dart';
import 'shared/models/wallet.dart';
import 'shared/models/position.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(WalletAdapter());
  Hive.registerAdapter(PositionAdapter());

  // Open the box once before the app starts
  await Hive.openBox<Wallet>('wallet');
  await Hive.openBox<Position>('positions');

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crypto Sim',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1F1F1F),
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFFFD700),
          secondary: Colors.blueAccent,
        ),
      ),
      home: const AppShell(),
    );
  }
}
