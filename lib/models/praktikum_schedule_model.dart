class PraktikumScheduleModel {
  final int? id;
  final String mataKuliah;
  final String kelas;
  final String ruangLab;
  final DateTime tanggal;
  final String jamMulai;
  final String jamSelesai;
  final String? dosen;
  final String? status;

  PraktikumScheduleModel({
    this.id,
    required this.mataKuliah,
    required this.kelas,
    required this.ruangLab,
    required this.tanggal,
    required this.jamMulai,
    required this.jamSelesai,
    this.dosen,
    this.status,
  });

  factory PraktikumScheduleModel.fromJson(Map<String, dynamic> json) {
    return PraktikumScheduleModel(
      id: json['id'],
      mataKuliah: json['mata_kuliah'] ?? '',
      kelas: json['kelas'] ?? '',
      ruangLab: json['ruang_lab'] ?? '',
      tanggal: DateTime.parse(json['tanggal'] ?? DateTime.now().toIso8601String()),
      jamMulai: json['jam_mulai'] ?? '',
      jamSelesai: json['jam_selesai'] ?? '',
      dosen: json['dosen'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mata_kuliah': mataKuliah,
      'kelas': kelas,
      'ruang_lab': ruangLab,
      'tanggal': tanggal.toIso8601String(),
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
      'dosen': dosen,
      'status': status,
    };
  }
}