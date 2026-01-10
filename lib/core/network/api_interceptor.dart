import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../storage/token_storage.dart';
import '../utils/logger.dart';

/// API Interceptor
/// 
/// Handles automatic header injection and request preprocessing
class ApiInterceptor {
  final TokenStorage _tokenStorage;
  
  ApiInterceptor(this._tokenStorage);
  
  /// Build headers for request
  /// 
  /// Automatically adds:
  /// - Content-Type: application/json
  /// - X-API-Version: 1
  /// - User-Agent: laboratorium-mobile-app
  /// - Authorization: Bearer <token> (if token exists)
  Future<Map<String, String>> buildHeaders({
    bool requiresAuth = true,
  }) async {
    final headers = <String, String>{
      ApiConfig.headerContentType: ApiConfig.contentTypeJson,
      ApiConfig.headerApiVersion: ApiConfig.apiVersion,
      ApiConfig.headerUserAgent: ApiConfig.userAgent,
    };
    
    // Add Authorization header if auth is required and token exists
    if (requiresAuth) {
      final token = _tokenStorage.getToken();
      if (token != null && token.isNotEmpty) {
        headers[ApiConfig.headerAuthorization] = 
            '${ApiConfig.authorizationBearer} $token';
      }
    }
    
    return headers;
  }
  
  /// Handle 401 response - token invalid/expired
  /// 
  /// Clears token and logs the event
  Future<void> handleUnauthorized() async {
    Logger.warning('401 Unauthorized - clearing token');
    await _tokenStorage.clearToken();
  }
}
