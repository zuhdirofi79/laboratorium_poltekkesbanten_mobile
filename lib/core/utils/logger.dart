/// Simple Logger Utility
/// 
/// Production-ready logger that can be extended later
/// Currently uses print, but can be swapped with logging package
class Logger {
  static const bool _debugMode = true; // Can be controlled via build config
  
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (_debugMode) {
      print('[DEBUG] $message');
      if (error != null) {
        print('[ERROR] $error');
      }
      if (stackTrace != null) {
        print('[STACK] $stackTrace');
      }
    }
  }
  
  static void info(String message) {
    if (_debugMode) {
      print('[INFO] $message');
    }
  }
  
  static void warning(String message) {
    print('[WARNING] $message');
  }
  
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    print('[ERROR] $message');
    if (error != null) {
      print('[ERROR_DETAIL] $error');
    }
    if (stackTrace != null) {
      print('[STACK] $stackTrace');
    }
  }
}
