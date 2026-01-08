class ApiConfig {
  // Base URL - Ganti dengan URL backend PHP yang sebenarnya
  static const String baseUrl = 'https://laboratorium.poltekkesbanten.ac.id/api';
  
  // API Endpoints
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String profile = '/auth/profile';
  static const String changePassword = '/auth/change-password';
  
  // Admin Endpoints
  static const String users = '/admin/users';
  static const String manageUsers = '/admin/manage-users';
  static const String masterData = '/admin/master-data';
  static const String addUser = '/admin/users/add';
  static const String importUsers = '/admin/users/import';
  static const String editUser = '/admin/users/edit';
  static const String deleteUser = '/admin/users/delete';
  static const String addRoom = '/admin/rooms/add';
  static const String editRoom = '/admin/rooms/edit';
  static const String deleteRoom = '/admin/rooms/delete';
  
  // PLP Endpoints
  static const String daftarBarang = '/plp/items';
  static const String jadwalPraktikum = '/plp/praktikum/schedule';
  static const String requestPeralatan = '/plp/equipment/requests';
  static const String requestJadwalPraktek = '/plp/schedule/requests';
  static const String pinjamanPengembalian = '/plp/loans';
  static const String laporan = '/plp/reports';
  static const String approveRequest = '/plp/requests/approve';
  static const String rejectRequest = '/plp/requests/reject';
  static const String requestDetail = '/plp/requests/detail';
  
  // User Endpoints
  static const String userRequestPeralatan = '/user/equipment/requests';
  static const String userCreateRequest = '/user/equipment/request/create';
  static const String userJadwalPraktikum = '/user/praktikum/schedule';
  static const String userKunjunganLab = '/user/lab-visits';
  static const String userRequestDetail = '/user/requests/detail';
  
  // Headers
  static Map<String, String> getHeaders(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}