import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_constants.dart';
import '../utils/logger.dart';

/// Token Storage Abstraction
/// 
/// Handles JWT token persistence
/// Token is opaque - no decoding or inspection
/// Uses SharedPreferences as underlying storage
class TokenStorage {
  static TokenStorage? _instance;
  SharedPreferences? _prefs;
  
  TokenStorage._();
  
  /// Get singleton instance
  static Future<TokenStorage> getInstance() async {
    _instance ??= TokenStorage._();
    _instance!._prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }
  
  /// Save JWT token
  /// 
  /// Token is treated as opaque string per contract
  Future<bool> saveToken(String token) async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      return await _prefs!.setString(AppConstants.tokenStorageKey, token);
    } catch (e, stackTrace) {
      Logger.error('Failed to save token', e, stackTrace);
      return false;
    }
  }
  
  /// Get JWT token
  /// 
  /// Returns null if no token exists
  String? getToken() {
    try {
      return _prefs?.getString(AppConstants.tokenStorageKey);
    } catch (e, stackTrace) {
      Logger.error('Failed to get token', e, stackTrace);
      return null;
    }
  }
  
  /// Check if token exists
  bool hasToken() {
    try {
      return _prefs?.containsKey(AppConstants.tokenStorageKey) ?? false;
    } catch (e, stackTrace) {
      Logger.error('Failed to check token', e, stackTrace);
      return false;
    }
  }
  
  /// Clear/Remove token
  /// 
  /// Called on logout or when token is invalid
  Future<bool> clearToken() async {
    try {
      _prefs ??= await SharedPreferences.getInstance();
      return await _prefs!.remove(AppConstants.tokenStorageKey);
    } catch (e, stackTrace) {
      Logger.error('Failed to clear token', e, stackTrace);
      return false;
    }
  }
}
