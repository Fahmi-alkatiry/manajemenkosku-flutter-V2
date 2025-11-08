// lib/providers/pembayaran_provider.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/models/kontrak_simple.dart';
import 'package:kosku_app/models/pembayaran.dart';
import 'package:kosku_app/services/api_service.dart';
import 'package:kosku_app/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';

class PembayaranProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;

  List<Pembayaran> _pendingPayments = []; // Untuk Admin Verifikasi
  List<KontrakSimple> _activeContracts = []; // Untuk Admin Form Tagihan
  List<Pembayaran> _myPayments = []; // Untuk Penyewa Home
  List<Pembayaran> _reportPayments = []; // Untuk Admin Laporan
  
  bool _isLoading = false;
  String _errorMessage = '';

  // === GETTERS ===

  // Getter untuk Admin
  List<Pembayaran> get pendingPayments => _pendingPayments;
  List<KontrakSimple> get activeContracts => _activeContracts;
  List<Pembayaran> get reportPayments => _reportPayments;
  
  // Getter untuk Penyewa
  List<Pembayaran> get myPayments => _myPayments;
  List<Pembayaran> get tagihanAktifList {
    return _myPayments.where((p) => p.status == 'Pending').toList();
  }
  List<Pembayaran> get riwayatPembayaran {
    return _myPayments.where((p) => p.status != 'Pending').toList();
  }
  
  // Getter Status
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  // === CONSTRUCTOR ===

  PembayaranProvider(AuthProvider authProvider) {
    _token = authProvider.token;
  }

  // === FUNGSI-FUNGSI ===

  // --- Untuk Admin ---

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

      if (newPayment.status == 'Pending') {
        _pendingPayments.add(newPayment);
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

  Future<bool> konfirmasiPembayaran(int pembayaranId, String status) async {
    if (_token == null) return false;
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      await _apiService.konfirmasiPembayaran(_token!, pembayaranId, status);
      _pendingPayments.removeWhere((payment) => payment.id == pembayaranId);
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
  
  Future<void> fetchReportPayments({String? status}) async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      _reportPayments = await _apiService.getPayments(_token!, status: status);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- Untuk Penyewa ---

  Future<void> fetchMyPayments() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      _myPayments = await _apiService.getMyPayments(_token!);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> uploadBukti(int pembayaranId, XFile imageFile) async {
    if (_token == null) return false;
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();
    try {
      await _apiService.uploadBuktiPembayaran(_token!, pembayaranId, imageFile);
      // Panggil ulang fetchMyPayments untuk refresh data
      await fetchMyPayments(); 
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
}