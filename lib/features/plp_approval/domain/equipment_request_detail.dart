/// Equipment Request Detail Domain Model
/// 
/// Used for detail view with items list
/// Based on GET /plp/requests/detail.php?id={id}
/// Strongly typed model with camelCase fields
/// fromJson factory only (no toJson needed yet)
class EquipmentRequestDetail {
  final int id;
  final int userId;
  final String userName;
  final String userUsername;
  final String itemName;
  final String labRoom;
  final String status;
  final DateTime requestDate;
  final String? department;
  final String? responsiblePerson;
  final String? level;
  final String? startTime;
  final String? endTime;
  final String? purpose;
  final DateTime? returnDate;
  final DateTime createdAt;
  final List<EquipmentRequestItem> items;
  
  const EquipmentRequestDetail({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userUsername,
    required this.itemName,
    required this.labRoom,
    required this.status,
    required this.requestDate,
    this.department,
    this.responsiblePerson,
    this.level,
    this.startTime,
    this.endTime,
    this.purpose,
    this.returnDate,
    required this.createdAt,
    required this.items,
  });
  
  /// Parse from JSON (snake_case Indonesian fields from backend)
  /// Backend: api/plp/requests/detail.php
  factory EquipmentRequestDetail.fromJson(Map<String, dynamic> json) {
    final itemsJson = json['items'] as List<dynamic>? ?? [];
    final items = itemsJson
        .map((item) => EquipmentRequestItem.fromJson(item as Map<String, dynamic>))
        .toList();
    
    return EquipmentRequestDetail(
      id: json['id'] as int? ?? 0,
      userId: json['user_id'] as int? ?? 0,
      userName: json['user_name'] as String? ?? '',
      userUsername: json['user_username'] as String? ?? '',
      itemName: json['jenis'] as String? ?? '',
      labRoom: json['ruangan'] as String? ?? '',
      status: json['status'] as String? ?? '',
      requestDate: json['tgl_pinjaman'] != null
          ? DateTime.parse(json['tgl_pinjaman'] as String)
          : DateTime.now(),
      department: json['jurusan'] as String?,
      responsiblePerson: json['penanggung_jawab'] as String?,
      level: json['tingkat'] as String?,
      startTime: json['waktu_mulai'] as String?,
      endTime: json['waktu_selesai'] as String?,
      purpose: json['tujuan'] as String?,
      returnDate: json['tgl_pengembalian'] != null
          ? DateTime.parse(json['tgl_pengembalian'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      items: items,
    );
  }
  
  /// Check if request can be approved/rejected
  bool get canApproveOrReject {
    final statusLower = status.toLowerCase();
    return statusLower == 'pending' ||
        statusLower == 'menunggu konfirmasi' ||
        statusLower == 'menunggu';
  }
}

/// Equipment Request Item Domain Model
/// 
/// Represents individual equipment items in a request
class EquipmentRequestItem {
  final int id;
  final int itemId;
  final String itemName;
  final String? itemType;
  final int stockQuantity;
  final String status;
  final String? condition;
  final String? loanOfficer;
  final String? returnOfficer;
  
  const EquipmentRequestItem({
    required this.id,
    required this.itemId,
    required this.itemName,
    this.itemType,
    required this.stockQuantity,
    required this.status,
    this.condition,
    this.loanOfficer,
    this.returnOfficer,
  });
  
  /// Parse from JSON (snake_case from backend)
  factory EquipmentRequestItem.fromJson(Map<String, dynamic> json) {
    return EquipmentRequestItem(
      id: json['id'] as int? ?? 0,
      itemId: json['barang_id'] as int? ?? 0,
      itemName: json['barang_nama'] as String? ?? '',
      itemType: json['barang_type'] as String?,
      stockQuantity: json['stok_pinjam'] as int? ?? 0,
      status: json['status'] as String? ?? '',
      condition: json['kondisi'] as String?,
      loanOfficer: json['petugas_peminjaman'] as String?,
      returnOfficer: json['petugas_pengembalian'] as String?,
    );
  }
}
