// lib/screens/penyewa/penyewa_home_screen.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/providers/auth_provider.dart';
import 'package:kosku_app/screens/penyewa/penyewa_dashboard_page.dart'; // <-- 1. IMPORT DASHBOARD
import 'package:kosku_app/screens/profile_screen.dart'; // <-- 2. IMPORT PROFIL
import 'package:provider/provider.dart';

class PenyewaHomeScreen extends StatefulWidget {
  const PenyewaHomeScreen({super.key});

  @override
  State<PenyewaHomeScreen> createState() => _PenyewaHomeScreenState();
}

class _PenyewaHomeScreenState extends State<PenyewaHomeScreen> {
  int _selectedIndex = 0; // Index untuk halaman yang aktif

  // Daftar halaman/layar untuk Penyewa
  static const List<Widget> _penyewaPages = <Widget>[
    PenyewaDashboardPage(), // 0: Halaman Home (Tagihan/Riwayat)
    ProfileScreen(),        // 1: Halaman Profil
  ];

  // Daftar judul untuk AppBar
  static const List<String> _pageTitles = <String>[
    'Dashboard Saya',
    'Profil Saya',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Judul AppBar akan berubah sesuai tab yang dipilih
        title: Text(_pageTitles[_selectedIndex]),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: _penyewaPages.elementAt(_selectedIndex), // Tampilkan halaman yang dipilih
      
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
      ),
    );
  }
}