// lib/screens/admin/tambah_penyewa_page.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/providers/user_provider.dart';
import 'package:provider/provider.dart';

class TambahPenyewaPage extends StatefulWidget {
  const TambahPenyewaPage({super.key});

  @override
  State<TambahPenyewaPage> createState() => _TambahPenyewaPageState();
}

class _TambahPenyewaPageState extends State<TambahPenyewaPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _noHpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _noHpController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() { _isLoading = true; });

    final provider = Provider.of<UserProvider>(context, listen: false);
    final success = await provider.tambahPenyewa(
      nama: _namaController.text,
      email: _emailController.text,
      password: _passwordController.text,
      noHp: _noHpController.text.isEmpty ? null : _noHpController.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pop(context); // Kembali ke daftar penyewa
    } else {
      // Tampilkan error (misal: email sudah terdaftar)
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? "Gagal menambah penyewa"),
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
        title: const Text("Tambah Penyewa Baru"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: "Nama Lengkap"),
                validator: (val) => (val == null || val.isEmpty) ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Wajib diisi';
                  if (!val.contains('@')) return 'Email tidak valid';
                  return null;
                },
              ),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password (Minimal 6 karakter)"),
                obscureText: true,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Wajib diisi';
                  if (val.length < 6) return 'Minimal 6 karakter';
                  return null;
                },
              ),
              TextFormField(
                controller: _noHpController,
                decoration: const InputDecoration(labelText: "Nomor HP (Opsional)"),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text("Simpan Penyewa"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}