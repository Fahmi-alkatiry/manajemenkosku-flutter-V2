// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/models/user_simple.dart';
import 'package:kosku_app/services/api_service.dart';
import 'package:kosku_app/providers/auth_provider.dart';
import 'package:kosku_app/models/user_detail.dart'; // <-- 1. IMPORT BARU

class UserProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;

  List<UserSimple> _penyewaList = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<UserSimple> get penyewaList => _penyewaList;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  UserProvider(AuthProvider authProvider) {
    _token = authProvider.token;
  }

  UserDetail? _selectedUserDetail;
  bool _isLoadingDetail = false;

  UserDetail? get selectedUserDetail => _selectedUserDetail;
  bool get isLoadingDetail => _isLoadingDetail;

  // Ambil daftar penyewa
  Future<void> fetchPenyewa() async {
    if (_token == null) return; // Jangan lakukan apa-apa jika tidak ada token

    _isLoading = true;
    notifyListeners();
    try {
      _penyewaList = await _apiService.getUsersByRole(_token!, 'PENYEWA');
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  Future<bool> tambahPenyewa({
    required String nama,
    required String email,
    required String password,
    String? noHp,
  }) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final Map<String, dynamic> data = {
        'nama': nama,
        'email': email,
        'password': password,
        'no_hp': noHp,
      };

      // Panggil service (public endpoint)
      final newUser = await _apiService.registerPenyewa(data);
      
      // Tambahkan user baru ke daftar lokal agar UI refresh
      _penyewaList.add(newUser);
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
Future<void> fetchUserDetail(int userId) async {
    if (_token == null) return;

    _isLoadingDetail = true;
    _errorMessage = '';
    notifyListeners();
    try {
      _selectedUserDetail = await _apiService.getUserDetail(_token!, userId);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  // Fungsi untuk membersihkan detail saat halaman ditutup
  void clearSelectedUser() {
    _selectedUserDetail = null;
  }
}