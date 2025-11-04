// lib/screens/penyewa/pembayaran_page.dart
import 'dart:io'; // Untuk menampilkan File
import 'package:flutter/material.dart';
import 'package:kosku_app/models/pembayaran.dart';
import 'package:kosku_app/providers/pembayaran_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class PembayaranPage extends StatefulWidget {
  final Pembayaran tagihan; // Terima tagihan yang akan dibayar

  const PembayaranPage({super.key, required this.tagihan});

  @override
  State<PembayaranPage> createState() => _PembayaranPageState();
}

class _PembayaranPageState extends State<PembayaranPage> {
  final formatRupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  XFile? _selectedImage; // Menyimpan file gambar yang dipilih
  bool _isLoading = false;

  // Fungsi untuk memilih gambar
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  // Fungsi untuk upload bukti
  Future<void> _submitUpload() async {
    if (_selectedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih gambar bukti transfer'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() { _isLoading = true; });
    final provider = Provider.of<PembayaranProvider>(context, listen: false);
    
    final success = await provider.uploadBukti(widget.tagihan.id, _selectedImage!);

    if (!mounted) return;
    if (success) {
      Navigator.pop(context); // Kembali ke home
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bukti berhasil di-upload! Menunggu konfirmasi.'), backgroundColor: Colors.green),
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
    
    // --- INFO REKENING BANK (HARDCODE) ---
    const String noRekening = "123-456-7890";
    const String namaBank = "Bank Central Asia (BCA)";
    const String atasNama = "Admin Kosku";
    // ----------------------------------------

    return Scaffold(
      appBar: AppBar(
        title: Text("Bayar Tagihan ${tagihan.bulan}"),
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // 1. Info Tagihan
                Text(
                  formatRupiah.format(tagihan.jumlah),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                Text(
                  "Tagihan untuk ${tagihan.bulan} ${tagihan.tahun}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const Divider(height: 30),

                // 2. Info Rekening Tujuan (Hardcode)
                const Text("Silakan transfer ke rekening berikut:", style: TextStyle(fontWeight: FontWeight.bold)),
                _buildInfoRekening(namaBank, noRekening, atasNama),
                const Divider(height: 30),
                
                // 3. Tombol Pilih Gambar
                Center(
                  child: OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text("Pilih Bukti Transfer"),
                  ),
                ),
                const SizedBox(height: 10),

                // 4. Preview Gambar yang Dipilih
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _selectedImage == null
                      ? const Center(child: Text("Belum ada gambar dipilih"))
                      : Image.file(
                          File(_selectedImage!.path), // Tampilkan gambar dari file
                          fit: BoxFit.contain,
                        ),
                ),
                const SizedBox(height: 20),
                
                // 5. Tombol Upload
                ElevatedButton(
                  onPressed: (_selectedImage == null) ? null : _submitUpload, // Disable jika tdk ada gambar
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text("Upload Bukti Pembayaran"),
                ),
              ],
            ),
    );
  }

  // Widget helper info rekening
  Widget _buildInfoRekening(String bank, String no, String nama) {
    return Card(
      elevation: 0,
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            _buildInfoRow("Bank:", bank),
            _buildInfoRow("No. Rekening:", no),
            _buildInfoRow("Atas Nama:", nama),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}