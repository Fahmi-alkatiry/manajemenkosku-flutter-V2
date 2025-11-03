// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/services/api_service.dart';
import 'package:kosku_app/services/storage_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  String? _token;
  String? _role;
  bool _isLoading = false;
  String? _errorMessage;

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
}