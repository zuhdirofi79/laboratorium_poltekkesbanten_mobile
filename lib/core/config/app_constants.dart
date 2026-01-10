/// Application Constants
/// 
/// Application-wide constants not specific to API contract
class AppConstants {
  // Token storage key
  static const String tokenStorageKey = 'auth_token';
  
  // User role values (from contract)
  static const String roleAdmin = 'admin';
  static const String rolePlp = 'plp';
  static const String roleUser = 'user';
  
  // Date/Time formats (ISO 8601 from contract)
  static const String dateFormat = 'yyyy-MM-dd';
  static const String timeFormat = 'HH:mm:ss';
  static const String dateTimeFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'";
  
  // Minimum password length (from contract)
  static const int minPasswordLength = 6;
  
  // Private constructor - this is a utility class
  AppConstants._();
}
