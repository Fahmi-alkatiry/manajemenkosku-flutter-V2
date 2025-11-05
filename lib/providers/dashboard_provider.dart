// lib/providers/dashboard_provider.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/models/dashboard_stats.dart';
import 'package:kosku_app/services/api_service.dart';
import 'package:kosku_app/providers/auth_provider.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  String? _token;

  DashboardStats? _stats;
  bool _isLoading = false;
  String _errorMessage = '';

  DashboardStats? get stats => _stats;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  DashboardProvider(AuthProvider authProvider) {
    _token = authProvider.token;
  }

  Future<void> fetchStats() async {
    if (_token == null) return;
    _isLoading = true;
    notifyListeners();
    try {
      _stats = await _apiService.getDashboardStats(_token!);
      _errorMessage = '';
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}