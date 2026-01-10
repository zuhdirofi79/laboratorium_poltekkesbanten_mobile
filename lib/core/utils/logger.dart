import 'package:flutter/foundation.dart';

/// Simple Logger Utility
/// 
/// Production-ready logger that can be extended later
/// Uses debugPrint for production-safe logging
class Logger {
  static const bool _debugMode = true; // Can be controlled via build config
  
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (_debugMode) {
      debugPrint('[DEBUG] $message');
      if (error != null) {
        debugPrint('[ERROR] $error');
      }
      if (stackTrace != null) {
        debugPrint('[STACK] $stackTrace');
      }
    }
  }
  
  static void info(String message) {
    if (_debugMode) {
      debugPrint('[INFO] $message');
    }
  }
  
  static void warning(String message) {
    debugPrint('[WARNING] $message');
  }
  
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    debugPrint('[ERROR] $message');
    if (error != null) {
      debugPrint('[ERROR_DETAIL] $error');
    }
    if (stackTrace != null) {
      debugPrint('[STACK] $stackTrace');
    }
  }
}
