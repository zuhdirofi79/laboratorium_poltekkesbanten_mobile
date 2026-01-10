/// Equipment Request Summary Domain Model
/// 
/// Used for list view (pending approval requests)
/// Based on GET /plp/equipment/requests?status=Menunggu
/// Strongly typed model with camelCase fields
/// fromJson factory only (no toJson needed yet)
class EquipmentRequestSummary {
  final int id;
  final int userId;
  final String userName;
  final String itemName;
  final String labRoom;
  final String status;
  final DateTime requestDate;
  final String? department;
  final String? responsiblePerson;
  final String? level;
  final String? purpose;
  final DateTime? returnDate;
  final DateTime createdAt;
  
  const EquipmentRequestSummary({
    required this.id,
    required this.userId,
    required this.userName,
    required this.itemName,
    required this.labRoom,
    required this.status,
    required this.requestDate,
    this.department,
    this.responsiblePerson,
    this.level,
    this.purpose,
    this.returnDate,
    required this.createdAt,
  });
  
  /// Parse from JSON (snake_case Indonesian fields from backend)
  /// Backend: api/plp/equipment/requests.php
  factory EquipmentRequestSummary.fromJson(Map<String, dynamic> json) {
    return EquipmentRequestSummary(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      userName: json['user_name'] as String? ?? '',
      itemName: json['jenis'] as String? ?? '',
      labRoom: json['ruangan'] as String? ?? '',
      status: json['status'] as String? ?? '',
      requestDate: json['tgl_pinjaman'] != null
          ? DateTime.parse(json['tgl_pinjaman'] as String)
          : DateTime.now(),
      department: json['jurusan'] as String?,
      responsiblePerson: json['penanggung_jawab'] as String?,
      level: json['tingkat'] as String?,
      purpose: json['tujuan'] as String?,
      returnDate: json['tgl_pengembalian'] != null
          ? DateTime.parse(json['tgl_pengembalian'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
  
  /// Get status label for display
  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'menunggu konfirmasi':
      case 'menunggu':
        return 'Menunggu Konfirmasi';
      case 'approved':
      case 'disetujui':
      case 'diterima':
        return 'Disetujui';
      case 'rejected':
      case 'ditolak':
        return 'Ditolak';
      case 'selesai':
        return 'Selesai';
      default:
        return status;
    }
  }
  
  /// Check if request can be approved/rejected
  bool get canApproveOrReject {
    final statusLower = status.toLowerCase();
    return statusLower == 'pending' ||
        statusLower == 'menunggu konfirmasi' ||
        statusLower == 'menunggu';
  }
}
