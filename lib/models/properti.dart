// lib/models/properti.dart

class Properti {
  final int id;
  final String namaProperti;
  final String alamat;
  final String? deskripsi;
  final int pemilikId;
  final DateTime createdAt;

  Properti({
    required this.id,
    required this.namaProperti,
    required this.alamat,
    this.deskripsi,
    required this.pemilikId,
    required this.createdAt,
  });

  factory Properti.fromJson(Map<String, dynamic> json) {
    return Properti(
      id: json['id'],
      namaProperti: json['nama_properti'],
      alamat: json['alamat'],
      deskripsi: json['deskripsi'],
      pemilikId: json['pemilikId'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}