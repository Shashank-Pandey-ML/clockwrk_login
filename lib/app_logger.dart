import 'package:logger/logger.dart';

class AppLogger {
  // Private constructor
  AppLogger._internal();

  // Static instance of Logger
  static final Logger _instance = Logger(
    printer: PrettyPrinter(),
  );

  // Public getter to access the logger instance
  static Logger get instance => _instance;
}