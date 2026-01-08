class EquipmentRequestModel {
  final int? id;
  final String namaPeminjam;
  final String jenisAlat;
  final String ruangLab;
  final String tingkat;
  final DateTime tglPermintaan;
  final String status;
  final String? jurusan;
  final String? keterangan;

  EquipmentRequestModel({
    this.id,
    required this.namaPeminjam,
    required this.jenisAlat,
    required this.ruangLab,
    required this.tingkat,
    required this.tglPermintaan,
    required this.status,
    this.jurusan,
    this.keterangan,
  });

  factory EquipmentRequestModel.fromJson(Map<String, dynamic> json) {
    return EquipmentRequestModel(
      id: json['id'],
      namaPeminjam: json['nama_peminjam'] ?? '',
      jenisAlat: json['jenis_alat'] ?? '',
      ruangLab: json['ruang_lab'] ?? '',
      tingkat: json['tingkat'] ?? '',
      tglPermintaan: DateTime.parse(json['tgl_permintaan'] ?? DateTime.now().toIso8601String()),
      status: json['status'] ?? '',
      jurusan: json['jurusan'],
      keterangan: json['keterangan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_peminjam': namaPeminjam,
      'jenis_alat': jenisAlat,
      'ruang_lab': ruangLab,
      'tingkat': tingkat,
      'tgl_permintaan': tglPermintaan.toIso8601String(),
      'status': status,
      'jurusan': jurusan,
      'keterangan': keterangan,
    };
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
      case 'menunggu konfirmasi':
        return 'Menunggu Konfirmasi';
      case 'approved':
      case 'disetujui':
        return 'Disetujui';
      case 'rejected':
      case 'ditolak':
        return 'Ditolak';
      default:
        return status;
    }
  }
}