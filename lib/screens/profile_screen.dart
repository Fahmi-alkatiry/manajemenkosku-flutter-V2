// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profil Saya"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit Profil"),
            onTap: () {
              // TODO: Navigasi ke halaman Edit Profil
            },
          ),
          ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Ganti Password"),
            onTap: () {
              // TODO: Navigasi ke halaman Ganti Password
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