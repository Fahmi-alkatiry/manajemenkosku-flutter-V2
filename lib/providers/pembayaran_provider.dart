// lib/providers/pembayaran_provider.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/models/kontrak_simple.dart';
import 'package:kosku_app/models/pembayaran.dart';
import 'package:kosku_app/services/api_service.dart';
import 'package:kosku_app/providers/auth_provider.dart';

class PembayaranProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;

  List<Pembayaran> _pendingPayments = [];
  List<KontrakSimple> _activeContracts = [];
  bool _isLoading = false;
  String _errorMessage = '';

  // Getters
  List<Pembayaran> get pendingPayments => _pendingPayments;
  List<KontrakSimple> get activeContracts => _activeContracts;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  PembayaranProvider(AuthProvider authProvider) {
    _token = authProvider.token;
  }

  // Ambil data untuk Tab Verifikasi
  Future<void> fetchPendingPayments() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      _pendingPayments = await _apiService.getPendingPayments(_token!);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Ambil data untuk Form Tambah Tagihan
  Future<void> fetchActiveContracts() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      _activeContracts = await _apiService.getAllActiveContracts(_token!);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Fungsi untuk submit tagihan baru
  Future<bool> createTagihan({
    required int kontrakId,
    required String bulan,
    required int tahun,
  }) async {
    if (_token == null) return false;
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      final data = {'kontrakId': kontrakId, 'bulan': bulan, 'tahun': tahun};
      final newPayment = await _apiService.createTagihan(_token!, data);

      // Tambahkan ke daftar pending jika statusnya pending
      if (newPayment.status == 'Pending') {
        _pendingPayments.add(newPayment);
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

  Future<bool> konfirmasiPembayaran(int pembayaranId, String status) async {
    if (_token == null) {
      _errorMessage = "Sesi Anda berakhir. Silakan login ulang.";
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      await _apiService.konfirmasiPembayaran(_token!, pembayaranId, status);

      // Jika sukses, hapus tagihan dari daftar 'pending'
      _pendingPayments.removeWhere((payment) => payment.id == pembayaranId);

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
