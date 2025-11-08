// lib/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kosku_app/models/properti.dart';
import 'package:kosku_app/models/kamar.dart'; 
import 'package:kosku_app/models/user_simple.dart'; // <-- 1. IMPORT BARU
import 'package:kosku_app/models/pembayaran.dart';
import 'package:kosku_app/models/kontrak_simple.dart';
import 'package:image_picker/image_picker.dart'; // <-- 1. IMPORT BARU
import 'package:http_parser/http_parser.dart'; // <-- 2. IMPORT BARU
import 'package:kosku_app/models/user_detail.dart';
import 'package:kosku_app/models/dashboard_stats.dart'; // <-- IMPORT BARU

class ApiService {
  // GUNAKAN IP YANG SESUAI DARI LANGKAH 1
  // 192.168.100.140
  // 192.168.2.119
  //192.168.1.21
  final String _baseUrl = "http://192.168.100.140:5000/api";

 // Fungsi login mengembalikan Map (token + data user)
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8', // Perbaikan UTF-8
      },
      body: jsonEncode(<String, String>{
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data; // Kembalikan semua data
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Gagal login.');
    }
  }

  Future<UserSimple> registerPenyewa(Map<String, dynamic> data) async {
    
    // Pastikan data role dikirim sebagai PENYEWA
    data['role'] = 'PENYEWA';

    final response = await http.post(
      Uri.parse('$_baseUrl/auth/register'), // Panggil endpoint register PUBLIK
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.body.isEmpty) {
      throw Exception('Gagal mendaftar: Respons server kosong (Status: ${response.statusCode})');
    }
    
    final responseData = jsonDecode(response.body);

    if (response.statusCode == 201) {
      // Backend mengembalikan 'data' user yang baru
      return UserSimple.fromJson(responseData['data']);
    } else {
      // Tangkap error (misal: email sudah terdaftar)
      throw Exception(responseData['message'] ?? 'Gagal mendaftarkan penyewa');
    }
  }

 // 1. Mengambil DAFTAR properti
  Future<List<Properti>> getProperti(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/properti'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // <-- Wajib ada token
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Properti.fromJson(data)).toList();
    } else {
      throw Exception('Gagal memuat daftar properti');
    }
  }

  // 2. Membuat properti BARU
  Future<Properti> createProperti(
      String token, String nama, String alamat, String? deskripsi) async {
    
    final response = await http.post(
      Uri.parse('$_baseUrl/properti'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // <-- Wajib ada token
      },
      body: jsonEncode(<String, String?>{
        'nama_properti': nama,
        'alamat': alamat,
        'deskripsi': deskripsi,
      }),
    );

    if (response.body.isEmpty) {
      throw Exception('Gagal: Server tidak merespons (Status: ${response.statusCode})');
    }
    
    final data = jsonDecode(response.body);

    if (response.statusCode == 201) { // 201 = Created
      return Properti.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Gagal membuat properti.');
    }
  }


  Future<List<Kamar>> getKamarByProperti(String token, int propertiId) async {
    final response = await http.get(
      // Panggil endpoint kamar berdasarkan propertiId
      Uri.parse('$_baseUrl/kamar/properti/$propertiId'), 
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token', // <-- Wajib ada token
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Kamar.fromJson(data)).toList();
    } else {
      throw Exception('Gagal memuat daftar kamar');
    }
  }


  Future<Kamar> createKamar(
      String token, Map<String, dynamic> kamarData) async {
    
    final response = await http.post(
      Uri.parse('$_baseUrl/kamar'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(kamarData),
    );

    if (response.body.isEmpty) {
      throw Exception('Gagal: Server tidak merespons (Status: ${response.statusCode})');
    }

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) { // 201 = Created
      return Kamar.fromJson(data);
    } else {
      throw Exception(data['message'] ?? 'Gagal membuat kamar.');
    }
  }

  Future<List<UserSimple>> getUsersByRole(String token, String role) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user?role=$role'), // Panggil endpoint user
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => UserSimple.fromJson(data)).toList();
    } else {
      throw Exception('Gagal memuat daftar pengguna');
    }
  }

  // 2. Membuat kontrak baru
  Future<void> createKontrak(
      String token, Map<String, dynamic> data) async {
    
    final response = await http.post(
      Uri.parse('$_baseUrl/kontrak'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 201) { // 201 = Created
      // Tangani error jika gagal
      if (response.body.isNotEmpty) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Gagal membuat kontrak.');
      } else {
        throw Exception('Gagal membuat kontrak (Status: ${response.statusCode})');
      }
    }
    // Jika sukses (201), tidak perlu mengembalikan apa-apa
  }

  // 1. API UNTUK FORM: Ambil semua kontrak aktif
  // (ASUMSI backend punya endpoint: GET /api/kontrak?status=AKTIF)
  Future<List<KontrakSimple>> getAllActiveContracts(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/kontrak?status=AKTIF'), // Endpoint baru
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => KontrakSimple.fromJson(data)).toList();
    } else {
      throw Exception('Gagal memuat daftar kontrak');
    }
  }

  // 2. API UNTUK FORM: Buat tagihan baru
  Future<Pembayaran> createTagihan(String token, Map<String, dynamic> data) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/pembayaran'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );
    if (response.statusCode == 201) {
      return Pembayaran.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Gagal membuat tagihan');
    }
  }

  // 3. API UNTUK TAB VERIFIKASI: Ambil tagihan pending
  // (ASUMSI backend punya endpoint: GET /api/pembayaran?status=Pending)
  Future<List<Pembayaran>> getPendingPayments(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/pembayaran?status=Pending'), // Endpoint baru
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Pembayaran.fromJson(data)).toList();
    } else {
      throw Exception('Gagal memuat tagihan pending');
    }
  }


  Future<Pembayaran> konfirmasiPembayaran(
      String token, int pembayaranId, String status) async {
    
    final response = await http.put(
      Uri.parse('$_baseUrl/pembayaran/konfirmasi/$pembayaranId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'status': status, // Kirim 'Lunas' atau 'Ditolak'
      }),
    );

    if (response.statusCode == 200) {
      return Pembayaran.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Gagal konfirmasi pembayaran');
    }
  }


  Future<List<Pembayaran>> getMyPayments(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/pembayaran/saya'), // Endpoint /saya
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      // Model Pembayaran kita sudah di-setup untuk mengambil data relasi
      return jsonData.map((data) => Pembayaran.fromJson(data)).toList();
    } else {
      throw Exception('Gagal memuat riwayat pembayaran');
    }
  }

  // ===================================
  // ==  API BARU UNTUK UPLOAD BUKTI  ==
  // ===================================

  Future<void> uploadBuktiPembayaran(String token, int pembayaranId, XFile imageFile) async {
    
    // Siapkan request multipart
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/upload/bukti/$pembayaranId'), // Panggil endpoint upload
    );

    // Tambahkan token ke header
    request.headers['Authorization'] = 'Bearer $token';

    // Tambahkan file gambar ke request
    request.files.add(
      await http.MultipartFile.fromPath(
        'bukti_pembayaran', // Ini adalah NAMA FIELD di backend (Multer)
        imageFile.path,
        contentType: MediaType('image', imageFile.path.split('.').last), // Cth: 'image/jpeg'
      ),
    );

    // Kirim request
    var response = await request.send();

    // Cek status respons
    if (response.statusCode != 200) {
      // Coba baca pesan error jika ada
      final respBody = await response.stream.bytesToString();
      try {
        final errorData = jsonDecode(respBody);
        throw Exception(errorData['message'] ?? 'Gagal upload bukti');
      } catch (e) {
        throw Exception('Gagal upload bukti (Status: ${response.statusCode})');
      }
    }
    // Jika sukses (200), selesai.
  }
Future<Map<String, dynamic>> updateMyProfile(String token, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/user/me'), // Endpoint PUT /user/me
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      // Backend mengembalikan { message: "...", data: {...} }
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Gagal update profil');
    }
  }
Future<Map<String, dynamic>> getMyProfile(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user/me'), // Endpoint GET /user/me
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      // Backend mengembalikan data user (sudah tanpa password)
      return jsonDecode(response.body);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Gagal mengambil profil');
    }
  }

  Future<void> changeMyPassword(String token, String newPassword) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/user/me'), // Endpoint PUT /user/me
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      // Backend kita (di controller user) sudah di-setup
      // untuk menerima 'password' dan meng-hash-nya.
      body: jsonEncode(<String, String>{
        'password': newPassword,
      }),
    );

    if (response.statusCode != 200) {
      // Tangani jika gagal
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Gagal ganti password');
    }
    // Jika 200 OK, sukses
  }


  Future<UserDetail> getUserDetail(String token, int userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/user/$userId'), // Panggil endpoint /api/user/:id
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return UserDetail.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Gagal mengambil detail user');
    }
  }



// 4. API UNTUK LAPORAN: Ambil pembayaran dengan filter status (opsional)
  Future<List<Pembayaran>> getPayments(String token, {String? status}) async {
    // Jika status null, ambil semua. Jika ada, tambahkan ?status=...
    String url = '$_baseUrl/pembayaran';
    if (status != null) {
      url += '?status=$status';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );
    if (response.statusCode == 200) {
      List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((data) => Pembayaran.fromJson(data)).toList();
    } else {
      throw Exception('Gagal memuat data pembayaran');
    }
  }

  Future<DashboardStats> getDashboardStats(String token) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/dashboard/stats'), // Endpoint baru
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      return DashboardStats.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Gagal memuat statistik dashboard');
    }
  }


  Future<void> updateKontrakStatus(String token, int kontrakId, String status) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/kontrak/status/$kontrakId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode({'status_kontrak': status}),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Gagal update status kontrak');
    }
  }
  
Future<void> uploadKtp(String token, XFile imageFile, {int? targetUserId}) async {
    // Jika targetUserId diisi, gunakan endpoint Admin. Jika null, gunakan endpoint biasa.
    final String endpoint = targetUserId != null
        ? '/upload/ktp/$targetUserId' // Endpoint Admin
        : '/upload/ktp';              // Endpoint User Sendiri

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl$endpoint'),
    );

    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(
      await http.MultipartFile.fromPath(
        'foto_ktp', // Sesuai nama field di middleware Multer backend
        imageFile.path,
        contentType: MediaType('image', imageFile.path.split('.').last),
      ),
    );

    var response = await request.send();

    if (response.statusCode != 200) {
      final respBody = await response.stream.bytesToString();
      throw Exception('Gagal upload KTP: $respBody');
    }
  }

  Future<Kamar> updateKamar(String token, int kamarId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/kamar/$kamarId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return Kamar.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Gagal update kamar');
    }
  }

  // Hapus kamar
  Future<void> deleteKamar(String token, int kamarId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/kamar/$kamarId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Gagal menghapus kamar');
    }
  }


  Future<Properti> updateProperti(String token, int propertiId, Map<String, dynamic> data) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/properti/$propertiId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      return Properti.fromJson(jsonDecode(response.body));
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Gagal update properti');
    }
  }

  // Hapus Properti
  Future<void> deleteProperti(String token, int propertiId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/properti/$propertiId'),
      headers: <String, String>{
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      // Error umum: tidak bisa hapus properti yg masih punya kamar/kontrak
      throw Exception(error['message'] ?? 'Gagal menghapus properti');
    }
  }
}