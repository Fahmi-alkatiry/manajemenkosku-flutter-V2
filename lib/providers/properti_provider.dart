// lib/providers/properti_provider.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/models/properti.dart';
import 'package:kosku_app/services/api_service.dart';
import 'package:kosku_app/providers/auth_provider.dart';

class PropertiProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token; // Token didapat dari AuthProvider

  List<Properti> _items = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<Properti> get items => _items;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Constructor untuk menerima token dari AuthProvider
  PropertiProvider(AuthProvider authProvider) {
    _token = authProvider.token;
  }

  // Fungsi untuk mengambil data properti
  Future<void> fetchProperti() async {
    if (_token == null) {
      _errorMessage = "Sesi Anda berakhir. Silakan login ulang.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _items = await _apiService.getProperti(_token!);
      _errorMessage = ''; // Hapus error jika sukses
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi untuk menambah properti
  Future<bool> tambahProperti(String nama, String alamat, String? deskripsi) async {
    if (_token == null) {
      _errorMessage = "Sesi Anda berakhir. Silakan login ulang.";
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final newProperti = await _apiService.createProperti(_token!, nama, alamat, deskripsi);
      _items.add(newProperti); // Tambahkan ke list jika sukses
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