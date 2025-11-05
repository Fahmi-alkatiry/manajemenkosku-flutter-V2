// lib/models/user_detail.dart

// Model kecil untuk menampung riwayat kontrak
class KontrakRiwayat {
  final int id;
  final String nomorKamar;
  final DateTime tanggalMulai;
  final DateTime tanggalAkhir;
  final String status;

  KontrakRiwayat({
    required this.id,
    required this.nomorKamar,
    required this.tanggalMulai,
    required this.tanggalAkhir,
    required this.status,
  });

  factory KontrakRiwayat.fromJson(Map<String, dynamic> json) {
    return KontrakRiwayat(
      id: json['id'],
      nomorKamar: json['kamar']?['nomor_kamar'] ?? 'N/A',
      tanggalMulai: DateTime.parse(json['tanggal_mulai_sewa']),
      tanggalAkhir: DateTime.parse(json['tanggal_akhir_sewa']),
      status: json['status_kontrak'],
    );
  }
}

// Model utama untuk data detail user
class UserDetail {
  final int id;
  final String nama;
  final String email;
  final String? noHp;
  final String? alamat;
  final String? nik;
  final String? fotoKtp; // Ini adalah URL path
  final List<KontrakRiwayat> kontrak; // Daftar riwayat kontrak

  UserDetail({
    required this.id,
    required this.nama,
    required this.email,
    this.noHp,
    this.alamat,
    this.nik,
    this.fotoKtp,
    required this.kontrak,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    // Ambil list kontrak dari JSON
    var kontrakList = (json['kontrak'] as List)
        .map((item) => KontrakRiwayat.fromJson(item))
        .toList();

    return UserDetail(
      id: json['id'],
      nama: json['nama'],
      email: json['email'],
      noHp: json['no_hp'],
      alamat: json['alamat'],
      nik: json['nik'],
      fotoKtp: json['foto_ktp'],
      kontrak: kontrakList,
    );
  }
}