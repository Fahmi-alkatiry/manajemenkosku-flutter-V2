// lib/screens/admin/properti_detail_page.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/models/properti.dart';
import 'package:kosku_app/providers/kamar_provider.dart';
import 'package:provider/provider.dart';
import 'package:kosku_app/screens/admin/tambah_kamar_page.dart'; // <-- 1. IMPORT
import 'package:kosku_app/screens/admin/tambah_kontrak_page.dart'; // <-- 1. IMPORT BARU

class PropertiDetailPage extends StatefulWidget {
  // Terima data properti yang diklik
  final Properti properti;
  
  const PropertiDetailPage({super.key, required this.properti});

  @override
  State<PropertiDetailPage> createState() => _PropertiDetailPageState();
}

class _PropertiDetailPageState extends State<PropertiDetailPage> {
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() { _isLoading = true; });
      // Panggil provider untuk ambil data kamar berdasarkan ID properti
      Provider.of<KamarProvider>(context, listen: false)
          .fetchKamar(widget.properti.id) // Gunakan ID dari properti
          .then((_) {
        setState(() { _isLoading = false; });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  // Fungsi refresh
  Future<void> _refreshKamar(BuildContext context) async {
    await Provider.of<KamarProvider>(context, listen: false)
        .fetchKamar(widget.properti.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.properti.namaProperti),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _refreshKamar(context),
              child: Consumer<KamarProvider>( // Dengarkan KamarProvider
                builder: (ctx, kamarData, _) {
                  if (kamarData.kamarItems.isEmpty) {
                    return const Center(
                      child: Text("Belum ada kamar di properti ini."),
                    );
                  } else {
                   return ListView.builder(
      itemCount: kamarData.kamarItems.length,
      itemBuilder: (ctx, i) {
        final kamar = kamarData.kamarItems[i];
        bool isTersedia = kamar.status == 'Tersedia'; // Cek status

        return ListTile(
          title: Text("Kamar ${kamar.nomorKamar}"),
          subtitle: Text(kamar.tipe),
          trailing: Chip(
            label: Text(
              kamar.status,
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: isTersedia ? Colors.green : Colors.red,
          ),
          
          // ===================================
          // ==       TAMBAHKAN INI         ==
          // ===================================
          onTap: () {
            if (isTersedia) {
              // Jika Tersedia, buka halaman Buat Kontrak
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => TambahKontrakPage(kamar: kamar),
                ),
              );
            } else {
              // Jika Ditempati, mungkin nanti tampilkan detail kontrak
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Kamar ${kamar.nomorKamar} sudah ditempati.')),
              );
            }
          },
          // ===================================

        );
      },
    );
                  }
                },
              ),
            ),
     floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigasi ke halaman Tambah Kamar
          Navigator.push(
            context,
            MaterialPageRoute(
              // Kirim ID properti ke halaman tambah
              builder: (ctx) => TambahKamarPage(propertiId: widget.properti.id),
            ),
          );
        },
        child: const Icon(Icons.add),
        tooltip: "Tambah Kamar",
      ),
    );
  }
}