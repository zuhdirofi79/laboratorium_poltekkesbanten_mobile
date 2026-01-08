class LabRoomModel {
  final int? id;
  final String jurusan;
  final String kampus;
  final String namaRuangLab;

  LabRoomModel({
    this.id,
    required this.jurusan,
    required this.kampus,
    required this.namaRuangLab,
  });

  factory LabRoomModel.fromJson(Map<String, dynamic> json) {
    return LabRoomModel(
      id: json['id'],
      jurusan: json['jurusan'] ?? '',
      kampus: json['kampus'] ?? '',
      namaRuangLab: json['nama_ruang_lab'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'jurusan': jurusan,
      'kampus': kampus,
      'nama_ruang_lab': namaRuangLab,
    };
  }
}