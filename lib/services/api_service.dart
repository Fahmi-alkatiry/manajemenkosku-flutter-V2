import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:kosku_app/models/properti.dart';

class ApiService {
  // GUNAKAN IP YANG SESUAI DARI LANGKAH 1
  // 192.168.100.140
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
}