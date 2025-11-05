// lib/models/kamar.dart

class Kamar {
  final int id;
  final String nomorKamar;
  final String tipe;
  final double harga;
  final String status;
  final int propertiId;
  // FIELD BARU (Opsional, hanya ada jika kamar Ditempati)
  final int? kontrakAktifId; 
  final String? namaPenyewa;

  Kamar({
    required this.id,
    required this.nomorKamar,
    required this.tipe,
    required this.harga,
    required this.status,
    required this.propertiId,
    this.kontrakAktifId,
    this.namaPenyewa,
  });

  factory Kamar.fromJson(Map<String, dynamic> json) {
    // Cek apakah ada kontrak aktif di dalam array 'kontrak'
    int? kId;
    String? pNama;
    if (json['kontrak'] != null && (json['kontrak'] as List).isNotEmpty) {
      kId = json['kontrak'][0]['id'];
      pNama = json['kontrak'][0]['penyewa']['nama'];
    }

    return Kamar(
      id: json['id'],
      nomorKamar: json['nomor_kamar'],
      tipe: json['tipe'],
      harga: (json['harga'] as num).toDouble(),
      status: json['status'],
      propertiId: json['propertiId'],
      // Isi field baru
      kontrakAktifId: kId,
      namaPenyewa: pNama,
    );
  }
}