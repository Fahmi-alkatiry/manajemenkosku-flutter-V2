// lib/screens/admin/admin_home_screen.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/screens/admin/admin_properti_page.dart';
import 'package:kosku_app/screens/profile_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({super.key});

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  int _selectedIndex = 1; // Mulai dari Tab "Properti" (indeks 1)

  // Daftar halaman sesuai rencana Anda
  static final List<Widget> _adminPages = <Widget>[
    // 0: Dashboard
    const Center(child: Text('1. Dashboard Utama (WIP)')),
    // 1: Manajemen Properti
    const AdminPropertiPage(),
    // 2: Pembuatan Kontrak (Kita skip dulu, krn ini alur)
    // 3: Verifikasi Pembayaran
    const Center(child: Text('4. Verifikasi Pembayaran (WIP)')),
    // 4: Laporan
    const Center(child: Text('6. Laporan (WIP)')),
    // 5: Profil
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _adminPages.elementAt(_selectedIndex), // Tampilkan halaman aktif
      bottomNavigationBar: BottomNavigationBar(
        // Rencana Anda ada 5 tab utama (Kontrak adalah alur, bukan tab)
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
        unselectedItemColor: Colors.grey, // Penting agar label terlihat
        onTap: _onItemTapped,
        showUnselectedLabels: true, // Tampilkan label walau tidak aktif
        type: BottomNavigationBarType.fixed, // Agar 5 item muat
      ),
    );
  }
}