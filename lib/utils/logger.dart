import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

class AppLogger {
  final String _name;

  AppLogger(this._name);

  void _log(LogLevel level, String message, [dynamic error, StackTrace? stackTrace]) {
    final timestamp = DateTime.now().toIso8601String();
    final levelStr = level.toString().split('.').last.toUpperCase();
    final logMessage = '[$timestamp] [$levelStr] [$_name] $message';

    switch (level) {
      case LogLevel.debug:
        developer.log(logMessage, name: _name);
        break;
      case LogLevel.info:
        developer.log(logMessage, name: _name);
        break;
      case LogLevel.warning:
        developer.log(logMessage, name: _name, level: 900);
        break;
      case LogLevel.error:
        developer.log(
          logMessage,
          name: _name,
          error: error,
          stackTrace: stackTrace,
          level: 1000,
        );
        break;
    }
  }

  void debug(String message) => _log(LogLevel.debug, message);
  void info(String message) => _log(LogLevel.info, message);
  void warning(String message) => _log(LogLevel.warning, message);
  void error(String message, [dynamic error, StackTrace? stackTrace]) =>
      _log(LogLevel.error, message, error, stackTrace);
}
