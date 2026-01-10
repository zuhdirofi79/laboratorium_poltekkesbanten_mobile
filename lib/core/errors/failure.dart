import 'error_code.dart';

/// Failure sealed hierarchy
/// 
/// Represents all possible failure states from API calls
/// Based on API_CONTRACT.md v1.0 error responses
sealed class Failure {
  final String message;
  final ErrorCode errorCode;
  
  const Failure({
    required this.message,
    required this.errorCode,
  });
}

/// Authentication Failure
/// 
/// Represents 401 errors: invalid credentials, invalid token, expired token
class AuthFailure extends Failure {
  const AuthFailure({
    required super.message,
    required super.errorCode,
  });
  
  factory AuthFailure.fromErrorCode(ErrorCode code, String message) {
    return AuthFailure(
      message: message,
      errorCode: code,
    );
  }
}

/// Rate Limit Failure
/// 
/// Represents 429 errors with retry_after field
class RateLimitFailure extends Failure {
  final int retryAfterSeconds;
  
  const RateLimitFailure({
    required super.message,
    required super.errorCode,
    required this.retryAfterSeconds,
  });
  
  factory RateLimitFailure.fromErrorCode(
    ErrorCode code,
    String message,
    int retryAfterSeconds,
  ) {
    return RateLimitFailure(
      message: message,
      errorCode: code,
      retryAfterSeconds: retryAfterSeconds,
    );
  }
  
  /// Get retry after as Duration
  Duration get retryAfter => Duration(seconds: retryAfterSeconds);
}

/// Security Blocked Failure
/// 
/// Represents 403 errors: reputation blocked or IP blocked
/// May include block_until timestamp
class SecurityBlockedFailure extends Failure {
  final DateTime? blockUntil;
  
  const SecurityBlockedFailure({
    required super.message,
    required super.errorCode,
    this.blockUntil,
  });
  
  factory SecurityBlockedFailure.fromErrorCode(
    ErrorCode code,
    String message,
    DateTime? blockUntil,
  ) {
    return SecurityBlockedFailure(
      message: message,
      errorCode: code,
      blockUntil: blockUntil,
    );
  }
  
  /// Check if block is permanent (no blockUntil)
  bool get isPermanent => blockUntil == null;
  
  /// Check if block is still active
  bool get isBlocked {
    if (blockUntil == null) return true; // Permanent block
    return DateTime.now().isBefore(blockUntil!);
  }
}

/// Server Failure
/// 
/// Represents 500+ errors or INTERNAL_ERROR
class ServerFailure extends Failure {
  const ServerFailure({
    required super.message,
    required super.errorCode,
  });
  
  factory ServerFailure.fromErrorCode(ErrorCode code, String message) {
    return ServerFailure(
      message: message,
      errorCode: code,
    );
  }
}

/// Network Failure
/// 
/// Represents network connectivity issues, timeouts, etc.
/// Not from API contract, but necessary for client-side handling
class NetworkFailure extends Failure {
  const NetworkFailure({
    required super.message,
    super.errorCode = ErrorCode.unknown,
  });
}

/// Validation Failure
/// 
/// Represents 400 errors: validation errors
class ValidationFailure extends Failure {
  const ValidationFailure({
    required super.message,
    required super.errorCode,
  });
  
  factory ValidationFailure.fromErrorCode(ErrorCode code, String message) {
    return ValidationFailure(
      message: message,
      errorCode: code,
    );
  }
}

/// Resource Not Found Failure
/// 
/// Represents 404 errors
class ResourceNotFoundFailure extends Failure {
  const ResourceNotFoundFailure({
    required super.message,
    required super.errorCode,
  });
  
  factory ResourceNotFoundFailure.fromErrorCode(ErrorCode code, String message) {
    return ResourceNotFoundFailure(
      message: message,
      errorCode: code,
    );
  }
}
