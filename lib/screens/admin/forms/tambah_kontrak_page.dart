// lib/screens/admin/tambah_kontrak_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kosku_app/models/kamar.dart';
import 'package:kosku_app/models/user_simple.dart';
import 'package:kosku_app/providers/kamar_provider.dart';
import 'package:kosku_app/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal

class TambahKontrakPage extends StatefulWidget {
  // Terima data kamar yang akan disewakan
  final Kamar kamar;

  const TambahKontrakPage({super.key, required this.kamar});

  @override
  State<TambahKontrakPage> createState() => _TambahKontrakPageState();
}

class _TambahKontrakPageState extends State<TambahKontrakPage> {
  final _formKey = GlobalKey<FormState>();
  UserSimple? _selectedPenyewa; // Untuk menyimpan penyewa yang dipilih
  final _hargaController = TextEditingController();
  final _tglMulaiController = TextEditingController();
  final _tglAkhirController = TextEditingController();
  bool _isLoading = false;
  DateTime? _tglMulai;
  DateTime? _tglAkhir;

  @override
  void initState() {
    super.initState();
    // Isi harga default dari data kamar
    _hargaController.text = widget.kamar.harga.toStringAsFixed(0);
    // Ambil daftar penyewa saat halaman dibuka
    // 'listen: false' karena ini di initState
    Provider.of<UserProvider>(context, listen: false).fetchPenyewa();
  }

  @override
  void dispose() {
    _hargaController.dispose();
    _tglMulaiController.dispose();
    _tglAkhirController.dispose();
    super.dispose();
  }

  // Fungsi untuk menampilkan date picker
  Future<void> _pilihTanggal(BuildContext context, bool isTanggalMulai) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(
        const Duration(days: 30),
      ), // Bisa mulai dari 30 hari lalu
      lastDate: now.add(const Duration(days: 365 * 2)), // Maks 2 tahun
    );
    if (picked != null) {
      setState(() {
        final formattedDate = DateFormat('dd-MM-yyyy').format(picked);
        if (isTanggalMulai) {
          _tglMulai = picked;
          _tglMulaiController.text = formattedDate;
        } else {
          _tglAkhir = picked;
          _tglAkhirController.text = formattedDate;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return; // Gagal validasi
    if (_selectedPenyewa == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih penyewa'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    setState(() {
      _isLoading = true;
    });

    final provider = Provider.of<KamarProvider>(context, listen: false);
    final success = await provider.createKontrak(
      penyewaId: _selectedPenyewa!.id,
      kamarId: widget.kamar.id,
      tanggalMulai: _tglMulai!,
      tanggalAkhir: _tglAkhir!,
      hargaDisepakati: double.parse(_hargaController.text),
    );

    if (!mounted) return;
    if (success) {
      Navigator.pop(context); // Kembali ke detail properti
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Buat Kontrak Kamar ${widget.kamar.nomorKamar}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Dropdown Pilih Penyewa
              Consumer<UserProvider>(
                builder: (ctx, userProvider, _) {
                  if (userProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return DropdownButtonFormField<UserSimple>(
                    decoration: const InputDecoration(
                      labelText: 'Pilih Penyewa',
                    ),
                    initialValue: _selectedPenyewa, // ✅ pengganti 'value'
                    items: userProvider.penyewaList.map((penyewa) {
                      return DropdownMenuItem(
                        value: penyewa,
                        child: Text(penyewa.nama),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPenyewa = value;
                      });
                    },
                    validator: (val) =>
                        (val == null) ? 'Wajib pilih penyewa' : null,
                  );
                },
              ),
              // Form Tanggal
              TextFormField(
                controller: _tglMulaiController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Mulai Sewa',
                ),
                readOnly: true, // Tidak bisa diketik manual
                onTap: () => _pilihTanggal(context, true),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _tglAkhirController,
                decoration: const InputDecoration(
                  labelText: 'Tanggal Akhir Sewa',
                ),
                readOnly: true,
                onTap: () => _pilihTanggal(context, false),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Wajib diisi' : null,
              ),
              // Form Harga
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(
                  labelText: "Harga Sewa Disepakati",
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text("Simpan Kontrak"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
