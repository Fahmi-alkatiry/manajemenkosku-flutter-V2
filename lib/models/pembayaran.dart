// lib/models/pembayaran.dart
class Pembayaran {
  final int id;
  final String bulan;
  final int tahun;
  final double jumlah;
  final String status; // Pending, Lunas, Ditolak
  final String? buktiPembayaran;
  final int kontrakId;

  // --- TAMBAHKAN FIELD BARU ---
  // Kita asumsikan backend akan mengirim data ini
  // untuk mempermudah tampilan di UI
  final String? penyewaNama;
  final String? kamarNomor;
  // -----------------------------

  Pembayaran({
    required this.id,
    required this.bulan,
    required this.tahun,
    required this.jumlah,
    required this.status,
    this.buktiPembayaran,
    required this.kontrakId,
    // --- TAMBAHKAN DI CONSTRUCTOR ---
    this.penyewaNama,
    this.kamarNomor,
  });

  factory Pembayaran.fromJson(Map<String, dynamic> json) {
    return Pembayaran(
      id: json['id'],
      bulan: json['bulan'],
      tahun: json['tahun'],
      jumlah: (json['jumlah'] as num).toDouble(),
      status: json['status'],
      buktiPembayaran: json['bukti_pembayaran'],
      kontrakId: json['kontrakId'],
      
      // --- AMBIL DATA DARI RELASI (NESTED JSON) ---
      // (Backend Anda harus di-update untuk mengirim 'kontrak.penyewa.nama'
      //  dan 'kontrak.kamar.nomor_kamar' saat memanggil API pembayaran)
      penyewaNama: json['kontrak']?['penyewa']?['nama'] ?? 'N/A',
      kamarNomor: json['kontrak']?['kamar']?['nomor_kamar'] ?? 'N/A',
    );
  }
}