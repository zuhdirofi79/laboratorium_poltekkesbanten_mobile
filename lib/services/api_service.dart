import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/equipment_request_model.dart';
import '../models/lab_room_model.dart';
import '../models/praktikum_schedule_model.dart';
import '../models/item_model.dart';
import '../utils/api_config.dart';

class ApiService {
  late Dio _dio;
  String? _token;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: ApiConfig.getHeaders(null),
    ));

    // Load token from storage
    _loadToken();

    // Add interceptor for auto token refresh
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers['Authorization'] = 'Bearer $_token';
        }
        return handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Handle unauthorized - logout user
          _clearToken();
        }
        return handler.next(error);
      },
    ));
  }

  Future<void> _loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    if (_token != null) {
      _dio.options.headers['Authorization'] = 'Bearer $_token';
    }
  }

  Future<void> _saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> _clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    _dio.options.headers.remove('Authorization');
  }

  // Auth APIs
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await _dio.post(
        ApiConfig.login,
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.data['success'] == true) {
        final token = response.data['data']['token'];
        await _saveToken(token);
        return response.data;
      }
      throw Exception(response.data['message'] ?? 'Login failed');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Login failed');
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConfig.logout);
    } finally {
      await _clearToken();
    }
  }

  Future<UserModel> getProfile() async {
    try {
      final response = await _dio.get(ApiConfig.profile);
      return UserModel.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get profile');
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await _dio.post(
        ApiConfig.changePassword,
        data: {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to change password');
    }
  }

  // Admin APIs
  Future<List<UserModel>> getUsers({String? search}) async {
    try {
      final response = await _dio.get(
        ApiConfig.users,
        queryParameters: search != null ? {'search': search} : null,
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => UserModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get users');
    }
  }

  Future<List<UserModel>> getManageUsers({String? search}) async {
    try {
      final response = await _dio.get(
        ApiConfig.manageUsers,
        queryParameters: search != null ? {'search': search} : null,
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => UserModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get manage users');
    }
  }

  Future<List<LabRoomModel>> getMasterData({String? search}) async {
    try {
      final response = await _dio.get(
        ApiConfig.masterData,
        queryParameters: search != null ? {'search': search} : null,
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => LabRoomModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get master data');
    }
  }

  Future<void> addUser(Map<String, dynamic> userData) async {
    try {
      await _dio.post(ApiConfig.addUser, data: userData);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to add user');
    }
  }

  Future<void> editUser(int id, Map<String, dynamic> userData) async {
    try {
      await _dio.put('${ApiConfig.editUser}/$id', data: userData);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to edit user');
    }
  }

  Future<void> deleteUser(int id) async {
    try {
      await _dio.delete('${ApiConfig.deleteUser}/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete user');
    }
  }

  Future<void> addRoom(Map<String, dynamic> roomData) async {
    try {
      await _dio.post(ApiConfig.addRoom, data: roomData);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to add room');
    }
  }

  Future<void> editRoom(int id, Map<String, dynamic> roomData) async {
    try {
      await _dio.put('${ApiConfig.editRoom}/$id', data: roomData);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to edit room');
    }
  }

  Future<void> deleteRoom(int id) async {
    try {
      await _dio.delete('${ApiConfig.deleteRoom}/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to delete room');
    }
  }

  // PLP APIs
  Future<List<ItemModel>> getDaftarBarang({String? search}) async {
    try {
      final response = await _dio.get(
        ApiConfig.daftarBarang,
        queryParameters: search != null ? {'search': search} : null,
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => ItemModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get items');
    }
  }

  Future<List<PraktikumScheduleModel>> getJadwalPraktikum({String? search}) async {
    try {
      final response = await _dio.get(
        ApiConfig.jadwalPraktikum,
        queryParameters: search != null ? {'search': search} : null,
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => PraktikumScheduleModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get schedule');
    }
  }

  Future<List<EquipmentRequestModel>> getRequestPeralatan({String? jurusan}) async {
    try {
      final response = await _dio.get(
        ApiConfig.requestPeralatan,
        queryParameters: jurusan != null ? {'jurusan': jurusan} : null,
      );
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => EquipmentRequestModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get requests');
    }
  }

  Future<Map<String, dynamic>> getRequestDetail(int id) async {
    try {
      final response = await _dio.get('${ApiConfig.requestDetail}/$id');
      return response.data['data'];
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get request detail');
    }
  }

  Future<void> approveRequest(int id) async {
    try {
      await _dio.post('${ApiConfig.approveRequest}/$id');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to approve request');
    }
  }

  Future<void> rejectRequest(int id, {String? reason}) async {
    try {
      await _dio.post('${ApiConfig.rejectRequest}/$id', data: {'reason': reason});
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to reject request');
    }
  }

  // User APIs
  Future<List<EquipmentRequestModel>> getUserRequestPeralatan() async {
    try {
      final response = await _dio.get(ApiConfig.userRequestPeralatan);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => EquipmentRequestModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get requests');
    }
  }

  Future<void> createEquipmentRequest(Map<String, dynamic> requestData) async {
    try {
      await _dio.post(ApiConfig.userCreateRequest, data: requestData);
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to create request');
    }
  }

  Future<List<PraktikumScheduleModel>> getUserJadwalPraktikum() async {
    try {
      final response = await _dio.get(ApiConfig.userJadwalPraktikum);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => PraktikumScheduleModel.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get schedule');
    }
  }

  Future<List<Map<String, dynamic>>> getUserKunjunganLab() async {
    try {
      final response = await _dio.get(ApiConfig.userKunjunganLab);
      final List<dynamic> data = response.data['data'] ?? [];
      return data.cast<Map<String, dynamic>>();
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Failed to get lab visits');
    }
  }
}