# Crypto Trading Simulator

## Project Overview

Flutter mobile app for crypto futures paper trading (like Binance Testnet).

## Tech Stack

- Flutter 3.24+
- State Management: Riverpod
- HTTP: Dio
- WebSocket: web_socket_channel
- Backend: Supabase (planned)

## Architecture

- Feature-first structure (lib/features/)
- Clean Architecture principles
- Models in lib/shared/models/

## Code Style

- Use Riverpod for all state
- Prefer StatelessWidget + ConsumerWidget
- All API calls through services in lib/shared/services/
- Ukrainian comments allowed, code in English
