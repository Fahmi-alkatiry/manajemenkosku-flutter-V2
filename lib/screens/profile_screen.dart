// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:kosku_app/screens/edit_profile_page.dart'; // <-- 1. IMPORT
import 'package:kosku_app/screens/ganti_password_page.dart'; // <-- 1. IMPORT BARU

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit Profil"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const EditProfilePage()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Ganti Password"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const GantiPasswordPage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Logout"),
            onTap: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
              // 'main.dart' akan otomatis kembali ke LoginScreen
            },
          ),
        ],
      ),
    );
  }
}