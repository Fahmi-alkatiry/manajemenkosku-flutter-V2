// lib/providers/user_provider.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/models/user_simple.dart';
import 'package:kosku_app/services/api_service.dart';
import 'package:kosku_app/providers/auth_provider.dart';

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
}