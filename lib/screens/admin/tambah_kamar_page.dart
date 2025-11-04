// lib/screens/admin/tambah_kamar_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kosku_app/providers/kamar_provider.dart';
import 'package:provider/provider.dart';

class TambahKamarPage extends StatefulWidget {
  // Kita butuh ID properti agar tahu kamar ini milik siapa
  final int propertiId;

  const TambahKamarPage({super.key, required this.propertiId});

  @override
  State<TambahKamarPage> createState() => _TambahKamarPageState();
}

class _TambahKamarPageState extends State<TambahKamarPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomorController = TextEditingController();
  final _tipeController = TextEditingController();
  final _hargaController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nomorController.dispose();
    _tipeController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return; // Validasi gagal
    }
    setState(() { _isLoading = true; });

    final provider = Provider.of<KamarProvider>(context, listen: false);
    
    final success = await provider.tambahKamar(
      nomorKamar: _nomorController.text,
      tipe: _tipeController.text,
      harga: double.tryParse(_hargaController.text) ?? 0.0,
      propertiId: widget.propertiId, // Ambil dari widget
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context); // Kembali ke halaman detail
    } else {
      // Tampilkan error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage),
          backgroundColor: Colors.red,
        ),
      );
    }
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Kamar Baru"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomorController,
                decoration: const InputDecoration(labelText: "Nomor Kamar (Cth: 1A, 201)"),
                validator: (val) => (val == null || val.isEmpty) ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _tipeController,
                decoration: const InputDecoration(labelText: "Tipe (Cth: KM Dalam + AC)"),
                validator: (val) => (val == null || val.isEmpty) ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(labelText: "Harga per Bulan (Cth: 500000)"),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) => (val == null || val.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text("Simpan Kamar"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}