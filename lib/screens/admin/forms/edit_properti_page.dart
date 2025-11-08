// lib/screens/admin/edit_properti_page.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/models/properti.dart';
import 'package:kosku_app/providers/properti_provider.dart';
import 'package:provider/provider.dart';

class EditPropertiPage extends StatefulWidget {
  final Properti properti;
  const EditPropertiPage({super.key, required this.properti});

  @override
  State<EditPropertiPage> createState() => _EditPropertiPageState();
}

class _EditPropertiPageState extends State<EditPropertiPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _alamatController;
  late TextEditingController _deskripsiController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.properti.namaProperti);
    _alamatController = TextEditingController(text: widget.properti.alamat);
    _deskripsiController = TextEditingController(text: widget.properti.deskripsi ?? '');
  }

  @override
  void dispose() {
    _namaController.dispose();
    _alamatController.dispose();
    _deskripsiController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final provider = Provider.of<PropertiProvider>(context, listen: false);
    final success = await provider.updateProperti(
      widget.properti.id,
      _namaController.text,
      _alamatController.text,
      _deskripsiController.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Properti diperbarui"), backgroundColor: Colors.green));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.errorMessage), backgroundColor: Colors.red));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Properti")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: "Nama Properti"),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(labelText: "Alamat"),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: "Deskripsi"),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(onPressed: _submit, child: const Text("Simpan Perubahan")),
            ],
          ),
        ),
      ),
    );
  }
}