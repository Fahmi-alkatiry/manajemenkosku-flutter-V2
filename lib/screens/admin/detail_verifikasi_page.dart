// lib/screens/admin/detail_verifikasi_page.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/models/pembayaran.dart';
import 'package:kosku_app/providers/pembayaran_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class DetailVerifikasiPage extends StatefulWidget {
  final Pembayaran tagihan; // Terima tagihan yang diklik

  const DetailVerifikasiPage({super.key, required this.tagihan});

  @override
  State<DetailVerifikasiPage> createState() => _DetailVerifikasiPageState();
}

class _DetailVerifikasiPageState extends State<DetailVerifikasiPage> {
  final formatRupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  bool _isLoading = false;

  // Fungsi untuk memproses aksi (Setujui / Tolak)
  Future<void> _prosesVerifikasi(String status) async {
    setState(() { _isLoading = true; });

    final provider = Provider.of<PembayaranProvider>(context, listen: false);
    final success = await provider.konfirmasiPembayaran(widget.tagihan.id, status);

    if (!mounted) return;
    if (success) {
      Navigator.pop(context); // Kembali ke daftar verifikasi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tagihan berhasil diubah ke $status'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage), backgroundColor: Colors.red),
      );
    }
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    final tagihan = widget.tagihan;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Verifikasi"),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildInfoRow("Penyewa:", tagihan.penyewaNama ?? 'N/A'),
                _buildInfoRow("Kamar:", tagihan.kamarNomor ?? 'N/A'),
                _buildInfoRow("Tagihan:", '${tagihan.bulan} ${tagihan.tahun}'),
                _buildInfoRow("Jumlah:", formatRupiah.format(tagihan.jumlah)),
                const Divider(height: 20),
                
                // === Bagian Bukti Pembayaran ===
                const Text("Bukti Pembayaran:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  height: 300,
                  width: double.infinity,
                  child: tagihan.buktiPembayaran == null
                      ? const Center(child: Text("Penyewa belum upload bukti"))
                      : Image.network(
                          // TODO: Gabungkan _baseUrl dengan path bukti
                          // (Kita asumsikan 'buktiPembayaran' adalah path, cth: /uploads/bukti/file.jpg)
                          // Anda perlu _baseUrl dari ApiService di sini
                          "http://192.168.100.140:5000${tagihan.buktiPembayaran}", 
                          fit: BoxFit.contain,
                          loadingBuilder: (ctx, child, progress) {
                            return progress == null ? child : const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder: (ctx, err, stack) {
                            return const Center(child: Text("Gagal memuat gambar", style: TextStyle(color: Colors.red)));
                          },
                        ),
                ),
                const SizedBox(height: 20),

                // === Tombol Aksi ===
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        // Kirim 'Ditolak'
                        onPressed: () => _prosesVerifikasi('Ditolak'),
                        child: const Text("Tolak"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        // Kirim 'Lunas'
                        onPressed: () => _prosesVerifikasi('Lunas'),
                        child: const Text("Setujui (Lunas)"),
                      ),
                    ),
                  ],
                ),
              ],
            ),
    );
  }

  // Widget helper untuk baris info
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}