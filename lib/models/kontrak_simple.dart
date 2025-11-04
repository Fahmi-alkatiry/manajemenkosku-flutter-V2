// lib/models/kontrak_simple.dart
class KontrakSimple {
  final int id;
  // Kita perlu nama penyewa & kamar untuk ditampilkan di dropdown
  final String namaPenyewa; 
  final String nomorKamar;
  final String namaProperti;

  KontrakSimple({
    required this.id,
    required this.namaPenyewa,
    required this.nomorKamar,
    required this.namaProperti,
  });

  // Tampilkan sbg "Kamar 101 - Budi (Kos Mawar)"
  String get displayName => '$nomorKamar - $namaPenyewa ($namaProperti)';

  factory KontrakSimple.fromJson(Map<String, dynamic> json) {
    // Kita asumsikan backend akan mengirim data relasi
    return KontrakSimple(
      id: json['id'],
      namaPenyewa: json['penyewa']?['nama'] ?? 'N/A',
      nomorKamar: json['kamar']?['nomor_kamar'] ?? 'N/A',
      namaProperti: json['kamar']?['properti']?['nama_properti'] ?? 'N/A',
    );
  }
}