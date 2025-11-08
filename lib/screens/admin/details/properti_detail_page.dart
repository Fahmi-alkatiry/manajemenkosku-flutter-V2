// lib/screens/admin/properti_detail_page.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/models/properti.dart';
import 'package:kosku_app/models/kamar.dart'; // Import model Kamar
import 'package:kosku_app/providers/kamar_provider.dart';
import 'package:kosku_app/screens/admin/forms/tambah_kamar_page.dart';
import 'package:kosku_app/screens/admin/forms/tambah_kontrak_page.dart';
import 'package:kosku_app/screens/admin/details/detail_kontrak_aktif_page.dart';
import 'package:kosku_app/screens/admin/forms/edit_kamar_page.dart'; // Import halaman Edit
import 'package:provider/provider.dart';

class PropertiDetailPage extends StatefulWidget {
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
      Provider.of<KamarProvider>(context, listen: false)
          .fetchKamar(widget.properti.id)
          .then((_) {
        setState(() { _isLoading = false; });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _refreshKamar(BuildContext context) async {
    await Provider.of<KamarProvider>(context, listen: false)
        .fetchKamar(widget.properti.id);
  }

  // Fungsi Konfirmasi Hapus Kamar
  Future<void> _confirmDelete(BuildContext context, Kamar kamar) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Kamar?"),
        content: Text("Yakin ingin menghapus Kamar ${kamar.nomorKamar}?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Batal")),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = Provider.of<KamarProvider>(context, listen: false);
      final success = await provider.deleteKamar(kamar.id);

      if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(provider.errorMessage),
              backgroundColor: Colors.red),
        );
      } else if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Kamar berhasil dihapus"),
              backgroundColor: Colors.green),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.properti.namaProperti)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _refreshKamar(context),
              child: Consumer<KamarProvider>(
                builder: (ctx, kamarData, _) {
                  if (kamarData.kamarItems.isEmpty) {
                    return const Center(
                        child: Text("Belum ada kamar di properti ini."));
                  } else {
                    return ListView.builder(
                      itemCount: kamarData.kamarItems.length,
                      itemBuilder: (ctx, i) {
                        final kamar = kamarData.kamarItems[i];
                        bool isTersedia = kamar.status == 'Tersedia';

                        return ListTile(
                          title: Text("Kamar ${kamar.nomorKamar}"),
                          subtitle: Text(kamar.tipe),
                          
                          // Navigasi saat tap (Kontrak/Info)
                          onTap: () async {
                            if (isTersedia) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) =>
                                      TambahKontrakPage(kamar: kamar),
                                ),
                              );
                            } else if (kamar.status == 'Ditempati' &&
                                kamar.kontrakAktifId != null) {
                              final perluRefresh = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) =>
                                      DetailKontrakAktifPage(kamar: kamar),
                                ),
                              );
                              if (!mounted) return;
                              if (perluRefresh == true) {
                                _refreshKamar(context);
                              }
                            } else {
                              if (!mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Kamar ${kamar.nomorKamar} sedang tidak tersedia.')),
                              );
                            }
                          },

                          // Trailing: Status Chip + Menu Edit/Delete
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Chip(
                                label: Text(
                                  kamar.status,
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12),
                                ),
                                backgroundColor: isTersedia
                                    ? Colors.green
                                    : (kamar.status == 'Ditempati'
                                        ? Colors.red
                                        : Colors.orange),
                              ),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              EditKamarPage(kamar: kamar)),
                                    );
                                  } else if (value == 'delete') {
                                    _confirmDelete(context, kamar);
                                  }
                                },
                                itemBuilder: (BuildContext context) =>
                                    <PopupMenuEntry<String>>[
                                  const PopupMenuItem<String>(
                                      value: 'edit', child: Text('Edit')),
                                  const PopupMenuItem<String>(
                                      value: 'delete',
                                      child: Text('Hapus',
                                          style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => TambahKamarPage(propertiId: widget.properti.id),
            ),
          );
        },
        tooltip: "Tambah Kamar",
        child: const Icon(Icons.add),
      ),
    );
  }
}