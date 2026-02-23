# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
flutter pub get

# Run app
flutter run

# Run tests
flutter test
flutter test test/wallet_test.dart   # single test file

# Static analysis
flutter analyze

# Code generation (required after modifying Hive models)
flutter pub run build_runner build

# Build
flutter build apk
flutter build ios
flutter build web
```

## Architecture

**Crypto trading simulator** — uses real Binance market data (WebSocket + REST) but all trades/balances are local-only (no backend). Users start with $3,000 virtual cash.

### State Management: Riverpod 3.x

Uses the `Notifier<T>` pattern (not legacy `StateNotifier`). Providers are defined in `providers/` subdirectories within each feature.

- `ref.watch()` for reactive subscriptions in widgets
- `ref.read()` for one-time reads (e.g., in callbacks)
- `ConsumerWidget` / `ConsumerState` for widget integration
- `StreamProvider` for WebSocket ticker data
- `.family` modifier for parameterized providers (e.g., kline by symbol)

### Persistence: Hive

Local NoSQL boxes: `wallet`, `positions`, `trades`, `bonus`. All boxes are opened in `main()` before `runApp`. Models in `lib/shared/models/` use `@HiveType`/`@HiveField` annotations with generated `.g.dart` adapters — run `build_runner` after modifying them.

### Data Flow

1. **Market prices**: `BinanceWebsocketService` → `tickerStreamProvider` → UI. WebSocket auto-reconnects with 3s backoff. Emits throttled (2s initial, 5s periodic).
2. **Trades/Positions**: User action → `TradeNotifier`/`PositionsNotifier` → Hive box → provider state.
3. **Wallet**: `WalletNotifier.invest()` / `release()` / `updateBalance()` → Hive → UI.
4. **Bonuses**: `BonusNotifier.claim()` → updates streak state + credits wallet.

### Feature Structure

```
lib/
├── core/constants/     # App-wide constants (Binance URLs, crypto symbols, bonus rewards)
├── features/           # Self-contained feature modules
│   ├── onboarding/     # First-launch welcome screen
│   ├── lobby/          # Home screen (balance, daily bonus, lucky spin)
│   ├── trading/        # Positions, trade history, detail charts
│   ├── market/         # Real-time ticker list
│   ├── bonus/          # Daily bonus streak + lucky spin wheel
│   ├── wallet/         # Balance management
│   ├── academy/        # Placeholder educational section
│   └── profile/        # Stats and reset
├── shared/
│   ├── models/         # Hive data classes (Wallet, Position, Trade, BonusData, etc.)
│   ├── providers/      # Cross-feature providers (navigation)
│   ├── services/       # Business logic (WalletService, TradeService, BinanceWebsocketService, etc.)
│   └── widgets/        # AppShell (bottom nav layout)
└── main.dart           # Hive init + app bootstrap
```

### Binance Integration

- **WebSocket**: `wss://stream.binance.com:9443/stream` — combined ticker stream for 10 symbols (BTC, ETH, BNB, SOL, XRP, ADA, DOGE, AVAX, DOT, POL)
- **REST**: `https://api.binance.com/api/v3/klines` — candlestick (OHLCV) data for detail charts

### Key Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod ^3.0.3` | State management |
| `hive` + `hive_flutter` | Local persistence |
| `web_socket_channel ^3.0.3` | Binance WebSocket |
| `dio ^5.9.0` | REST API (klines) |
| `fl_chart ^1.1.1` | Trading charts |
| `flutter_fortune_wheel ^1.3.2` | Lucky spin wheel |
| `showcaseview ^5.0.1` | Tutorial overlays |
