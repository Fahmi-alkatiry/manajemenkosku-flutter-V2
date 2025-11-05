// lib/screens/admin/detail_kontrak_aktif_page.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/models/kamar.dart';
import 'package:kosku_app/providers/auth_provider.dart';
import 'package:kosku_app/services/api_service.dart';
import 'package:provider/provider.dart';

class DetailKontrakAktifPage extends StatefulWidget {
  final Kamar kamar;

  const DetailKontrakAktifPage({super.key, required this.kamar});

  @override
  State<DetailKontrakAktifPage> createState() => _DetailKontrakAktifPageState();
}

class _DetailKontrakAktifPageState extends State<DetailKontrakAktifPage> {
  bool _isLoading = false;
  final ApiService _apiService = ApiService();

  // Fungsi untuk mengakhiri kontrak
  Future<void> _akhiriKontrak() async {
    // Tampilkan dialog konfirmasi dulu
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Akhiri Sewa?"),
        content: Text("Apakah Anda yakin ingin mengakhiri sewa untuk Kamar ${widget.kamar.nomorKamar}? Status kamar akan kembali menjadi 'Tersedia'."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Ya, Akhiri"),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() { _isLoading = true; });
    try {
      final token = Provider.of<AuthProvider>(context, listen: false).token!;
      // Panggil API untuk ubah status kontrak jadi 'BERAKHIR'
      await _apiService.updateKontrakStatus(token, widget.kamar.kontrakAktifId!, 'BERAKHIR');

      if (!mounted) return;
      Navigator.pop(context, true); // Kembali dengan sinyal 'true' (perlu refresh)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kontrak berhasil diakhiri."), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final kamar = widget.kamar;
    return Scaffold(
      appBar: AppBar(title: Text("Kamar ${kamar.nomorKamar}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Status Saat Ini:", style: TextStyle(color: Colors.grey)),
            const Text("Ditempati", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 20),
            const Text("Penyewa:", style: TextStyle(color: Colors.grey)),
            Text(kamar.namaPenyewa ?? '-', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _akhiriKontrak,
                      icon: const Icon(Icons.exit_to_app),
                      label: const Text("AKHIRI SEWA SEKARANG", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}