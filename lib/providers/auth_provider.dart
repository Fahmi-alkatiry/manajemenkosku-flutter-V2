// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/services/api_service.dart';
import 'package:kosku_app/services/storage_service.dart';

class UserProfile {
  final String nama;
  final String email;
  final String? noHp;
  final String? alamat;

  final String? fotoKtp; // TAMBAHKAN INI

  UserProfile({
    required this.nama,
    required this.email,
    this.noHp,
    this.alamat,
    this.fotoKtp
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      nama: json['nama'],
      email: json['email'],
      noHp: json['no_hp'],
      alamat: json['alamat'],
      fotoKtp: json['foto_ktp'], // TAMBAHKAN INI
      
    );
  }
}


class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  String? _token;
  String? _role;
  bool _isLoading = false;
  String? _errorMessage;

  UserProfile? _userProfile; // <-- STATE BARU UNTUK DATA PROFIL
  UserProfile? get userProfile => _userProfile; // <-- GETTER BARU

  // Getters
  String? get token => _token;
  String? get role => _role;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuth => _token != null;
  bool get isAdmin => _role == 'ADMIN';

  // Fungsi internal untuk loading
  void _startLoading() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
  }

  void _stopLoading() {
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _startLoading();
    try {
      // loginData adalah Map
      final loginData = await _apiService.login(email, password);

      // Ekstrak data dari Map
      _token = loginData['token'];
      _role = loginData['user']['role'];

      // Simpan string ke storage
      await _storageService.saveToken(_token!);
      await _storageService.saveRole(_role!);

      _stopLoading();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _stopLoading();
      return false;
    }
  }

  Future<void> tryAutoLogin() async {
    final token = await _storageService.getToken();
    final role = await _storageService.getRole();
    if (token != null && role != null) {
      _token = token;
      _role = role;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _role = null;
    await _storageService.deleteToken();
    await _storageService.deleteRole();
    notifyListeners();
  }

 Future<void> fetchMyProfile() async {
    if (_token == null) return;
    
    // Cegah fetch berulang jika data sudah ada
    // if (_userProfile != null) return; 

    _isLoading = true;
    notifyListeners();
    try {
      // Panggil ApiService.getMyProfile()
      final profileData = await _apiService.getMyProfile(_token!);
      
      // Simpan data ke state
      _userProfile = UserProfile.fromJson(profileData); 
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Update data profil
  Future<bool> updateProfile(String nama, String noHp, String alamat) async {
    if (_token == null) {
      _errorMessage = "Sesi Anda berakhir. Silakan login ulang.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final Map<String, dynamic> data = {
        'nama': nama,
        'no_hp': noHp,
        'alamat': alamat,
      };

      await _apiService.updateMyProfile(_token!, data);

      // Update data profil lokal (opsional tapi bagus)
      _userProfile = UserProfile(
        nama: nama,
        email: _userProfile?.email ?? '', // Ambil email lama
        noHp: noHp,
        alamat: alamat,
      );

      _isLoading = false;
      notifyListeners();
      return true; // Sukses

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false; // Gagal
    }
  }


  Future<bool> changePassword(String newPassword) async {
    if (_token == null) {
      _errorMessage = "Sesi Anda berakhir. Silakan login ulang.";
      notifyListeners();
      return false;
    }

    _isLoading = true; // Kita bisa gunakan state loading yang sama
    _errorMessage = '';
    notifyListeners();

    try {
      // Panggil service baru
      await _apiService.changeMyPassword(_token!, newPassword);
      
      _isLoading = false;
      notifyListeners();
      return true; // Sukses

    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false; // Gagal
    }
  }

}
