import '../data/auth_models.dart';
import '../../../core/errors/failure.dart';

/// Auth State
/// 
/// Represents all possible authentication states
/// Used by UI layer (when implemented) to determine what to show
sealed class AuthState {
  const AuthState();
}

/// Unauthenticated State
/// 
/// User is not logged in or token is invalid
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// Authenticated State
/// 
/// User is logged in and token is valid
class Authenticated extends AuthState {
  final AuthenticatedUser user;
  
  const Authenticated(this.user);
}

/// Loading State
/// 
/// Authentication operation in progress
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// Error State
/// 
/// Authentication operation failed
class AuthError extends AuthState {
  final Failure failure;
  
  const AuthError(this.failure);
}

/// Blocked State
/// 
/// User/IP blocked by reputation system
/// May include block expiration time
class Blocked extends AuthState {
  final SecurityBlockedFailure failure;
  
  const Blocked(this.failure);
  
  /// Check if block is permanent
  bool get isPermanent => failure.isPermanent;
  
  /// Check if block is still active
  bool get isBlocked => failure.isBlocked;
  
  /// Get block expiration time
  DateTime? get blockUntil => failure.blockUntil;
}

/// Rate Limited State
/// 
/// Too many requests - must wait before retry
class RateLimited extends AuthState {
  final RateLimitFailure failure;
  
  const RateLimited(this.failure);
  
  /// Get seconds until retry allowed
  int get retryAfterSeconds => failure.retryAfterSeconds;
  
  /// Get retry after as Duration
  Duration get retryAfter => failure.retryAfter;
}
