import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../errors/error_code.dart';
import '../errors/failure.dart';
import '../utils/logger.dart';
import 'api_exception.dart';
import 'api_interceptor.dart';

/// API Client
/// 
/// Production-ready HTTP client based on API_CONTRACT.md v1.0
/// Uses http package as required
/// Handles all error codes from contract
class ApiClient {
  final ApiInterceptor _interceptor;
  
  ApiClient(this._interceptor);
  
  /// Make GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParameters,
    bool requiresAuth = true,
  }) async {
    return _request(
      'GET',
      endpoint,
      queryParameters: queryParameters,
      requiresAuth: requiresAuth,
    );
  }
  
  /// Make POST request
  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    return _request(
      'POST',
      endpoint,
      body: body,
      requiresAuth: requiresAuth,
    );
  }
  
  /// Make PUT request
  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    return _request(
      'PUT',
      endpoint,
      body: body,
      requiresAuth: requiresAuth,
    );
  }
  
  /// Make DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool requiresAuth = true,
  }) async {
    return _request(
      'DELETE',
      endpoint,
      requiresAuth: requiresAuth,
    );
  }
  
  /// Core request method
  Future<Map<String, dynamic>> _request(
    String method,
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, dynamic>? body,
    bool requiresAuth = true,
  }) async {
    try {
      // Build URL
      var url = '${ApiConfig.baseUrl}$endpoint';
      if (queryParameters != null && queryParameters.isNotEmpty) {
        final queryString = Uri(queryParameters: queryParameters).query;
        url = '$url?$queryString';
      }
      
      final uri = Uri.parse(url);
      
      // Build headers
      final headers = await _interceptor.buildHeaders(
        requiresAuth: requiresAuth,
      );
      
      // Build request body
      String? requestBody;
      if (body != null) {
        requestBody = jsonEncode(body);
      }
      
      Logger.debug('$method $url', null, null);
      if (requestBody != null) {
        Logger.debug('Body: $requestBody', null, null);
      }
      
      // Make request with timeout
      http.Response response;
      try {
        switch (method.toUpperCase()) {
          case 'GET':
            response = await http
                .get(uri, headers: headers)
                .timeout(ApiConfig.requestTimeout);
            break;
          case 'POST':
            response = await http
                .post(uri, headers: headers, body: requestBody)
                .timeout(ApiConfig.requestTimeout);
            break;
          case 'PUT':
            response = await http
                .put(uri, headers: headers, body: requestBody)
                .timeout(ApiConfig.requestTimeout);
            break;
          case 'DELETE':
            response = await http
                .delete(uri, headers: headers)
                .timeout(ApiConfig.requestTimeout);
            break;
          default:
            throw ServerFailure(
              message: 'Unsupported HTTP method: $method',
              errorCode: ErrorCode.unknown,
            );
        }
      } on SocketException catch (e) {
        Logger.error('Network error', e, null);
        throw NetworkFailure(message: 'No internet connection');
      } on HttpException catch (e) {
        Logger.error('HTTP error', e, null);
        throw NetworkFailure(message: 'HTTP error: ${e.message}');
      } on FormatException catch (e) {
        Logger.error('Format error', e, null);
        throw NetworkFailure(message: 'Invalid response format');
      } catch (e) {
        if (e is Failure) rethrow;
        Logger.error('Request error', e, null);
        throw NetworkFailure(message: 'Request failed: $e');
      }
      
      Logger.debug(
        'Response: ${response.statusCode}',
        null,
        null,
      );
      Logger.debug('Body: ${response.body}', null, null);
      
      // Handle 401 - clear token
      if (response.statusCode == 401) {
        await _interceptor.handleUnauthorized();
      }
      
      // Parse response
      Map<String, dynamic>? jsonResponse;
      if (response.body.isNotEmpty) {
        try {
          jsonResponse = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          Logger.error('Failed to parse JSON response', e, null);
          throw NetworkFailure(message: 'Invalid JSON response');
        }
      }
      
      // Handle error responses (from contract)
      if (response.statusCode >= 400) {
        final exception = ApiException.fromResponse(
          response.statusCode,
          response.body,
        );
        throw exception.toFailure();
      }
      
      // Validate success response structure (from contract)
      if (jsonResponse != null) {
        if (jsonResponse.containsKey(ApiConfig.fieldSuccess)) {
          final success = jsonResponse[ApiConfig.fieldSuccess] as bool?;
          if (success == false) {
            // This is an error response despite 2xx status code
            final exception = ApiException.fromResponse(
              response.statusCode,
              response.body,
            );
            throw exception.toFailure();
          }
        }
      }
      
      // Return parsed response
      return jsonResponse ?? {};
    } catch (e) {
      if (e is Failure) rethrow;
      Logger.error('Unexpected error in API client', e, null);
      throw NetworkFailure(message: 'Unexpected error: $e');
    }
  }
}
