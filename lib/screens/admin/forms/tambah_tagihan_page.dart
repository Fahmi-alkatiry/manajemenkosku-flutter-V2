// lib/screens/admin/tambah_tagihan_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kosku_app/models/kontrak_simple.dart';
import 'package:kosku_app/providers/pembayaran_provider.dart';
import 'package:provider/provider.dart';

class TambahTagihanPage extends StatefulWidget {
  const TambahTagihanPage({super.key});

  @override
  State<TambahTagihanPage> createState() => _TambahTagihanPageState();
}

class _TambahTagihanPageState extends State<TambahTagihanPage> {
  final _formKey = GlobalKey<FormState>();
  KontrakSimple? _selectedKontrak;
  String? _selectedBulan;
  final _tahunController = TextEditingController(text: DateTime.now().year.toString());
  bool _isLoading = false;

  // Daftar bulan untuk dropdown
  final List<String> _bulanList = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];

  @override
  void initState() {
    super.initState();
    // Ambil daftar kontrak aktif untuk dropdown saat halaman dibuka
    Provider.of<PembayaranProvider>(context, listen: false).fetchActiveContracts();
  }

  @override
  void dispose() {
    _tahunController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return; // Validasi gagal
    
    setState(() { _isLoading = true; });

    final provider = Provider.of<PembayaranProvider>(context, listen: false);
    final success = await provider.createTagihan(
      kontrakId: _selectedKontrak!.id,
      bulan: _selectedBulan!,
      tahun: int.parse(_tahunController.text),
    );

    if (!mounted) return;
    if (success) {
      Navigator.pop(context); // Kembali ke halaman verifikasi
    } else {
      // Tampilkan error jika gagal
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage), backgroundColor: Colors.red),
      );
    }
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Tagihan Baru"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Dropdown Kontrak
              Consumer<PembayaranProvider>(
                builder: (ctx, provider, _) {
                  if (provider.isLoading && provider.activeContracts.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return DropdownButtonFormField<KontrakSimple>(
                    decoration: const InputDecoration(labelText: 'Pilih Kontrak'),
                    initialValue: _selectedKontrak,
                    items: provider.activeContracts.map((kontrak) {
                      return DropdownMenuItem(
                        value: kontrak,
                        // Tampilkan nama kamar, penyewa, dan properti
                        child: Text(kontrak.displayName, overflow: TextOverflow.ellipsis),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedKontrak = value),
                    validator: (val) => (val == null) ? 'Wajib pilih kontrak' : null,
                  );
                },
              ),
SizedBox(height: 10),
              // Dropdown Bulan
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Bulan'),
                initialValue: _selectedBulan,
                items: _bulanList.map((bulan) {
                  return DropdownMenuItem(value: bulan, child: Text(bulan));
                }).toList(),
                onChanged: (value) => setState(() => _selectedBulan = value),
                validator: (val) => (val == null) ? 'Wajib pilih bulan' : null,
              ),
              // Form Tahun
              TextFormField(
                controller: _tahunController,
                decoration: const InputDecoration(labelText: "Tahun"),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (val) => (val == null || val.isEmpty) ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 20),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ElevatedButton(
                      onPressed: _submit,
                      child: const Text("Simpan Tagihan"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}