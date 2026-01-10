/// Praktikum Schedule Domain Model
/// 
/// Based on API_CONTRACT.md v1.0 - GET /user/praktikum/schedule
/// Strongly typed model with camelCase fields
/// fromJson factory only (no toJson needed yet)
class PraktikumSchedule {
  final int id;
  final String mataKuliah;
  final String kelas;
  final String ruangLab;
  final DateTime tanggal;
  final String jamMulai;
  final String jamSelesai;
  
  const PraktikumSchedule({
    required this.id,
    required this.mataKuliah,
    required this.kelas,
    required this.ruangLab,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
  });
  
  /// Parse from JSON (snake_case from backend)
  /// Backend: api/user/praktikum/schedule.php
  /// Maps backend fields to camelCase domain model
  factory PraktikumSchedule.fromJson(Map<String, dynamic> json) {
    return PraktikumSchedule(
      id: json['id'] as int? ?? 0,
      mataKuliah: json['mata_kuliah'] as String? ?? 
                  json['tujuan'] as String? ?? 
                  '', // mata_kuliah may not exist, fallback to tujuan or empty
      kelas: json['kelas'] as String? ?? '',
      ruangLab: json['ruang_lab'] as String? ?? 
                 json['ruang'] as String? ?? 
                 '', // ruang_lab may not exist, fallback to ruang
      tanggal: json['tanggal'] != null
          ? DateTime.parse(json['tanggal'] as String)
          : json['tgl'] != null
              ? DateTime.parse(json['tgl'] as String)
              : DateTime.now(), // fallback to tgl or now
      jamMulai: json['jam_mulai'] as String? ?? 
                json['waktu_mulai'] as String? ?? 
                '', // fallback to waktu_mulai
      jamSelesai: json['jam_selesai'] as String? ?? 
                  json['waktu_selesai'] as String? ?? 
                  '', // fallback to waktu_selesai
    );
  }
}
