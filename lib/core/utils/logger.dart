import 'package:logger/logger.dart';

/// Global logger instance for the application
class AppLogger {
  static final Logger _instance = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  static void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _instance.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message, {Object? error, StackTrace? stackTrace}) {
    _instance.i(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _instance.w(message, error: error, stackTrace: stackTrace);
  }

  static void error(String message, {Object? error, StackTrace? stackTrace}) {
    _instance.e(message, error: error, stackTrace: stackTrace);
  }

  static void verbose(String message, {Object? error, StackTrace? stackTrace}) {
    _instance.v(message, error: error, stackTrace: stackTrace);
  }
}
