// lib/screens/admin/edit_kamar_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kosku_app/models/kamar.dart';
import 'package:kosku_app/providers/kamar_provider.dart';
import 'package:provider/provider.dart';

class EditKamarPage extends StatefulWidget {
  final Kamar kamar;
  const EditKamarPage({super.key, required this.kamar});

  @override
  State<EditKamarPage> createState() => _EditKamarPageState();
}

class _EditKamarPageState extends State<EditKamarPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomorController;
  late TextEditingController _tipeController;
  late TextEditingController _hargaController;
  late String _selectedStatus;
  bool _isLoading = false;

  final List<String> _statusOptions = ['Tersedia', 'Ditempati', 'Diperbaiki'];

  @override
  void initState() {
    super.initState();
    _nomorController = TextEditingController(text: widget.kamar.nomorKamar);
    _tipeController = TextEditingController(text: widget.kamar.tipe);
    _hargaController = TextEditingController(text: widget.kamar.harga.toStringAsFixed(0));
    _selectedStatus = widget.kamar.status;
  }

  @override
  void dispose() {
    _nomorController.dispose();
    _tipeController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final provider = Provider.of<KamarProvider>(context, listen: false);
    final success = await provider.updateKamar(
      widget.kamar.id,
      {
        'nomor_kamar': _nomorController.text,
        'tipe': _tipeController.text,
        'harga': double.parse(_hargaController.text),
        'status': _selectedStatus,
      },
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Kamar berhasil diupdate"), backgroundColor: Colors.green),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Kamar ${widget.kamar.nomorKamar}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nomorController,
                decoration: const InputDecoration(labelText: "Nomor Kamar"),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _tipeController,
                decoration: const InputDecoration(labelText: "Tipe"),
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              TextFormField(
                controller: _hargaController,
                decoration: const InputDecoration(labelText: "Harga"),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) => val!.isEmpty ? 'Wajib diisi' : null,
              ),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: const InputDecoration(labelText: "Status"),
                items: _statusOptions.map((status) => DropdownMenuItem(value: status, child: Text(status))).toList(),
                onChanged: (val) => setState(() => _selectedStatus = val!),
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