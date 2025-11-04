// lib/screens/edit_profile_page.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _noHpController = TextEditingController();
  final _alamatController = TextEditingController();
  
  // Ubah _isLoading menjadi _isSaving (untuk tombol simpan)
  bool _isSaving = false;
  // Tambahkan _isLoadingPage (untuk memuat form)
  bool _isLoadingPage = true; 

  @override
  void initState() {
    super.initState();
    // Panggil fetchMyProfile saat halaman dibuka
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    
    // Panggil API
    await authProvider.fetchMyProfile(); 

    // Setelah data ada, isi controllernya
    if (authProvider.userProfile != null) {
      _namaController.text = authProvider.userProfile!.nama;
      _emailController.text = authProvider.userProfile!.email;
      _noHpController.text = authProvider.userProfile!.noHp ?? '';
      _alamatController.text = authProvider.userProfile!.alamat ?? '';
    }
    
    setState(() {
      _isLoadingPage = false; // Selesai loading halaman
    });
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _noHpController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() { _isSaving = true; }); // Gunakan _isSaving

    final provider = Provider.of<AuthProvider>(context, listen: false);
    final success = await provider.updateProfile(
      _namaController.text,
      _noHpController.text,
      _alamatController.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui'), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? "Gagal update"), // Perbaikan error 'String?'
          backgroundColor: Colors.red
        ),
      );
    }
    setState(() { _isSaving = false; }); // Gunakan _isSaving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profil"),
      ),
      // Tampilkan loading spinner saat data profil diambil
      body: _isLoadingPage 
          ? const Center(child: CircularProgressIndicator()) 
          : Padding(
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
                      readOnly: true, // Email tidak boleh diganti
                      style: const TextStyle(color: Colors.grey),
                    ),
                    TextFormField(
                      controller: _noHpController,
                      decoration: const InputDecoration(labelText: "Nomor HP (Opsional)"),
                      keyboardType: TextInputType.phone,
                    ),
                    TextFormField(
      
                      controller: _alamatController,
                      decoration: const InputDecoration(labelText: "Alamat (Opsional)"),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 20),
                    // Gunakan _isSaving untuk tombol
                    _isSaving 
                        ? const Center(child: CircularProgressIndicator())
                        : ElevatedButton(
                            onPressed: _submit,
                            child: const Text("Simpan Perubahan"),
                          ),
                  ],
                ),
              ),
            ),
    );
  }
}