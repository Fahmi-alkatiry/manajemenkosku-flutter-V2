// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // <-- IMPORT
import 'package:kosku_app/providers/auth_provider.dart';
import 'package:kosku_app/services/api_service.dart'; // <-- IMPORT
import 'package:kosku_app/screens/edit_profile_page.dart';
import 'package:kosku_app/screens/ganti_password_page.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  @override
  void initState() {
    super.initState();
    // Panggil fetchMyProfile saat halaman dibuka agar data terisi
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchMyProfile();
    });
  }
  // --- FUNGSI UPLOAD KTP SENDIRI ---
  Future<void> _uploadMyKtp(BuildContext context) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Mengupload KTP Anda...")));

      try {
        final token = Provider.of<AuthProvider>(context, listen: false).token!;
        // Panggil API TANPA targetUserId (default ke diri sendiri)
        await ApiService().uploadKtp(token, image);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("KTP berhasil diupload!"),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh data profil
        Provider.of<AuthProvider>(context, listen: false).fetchMyProfile();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    debugPrint(authProvider.userProfile.toString());
    // Base URL untuk menampilkan gambar KTP (jika sudah ada)
    const String baseUrl = "http://192.168.100.140:5000";


    // Tampilkan loading jika data profil belum siap
    if (authProvider.isLoading && authProvider.userProfile == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      // ... (AppBar opsional, tergantung shell)
      body: ListView(
        children: [
          // --- TAMPILAN INFO USER ---
          if (authProvider.userProfile != null) ...[
            const SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 40,
                child: Text(
                  authProvider.userProfile!.nama[0],
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                authProvider.userProfile!.nama,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Center(
              child: Text(
                authProvider.userProfile!.email,
                style: const TextStyle(color: Colors.grey),
              ),
            ),
            const Divider(height: 30),
          ],

          // --- MENU ---
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text("Edit Data Profil"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (ctx) => const EditProfilePage()),
              );
            },
          ),
          // == MENU BARU: UPLOAD KTP ==
          ListTile(
            leading: const Icon(Icons.credit_card),
            title: const Text("Upload / Lihat KTP Saya"),
            onTap: () {
              _showKtpDialog(
                context,
                authProvider.userProfile?.fotoKtp,
                baseUrl,
              );
              debugPrint("$baseUrl, ${authProvider.userProfile?.fotoKtp}");
            },
          ),
          // ===========================
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
            },
          ),
        ],
      ),
    );
  }

  // Dialog untuk melihat/upload KTP
  void _showKtpDialog(
    BuildContext context,
    String? fotoKtpPath,
    String baseUrl,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("KTP Saya"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              width: double.maxFinite,
              decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
              child: fotoKtpPath == null
                  ? const Center(child: Text("Belum ada KTP"))
                  : Image.network(
                      "$baseUrl$fotoKtpPath",
                      fit: BoxFit.contain,
                      errorBuilder: (c, e, s) =>
                          const Center(child: Text("Gagal memuat gambar")),
                    ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(ctx); // Tutup dialog dulu
                _uploadMyKtp(context); // Mulai proses upload
              },
              icon: const Icon(Icons.upload),
              label: const Text("Upload KTP Baru"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Tutup"),
          ),
        ],
      ),
    );
  }
}
