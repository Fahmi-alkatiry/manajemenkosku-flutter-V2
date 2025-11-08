// lib/screens/admin/pages/admin_properti_page.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/models/properti.dart'; // <-- PENTING: Import model Properti
import 'package:kosku_app/providers/properti_provider.dart';
// Sesuaikan path import di bawah ini dengan struktur folder Anda
import 'package:kosku_app/screens/admin/forms/tambah_properti_screen.dart';
import 'package:kosku_app/screens/admin/details/properti_detail_page.dart';
import 'package:kosku_app/screens/admin/forms/edit_properti_page.dart';
import 'package:provider/provider.dart';

class AdminPropertiPage extends StatefulWidget {
  const AdminPropertiPage({super.key});

  @override
  State<AdminPropertiPage> createState() => _AdminPropertiPageState();
}

class _AdminPropertiPageState extends State<AdminPropertiPage> {
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<PropertiProvider>(context, listen: false)
          .fetchProperti()
          .then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _refreshProperti(BuildContext context) async {
    await Provider.of<PropertiProvider>(context, listen: false).fetchProperti();
  }

  // ===================================
  // ==    FUNGSI CONFIRM DELETE      ==
  // ===================================
  Future<void> _confirmDelete(BuildContext context, Properti properti) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Properti?"),
        content: Text(
            "Yakin ingin menghapus '${properti.namaProperti}'? Semua kamar dan kontrak di dalamnya juga akan terhapus!"),
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
      final provider = Provider.of<PropertiProvider>(context, listen: false);
      final success = await provider.deleteProperti(properti.id);

      if (!mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Properti berhasil dihapus"),
              backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(provider.errorMessage),
              backgroundColor: Colors.red),
        );
      }
    }
  }
  // ===================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar dihapus jika halaman ini menjadi bagian dari BottomNavigationBar shell
      // Jika berdiri sendiri, biarkan ada AppBar
      // appBar: AppBar(title: const Text("Manajemen Properti")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _refreshProperti(context),
              child: Consumer<PropertiProvider>(
                builder: (ctx, propertiData, _) {
                  if (propertiData.items.isEmpty) {
                    return const Center(
                      child: Text("Belum ada properti. Silakan tambahkan."),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: propertiData.items.length,
                      itemBuilder: (ctx, i) {
                        final properti = propertiData.items[i];
                        return ListTile(
                          title: Text(properti.namaProperti),
                          subtitle: Text(properti.alamat),
                          leading: CircleAvatar(
                            child: Text((i + 1).toString()),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) =>
                                    PropertiDetailPage(properti: properti),
                              ),
                            );
                          },
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'edit') {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        EditPropertiPage(properti: properti),
                                  ),
                                );
                              } else if (value == 'delete') {
                                _confirmDelete(context, properti);
                              }
                            },
                            itemBuilder: (BuildContext context) =>
                                <PopupMenuEntry<String>>[
                              const PopupMenuItem<String>(
                                value: 'edit',
                                child: Text('Edit'),
                              ),
                              const PopupMenuItem<String>(
                                value: 'delete',
                                child: Text('Hapus',
                                    style: TextStyle(color: Colors.red)),
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
                builder: (ctx) => const TambahPropertiScreen()),
          );
        },
        tooltip: "Tambah Properti",
        child: const Icon(Icons.add),
      ),
    );
  }
}