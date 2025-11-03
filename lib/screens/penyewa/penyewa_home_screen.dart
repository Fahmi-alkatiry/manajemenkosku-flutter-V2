// lib/screens/penyewa/penyewa_home_screen.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class PenyewaHomeScreen extends StatelessWidget {
  const PenyewaHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Penyewa'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Provider.of<AuthProvider>(context, listen: false).logout(),
          )
        ],
      ),
      body: const Center(
        child: Text('Selamat Datang, Penyewa!'),
      ),
    );
  }
}