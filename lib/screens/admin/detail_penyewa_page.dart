// lib/screens/admin/detail_penyewa_page.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/models/user_simple.dart';
import 'package:kosku_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:kosku_app/models/user_detail.dart';
import 'package:image_picker/image_picker.dart'; // <-- IMPORT INI
import 'package:kosku_app/services/api_service.dart'; // <-- IMPORT INI
import 'package:kosku_app/providers/auth_provider.dart'; // <-- IMPORT INI

class DetailPenyewaPage extends StatefulWidget {
  final UserSimple penyewa; // Terima data simpel dari halaman daftar

  const DetailPenyewaPage({super.key, required this.penyewa});

  @override
  State<DetailPenyewaPage> createState() => _DetailPenyewaPageState();
}

class _DetailPenyewaPageState extends State<DetailPenyewaPage> {
  // Ganti IP ini sesuai IP backend Anda
  final String _baseUrl = "http://192.168.100.140:5000"; 


  Future<void> _adminUploadKtp() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Mengupload KTP...")));
      
      try {
        final token = Provider.of<AuthProvider>(context, listen: false).token!;
        // Panggil API dengan targetUserId
        await ApiService().uploadKtp(token, image, targetUserId: widget.penyewa.id);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("KTP Berhasil diupload!"), backgroundColor: Colors.green));
        // Refresh data halaman ini
        Provider.of<UserProvider>(context, listen: false).fetchUserDetail(widget.penyewa.id);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Panggil provider untuk ambil data lengkap
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserProvider>(context, listen: false)
          .fetchUserDetail(widget.penyewa.id);
    });
  }

  @override
  void dispose() {
    // Bersihkan data detail saat halaman ditutup
    Provider.of<UserProvider>(context, listen: false).clearSelectedUser();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.penyewa.nama), // Judul dari data simpel
      ),
      body: Consumer<UserProvider>(
        builder: (ctx, provider, _) {
          if (provider.isLoadingDetail || provider.selectedUserDetail == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage.isNotEmpty) {
            return Center(child: Text(provider.errorMessage));
          }

          final user = provider.selectedUserDetail!;
          
          return ListView(
            padding: const EdgeInsets.all(16.0),
           children: [
              // === Info Kontak ===
              Text("Informasi Kontak", style: Theme.of(context).textTheme.titleLarge),
              _buildInfoRow("Email:", user.email),
              _buildInfoRow("No. HP:", user.noHp ?? '-'),
              _buildInfoRow("Alamat:", user.alamat ?? '-'),
              const Divider(height: 20),

              // === Info KTP ===
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Data KTP", style: Theme.of(context).textTheme.titleLarge),
                  // TOMBOL UPLOAD UNTUK ADMIN
                  TextButton.icon(
                    onPressed: _adminUploadKtp,
                    icon: const Icon(Icons.upload_file),
                    label: const Text("Upload KTP"),
                  ),
                ],
              ),
              // --- BAGIAN INI HILANG DI KODE ANDA ---
              _buildInfoRow("NIK:", user.nik ?? '-'),
              const SizedBox(height: 10),
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(border: Border.all(color: Colors.grey)),
                child: user.fotoKtp == null
                    ? const Center(child: Text("Foto KTP belum di-upload"))
                    : Image.network(
                        "$_baseUrl${user.fotoKtp}",
                        fit: BoxFit.contain,
                        errorBuilder: (c, e, s) => const Center(child: Text("Gagal memuat KTP")),
                      ),
              ),
              // --------------------------------------
              const Divider(height: 20),

              // === Riwayat Kontrak ===
              Text("Riwayat Kontrak", style: Theme.of(context).textTheme.titleLarge),
              if (user.kontrak.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Text("Belum ada riwayat kontrak."),
                )
              else
                ...user.kontrak.map((k) => _buildKontrakTile(k)).toList(),
            ],
          );
        },
      ),
    );
  }

  // Helper untuk baris info
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: Colors.grey))),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }

  // Helper untuk tile riwayat kontrak
  Widget _buildKontrakTile(KontrakRiwayat kontrak) {
    final formatTgl = DateFormat('dd MMM yyyy');
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      child: ListTile(
        title: Text("Kamar ${kontrak.nomorKamar}"),
        subtitle: Text(
            "${formatTgl.format(kontrak.tanggalMulai)} - ${formatTgl.format(kontrak.tanggalAkhir)}"),
        trailing: Chip(
          label: Text(kontrak.status, style: const TextStyle(fontSize: 12)),
          backgroundColor: kontrak.status == 'AKTIF' ? Colors.green[100] : Colors.grey[200],
        ),
      ),
    );
  }
}