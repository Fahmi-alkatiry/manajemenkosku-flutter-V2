// lib/screens/tambah_properti_screen.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/providers/properti_provider.dart';
import 'package:provider/provider.dart';

class TambahPropertiScreen extends StatefulWidget {
  const TambahPropertiScreen({super.key});

  @override
  State<TambahPropertiScreen> createState() => _TambahPropertiScreenState();
}

class _TambahPropertiScreenState extends State<TambahPropertiScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _deskripsiController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return; // Validasi gagal
    }
    setState(() { _isLoading = true; });

    final provider = Provider.of<PropertiProvider>(context, listen: false);
    
    final success = await provider.tambahProperti(
      _namaController.text,
      _alamatController.text,
      _deskripsiController.text,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context); // Kembali ke halaman daftar properti
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
        title: const Text("Tambah Properti Baru"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: "Nama Properti"),
                validator: (val) => (val == null || val.isEmpty) ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(labelText: "Alamat"),
                validator: (val) => (val == null || val.isEmpty) ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: "Deskripsi (Opsional)"),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text("Simpan"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}