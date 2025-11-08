// lib/providers/kamar_provider.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/models/kamar.dart';
import 'package:kosku_app/services/api_service.dart';
import 'package:kosku_app/providers/auth_provider.dart';

class KamarProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;

  List<Kamar> _kamarItems = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<Kamar> get kamarItems => _kamarItems;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // Constructor untuk menerima token
  KamarProvider(AuthProvider authProvider) {
    _token = authProvider.token;
  }

  // Fungsi untuk mengambil data kamar
  Future<void> fetchKamar(int propertiId) async {
    if (_token == null) {
      _errorMessage = "Sesi Anda berakhir. Silakan login ulang.";
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _kamarItems = await _apiService.getKamarByProperti(_token!, propertiId);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

 Future<bool> tambahKamar({
    required String nomorKamar,
    required String tipe,
    required double harga,
    required int propertiId,
  }) async {
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
        'nomor_kamar': nomorKamar,
        'tipe': tipe,
        'harga': harga,
        'propertiId': propertiId,
        // Status akan di-handle default oleh backend
      };

      final newKamar = await _apiService.createKamar(_token!, data);
      
      // Tambahkan kamar baru ke daftar lokal
      _kamarItems.add(newKamar);
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


  Future<bool> createKontrak({
    required int penyewaId,
    required int kamarId,
    required DateTime tanggalMulai,
    required DateTime tanggalAkhir,
    required double hargaDisepakati,
  }) async {
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
        'penyewaId': penyewaId,
        'kamarId': kamarId,
        'tanggal_mulai_sewa': DateTime.utc(tanggalMulai.year, tanggalMulai.month, tanggalMulai.day).toIso8601String(),
        'tanggal_akhir_sewa': DateTime.utc(tanggalAkhir.year, tanggalAkhir.month, tanggalAkhir.day).toIso8601String(),
        'harga_sewa_disepakati': hargaDisepakati,
      };

      await _apiService.createKontrak(_token!, data);
      
      // Jika sukses, refresh daftar kamar
      // Ambil propertiId dari kamar pertama (asumsi semua kamar di list ini
      // dari properti yg sama, waspada jika list kosong)
      if (_kamarItems.isNotEmpty) {
        await fetchKamar(_kamarItems.first.propertiId);
      }
      
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


  Future<bool> updateKamar(int kamarId, Map<String, dynamic> data) async {
    if (_token == null) return false;
    _isLoading = true;
    notifyListeners();

    try {
      final updatedKamar = await _apiService.updateKamar(_token!, kamarId, data);
      // Update item di list lokal
      final index = _kamarItems.indexWhere((k) => k.id == kamarId);
      if (index != -1) {
        _kamarItems[index] = updatedKamar;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Fungsi Hapus Kamar
  Future<bool> deleteKamar(int kamarId) async {
    if (_token == null) return false;
    // Opsional: bisa tambah loading state khusus delete jika mau
    try {
      await _apiService.deleteKamar(_token!, kamarId);
      // Hapus item dari list lokal
      _kamarItems.removeWhere((k) => k.id == kamarId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}