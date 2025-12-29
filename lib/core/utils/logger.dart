import 'dart:developer' as developer;

class AppLogger {
  static void log(
    String message, {
    String? name,
    Object? error,
    StackTrace? stackTrace,
  }) {
    developer.log(
      message,
      name: name ?? 'CryptoSim',
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void info(String message) {
    log('INFO: $message');
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    log('ERROR: $message', error: error, stackTrace: stackTrace);
  }
}
