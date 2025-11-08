// lib/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kosku_app/providers/auth_provider.dart';
import 'package:kosku_app/services/api_service.dart';
import 'package:kosku_app/screens/edit_profile_page.dart';
import 'package:kosku_app/screens/ganti_password_page.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Ganti IP ini sesuai dengan backend Anda
  final String baseUrl = "http://192.168.100.140:5000";

  @override
  void initState() {
    super.initState();
    // Ambil data profil terbaru saat halaman dibuka
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

  // --- DIALOG UNTUK UPLOAD/LIHAT KTP ---
  void _showKtpDialog(BuildContext context, String? fotoKtpPath) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("KTP Saya"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              width: double.infinity,
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

  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer agar UI otomatis update saat data profil dimuat
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        // Tampilkan loading jika data profil sedang dimuat
        if (authProvider.isLoading && authProvider.userProfile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        // Tampilkan info default jika userProfile masih null
        final userNama = authProvider.userProfile?.nama ?? "Pengguna";
        final userEmail =
            authProvider.userProfile?.email ?? "email@loading.com";
        final userInisial = userNama.isNotEmpty
            ? userNama[0].toUpperCase()
            : "?";

        // ===================================
        // ==     LOGIKA PADDING BARU       ==
        // ===================================
        // Tentukan padding berdasarkan peran
        final EdgeInsets listPadding;
        if (authProvider.isAdmin) {
          // Padding untuk Admin (karena ada AppBar di AdminHomeScreen)
          listPadding = const EdgeInsets.all(16);
        } else {
          // Padding untuk Penyewa (User)
          listPadding = const EdgeInsets.fromLTRB(20, 60, 20, 40); 
        }
        // ===================================

        // Hapus Scaffold dari sini
        return ListView(
          padding: listPadding, // <-- Gunakan padding dinamis
          children: [
            // Card di tengah (Data Dinamis)
            Center(
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.infinity, 
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            userInisial, // INSIAL DINAMIS
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        userNama, // NAMA DINAMIS
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail, // EMAIL DINAMIS
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Menu Items (Tombol Fungsional)
            _buildMenuItem(
              context,
              icon: Icons.person_outline,
              title: "Edit Profil",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => const EditProfilePage(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.lock_outline,
              title: "Ganti Password",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (ctx) => const GantiPasswordPage(),
                  ),
                );
              },
            ),
            _buildMenuItem(
              context,
              icon: Icons.credit_card_outlined,
              title: "Upload KTP",
              onTap: () {
                _showKtpDialog(
                  context,
                  authProvider.userProfile?.fotoKtp, // Kirim path KTP
                );
              },
            ),
            const SizedBox(height: 24),

            // Logout Button (Tombol Fungsional)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  "Logout",
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  // Panggil fungsi logout dari provider
                  Provider.of<AuthProvider>(context, listen: false).logout();
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // Widget Helper Anda (sudah sangat bagus)
  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.blue, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}