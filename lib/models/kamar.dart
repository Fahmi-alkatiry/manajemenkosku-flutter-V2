// lib/models/kamar.dart

class Kamar {
  final int id;
  final String nomorKamar;
  final String tipe;
  final double harga;
  final String status; // Tersedia, Ditempati, Diperbaiki
  final int propertiId;

  Kamar({
    required this.id,
    required this.nomorKamar,
    required this.tipe,
    required this.harga,
    required this.status,
    required this.propertiId,
  });

  factory Kamar.fromJson(Map<String, dynamic> json) {
    return Kamar(
      id: json['id'],
      nomorKamar: json['nomor_kamar'],
      tipe: json['tipe'],
      // Backend mengirim 'Float', kita ubah jadi double
      harga: (json['harga'] as num).toDouble(), 
      status: json['status'],
      propertiId: json['propertiId'],
    );
  }
}