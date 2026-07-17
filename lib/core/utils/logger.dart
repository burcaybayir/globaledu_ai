import 'package:logger/logger.dart' as log_pkg;


class AppLogger {
  AppLogger._();

  static final log_pkg.Logger _logger = log_pkg.Logger(
    printer: log_pkg.PrettyPrinter(
      methodCount: 1,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
    ),
    level: log_pkg.Level.debug,
  );

  static void debug(String message, [dynamic data]) {
    _logger.d('$message${data != null ? '\n$data' : ''}');
  }

  static void info(String message, [dynamic data]) {
    _logger.i('$message${data != null ? '\n$data' : ''}');
  }

  static void warning(String message, [dynamic data]) {
    _logger.w('$message${data != null ? '\n$data' : ''}');
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void fatal(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.f(message, error: error, stackTrace: stackTrace);
  }
}
