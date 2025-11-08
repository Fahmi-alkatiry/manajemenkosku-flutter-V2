// lib/screens/admin/admin_home_screen.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/screens/admin/pages/admin_properti_page.dart';
import 'package:kosku_app/screens/admin/pages/admin_verifikasi_page.dart';
import 'package:kosku_app/screens/admin/pages/admin_penyewa_page.dart'; // <-- 1. IMPORT BARU
import 'package:kosku_app/screens/profile_screen.dart';
import 'package:kosku_app/screens/admin/pages/admin_laporan_page.dart'; // <-- 1. IMPORT
import 'package:kosku_app/screens/admin/pages/admin_dashboard_page.dart'; // <-- 1. IMPORT

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});
  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 0; // Mulai dari Tab "Properti"

  static final List<Widget> _adminPages = <Widget>[
    // 0: Dashboard
    const AdminDashboardPage(), // <-- 2. GANTI PLACEHOLDER
    // 1: Manajemen Properti
    const AdminPropertiPage(),
    // 2: Verifikasi Pembayaran
    const AdminVerifikasiPage(),
    
    // 3: Halaman Penyewa BARU
    const AdminPenyewaPage(), // <-- 2. TAMBAHKAN HALAMAN DI SINI

    // 4: Laporan
    const AdminLaporanPage(), // <-- 2. GANTI PLACEHOLDER
    // 5: Profil
    const ProfileScreen(),

    // 6: Placeholder
    const ProfileScreen(),
  ];

  // Daftar judul untuk AppBar
  static const List<String> _pageTitles = <String>[
    'Dashboard',
    'Manajemen Properti',
    'Verifikasi Pembayaran',
    'Manajemen Penyewa', // <-- JUDUL BARU
    'Laporan',
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
        title: Text(_pageTitles[_selectedIndex]), // Judul dinamis
      ),
      body: _adminPages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        // ===================================
        // ==   UPDATE ITEMS DI SINI (ADA 6)  ==
        // ===================================
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home_work),
            label: 'Properti',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Verifikasi',
          ),
          // --- ITEM BARU ---
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Penyewa',
          ),
          // -----------------
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Laporan',
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
        showUnselectedLabels: true, // Tampilkan label
        type: BottomNavigationBarType.fixed, // WAJIB 'fixed' untuk > 3 item
      ),
    );
  }
}