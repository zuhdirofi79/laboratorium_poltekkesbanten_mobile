/// Error Code Enum
/// 
/// Based on API_CONTRACT.md v1.0 Error Code Registry
/// All error codes from contract are defined here
enum ErrorCode {
  // Authentication errors
  authInvalidCredentials,
  authInvalidToken,
  authTokenExpired,
  
  // Authorization errors
  forbiddenRole,
  reputationBlocked,
  ipBlocked,
  
  // Rate limiting
  rateLimited,
  
  // Validation and resource errors
  validationError,
  resourceNotFound,
  
  // Server errors
  internalError,
  
  // Unknown error (fallback)
  unknown;

  /// Convert from API error code string (UPPER_SNAKE_CASE) to enum
  static ErrorCode fromString(String? errorCode) {
    if (errorCode == null) return ErrorCode.unknown;
    
    switch (errorCode.toUpperCase()) {
      case 'AUTH_INVALID_CREDENTIALS':
        return ErrorCode.authInvalidCredentials;
      case 'AUTH_INVALID_TOKEN':
        return ErrorCode.authInvalidToken;
      case 'AUTH_TOKEN_EXPIRED':
        return ErrorCode.authTokenExpired;
      case 'FORBIDDEN_ROLE':
        return ErrorCode.forbiddenRole;
      case 'REPUTATION_BLOCKED':
        return ErrorCode.reputationBlocked;
      case 'IP_BLOCKED':
        return ErrorCode.ipBlocked;
      case 'RATE_LIMITED':
        return ErrorCode.rateLimited;
      case 'VALIDATION_ERROR':
        return ErrorCode.validationError;
      case 'RESOURCE_NOT_FOUND':
        return ErrorCode.resourceNotFound;
      case 'INTERNAL_ERROR':
        return ErrorCode.internalError;
      default:
        return ErrorCode.unknown;
    }
  }
  
  /// Convert enum to API error code string
  String toApiString() {
    switch (this) {
      case ErrorCode.authInvalidCredentials:
        return 'AUTH_INVALID_CREDENTIALS';
      case ErrorCode.authInvalidToken:
        return 'AUTH_INVALID_TOKEN';
      case ErrorCode.authTokenExpired:
        return 'AUTH_TOKEN_EXPIRED';
      case ErrorCode.forbiddenRole:
        return 'FORBIDDEN_ROLE';
      case ErrorCode.reputationBlocked:
        return 'REPUTATION_BLOCKED';
      case ErrorCode.ipBlocked:
        return 'IP_BLOCKED';
      case ErrorCode.rateLimited:
        return 'RATE_LIMITED';
      case ErrorCode.validationError:
        return 'VALIDATION_ERROR';
      case ErrorCode.resourceNotFound:
        return 'RESOURCE_NOT_FOUND';
      case ErrorCode.internalError:
        return 'INTERNAL_ERROR';
      case ErrorCode.unknown:
        return 'UNKNOWN_ERROR';
    }
  }
  
  /// Check if this is an authentication error (401)
  bool get isAuthError {
    return this == ErrorCode.authInvalidCredentials ||
        this == ErrorCode.authInvalidToken ||
        this == ErrorCode.authTokenExpired;
  }
  
  /// Check if this is an authorization error (403)
  bool get isAuthorizationError {
    return this == ErrorCode.forbiddenRole ||
        this == ErrorCode.reputationBlocked ||
        this == ErrorCode.ipBlocked;
  }
  
  /// Check if this is a rate limit error (429)
  bool get isRateLimitError {
    return this == ErrorCode.rateLimited;
  }
  
  /// Check if this is a security block (403 reputation/IP)
  bool get isSecurityBlock {
    return this == ErrorCode.reputationBlocked || this == ErrorCode.ipBlocked;
  }
}
