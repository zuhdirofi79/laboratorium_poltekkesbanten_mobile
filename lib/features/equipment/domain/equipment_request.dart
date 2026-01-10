/// Equipment Request Domain Model
/// 
/// Based on actual backend response from GET /user/equipment/requests
/// Strongly typed model with camelCase fields
/// fromJson factory only (no toJson needed yet)
class EquipmentRequest {
  final int id;
  final String itemName;
  final String labRoom;
  final DateTime requestDate;
  final String status;
  final String? notes;
  final String? department;
  final String? responsiblePerson;
  final String? level;
  final String? startTime;
  final String? endTime;
  final DateTime? returnDate;
  final DateTime createdAt;
  
  const EquipmentRequest({
    required this.id,
    required this.itemName,
    required this.labRoom,
    required this.requestDate,
    required this.status,
    this.notes,
    this.department,
    this.responsiblePerson,
    this.level,
    this.startTime,
    this.endTime,
    this.returnDate,
    required this.createdAt,
  });
  
  /// Parse from JSON (snake_case Indonesian fields from backend)
  /// Backend response: api/user/equipment/requests.php
  factory EquipmentRequest.fromJson(Map<String, dynamic> json) {
    return EquipmentRequest(
      id: json['id'] as int,
      itemName: json['jenis'] as String? ?? '',
      labRoom: json['ruangan'] as String? ?? '',
      requestDate: json['tgl_pinjaman'] != null
          ? DateTime.parse(json['tgl_pinjaman'] as String)
          : DateTime.now(),
      status: json['status'] as String? ?? '',
      notes: json['tujuan'] as String?,
      department: json['jurusan'] as String?,
      responsiblePerson: json['penanggung_jawab'] as String?,
      level: json['tingkat'] as String?,
      startTime: json['waktu_mulai'] as String?,
      endTime: json['waktu_selesai'] as String?,
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
      case 'selesai':
        return 'Disetujui';
      case 'rejected':
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }
}
