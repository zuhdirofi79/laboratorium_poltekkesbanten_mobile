class ItemModel {
  final int? id;
  final String namaBarang;
  final String kategori;
  final String? merk;
  final String? spesifikasi;
  final int jumlah;
  final String kondisi;
  final String? lokasi;

  ItemModel({
    this.id,
    required this.namaBarang,
    required this.kategori,
    this.merk,
    this.spesifikasi,
    required this.jumlah,
    required this.kondisi,
    this.lokasi,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      namaBarang: json['nama_barang'] ?? '',
      kategori: json['kategori'] ?? '',
      merk: json['merk'],
      spesifikasi: json['spesifikasi'],
      jumlah: json['jumlah'] ?? 0,
      kondisi: json['kondisi'] ?? '',
      lokasi: json['lokasi'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_barang': namaBarang,
      'kategori': kategori,
      'merk': merk,
      'spesifikasi': spesifikasi,
      'jumlah': jumlah,
      'kondisi': kondisi,
      'lokasi': lokasi,
    };
  }
}