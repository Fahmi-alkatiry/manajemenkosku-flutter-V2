// lib/screens/ganti_password_page.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class GantiPasswordPage extends StatefulWidget {
  const GantiPasswordPage({super.key});

  @override
  State<GantiPasswordPage> createState() => _GantiPasswordPageState();
}

class _GantiPasswordPageState extends State<GantiPasswordPage> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return; // Validasi gagal
    
    setState(() { _isLoading = true; });

    final provider = Provider.of<AuthProvider>(context, listen: false);
    final success = await provider.changePassword(_passwordController.text);

    if (!mounted) return;
    if (success) {
      Navigator.pop(context); // Kembali ke halaman profil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password berhasil diperbarui'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? "Gagal ganti password"),
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
        title: const Text("Ganti Password"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password Baru"),
                obscureText: true, // Sembunyikan teks password
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Wajib diisi';
                  if (val.length < 6) return 'Minimal 6 karakter';
                  return null;
                },
              ),
              TextFormField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: "Konfirmasi Password Baru"),
                obscureText: true,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Wajib diisi';
                  // Cek apakah sama dengan password di atas
                  if (val != _passwordController.text) return 'Password tidak cocok';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text("Simpan Password"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}