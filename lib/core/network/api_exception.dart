import 'dart:convert';
import '../config/api_config.dart';
import '../errors/error_code.dart';
import '../errors/failure.dart';

/// API Exception
/// 
/// Parses API error responses according to API_CONTRACT.md v1.0
class ApiException implements Exception {
  final int statusCode;
  final String? body;
  final ErrorCode? errorCode;
  final String? message;
  final int? retryAfter;
  final DateTime? blockUntil;
  
  const ApiException({
    required this.statusCode,
    this.body,
    this.errorCode,
    this.message,
    this.retryAfter,
    this.blockUntil,
  });
  
  /// Parse exception from HTTP response
  factory ApiException.fromResponse(int statusCode, String? body) {
    ErrorCode? errorCode;
    String? message;
    int? retryAfter;
    DateTime? blockUntil;
    
    // Try to parse error response from contract
    if (body != null && body.isNotEmpty) {
      try {
        final json = jsonDecode(body) as Map<String, dynamic>;
        
        // Extract error_code (from contract)
        if (json.containsKey(ApiConfig.fieldErrorCode)) {
          final errorCodeStr = json[ApiConfig.fieldErrorCode] as String?;
          errorCode = ErrorCode.fromString(errorCodeStr);
        }
        
        // Extract message (from contract)
        if (json.containsKey(ApiConfig.fieldMessage)) {
          message = json[ApiConfig.fieldMessage] as String?;
        }
        
        // Extract retry_after (for 429)
        if (json.containsKey(ApiConfig.fieldRetryAfter)) {
          retryAfter = json[ApiConfig.fieldRetryAfter] as int?;
        }
        
        // Extract block_until (for 403 reputation blocks)
        if (json.containsKey(ApiConfig.fieldBlockUntil)) {
          final blockUntilStr = json[ApiConfig.fieldBlockUntil] as String?;
          if (blockUntilStr != null && blockUntilStr.isNotEmpty) {
            try {
              blockUntil = DateTime.parse(blockUntilStr);
            } catch (e) {
              // Invalid date format, ignore
            }
          }
        }
      } catch (e) {
        // Failed to parse JSON, use default message
      }
    }
    
    // Fallback error code based on status code if not parsed from response
    errorCode ??= _errorCodeFromStatusCode(statusCode);
    
    // Fallback message if not parsed from response
    message ??= _defaultMessage(statusCode);
    
    return ApiException(
      statusCode: statusCode,
      body: body,
      errorCode: errorCode,
      message: message,
      retryAfter: retryAfter,
      blockUntil: blockUntil,
    );
  }
  
  /// Convert exception to Failure
  Failure toFailure() {
    switch (statusCode) {
      case 401:
        return AuthFailure.fromErrorCode(
          errorCode ?? ErrorCode.authInvalidToken,
          message ?? 'Unauthorized',
        );
        
      case 403:
        return SecurityBlockedFailure.fromErrorCode(
          errorCode ?? ErrorCode.forbiddenRole,
          message ?? 'Forbidden',
          blockUntil,
        );
        
      case 429:
        return RateLimitFailure.fromErrorCode(
          errorCode ?? ErrorCode.rateLimited,
          message ?? 'Rate limit exceeded',
          retryAfter ?? 60, // Default 60 seconds if not provided
        );
        
      case 404:
        return ResourceNotFoundFailure.fromErrorCode(
          errorCode ?? ErrorCode.resourceNotFound,
          message ?? 'Resource not found',
        );
        
      case 400:
        return ValidationFailure.fromErrorCode(
          errorCode ?? ErrorCode.validationError,
          message ?? 'Validation error',
        );
        
      default:
        if (statusCode >= 500) {
          return ServerFailure.fromErrorCode(
            errorCode ?? ErrorCode.internalError,
            message ?? 'Server error',
          );
        }
        return ServerFailure.fromErrorCode(
          errorCode ?? ErrorCode.unknown,
          message ?? 'Unknown error',
        );
    }
  }
  
  /// Map HTTP status code to ErrorCode (fallback)
  static ErrorCode _errorCodeFromStatusCode(int statusCode) {
    switch (statusCode) {
      case 401:
        return ErrorCode.authInvalidToken;
      case 403:
        return ErrorCode.forbiddenRole;
      case 404:
        return ErrorCode.resourceNotFound;
      case 429:
        return ErrorCode.rateLimited;
      case 400:
        return ErrorCode.validationError;
      default:
        if (statusCode >= 500) {
          return ErrorCode.internalError;
        }
        return ErrorCode.unknown;
    }
  }
  
  /// Default message based on status code
  static String _defaultMessage(int statusCode) {
    switch (statusCode) {
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Resource not found';
      case 429:
        return 'Rate limit exceeded';
      case 400:
        return 'Bad request';
      default:
        if (statusCode >= 500) {
          return 'Server error';
        }
        return 'Unknown error';
    }
  }
}
