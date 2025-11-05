// lib/screens/admin/admin_properti_page.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/providers/properti_provider.dart';
import 'package:kosku_app/screens/tambah_properti_screen.dart'; // Akan kita buat
import 'package:provider/provider.dart';
import 'package:kosku_app/screens/admin/properti_detail_page.dart';

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
    // Ambil data properti saat halaman ini dimuat pertama kali
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      // Panggil provider untuk fetch data dari API
      Provider.of<PropertiProvider>(
        context,
        listen: false,
      ).fetchProperti().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  // Fungsi untuk refresh data saat ditarik ke bawah
  Future<void> _refreshProperti(BuildContext context) async {
    await Provider.of<PropertiProvider>(context, listen: false).fetchProperti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _refreshProperti(context),
              child: Consumer<PropertiProvider>(
                // Dengarkan perubahan data
                builder: (ctx, propertiData, _) {
                  if (propertiData.items.isEmpty) {
                    return const Center(
                      child: Text("Belum ada properti. Silakan tambahkan."),
                    );
                  } else {
                    // Tampilkan daftar properti
                    return ListView.builder(
                      itemCount: propertiData.items.length,
                      itemBuilder: (ctx, i) {
                        final properti =
                            propertiData.items[i]; // Ambil objek properti
                        return ListTile(
                          title: Text(propertiData.items[i].namaProperti),
                          subtitle: Text(propertiData.items[i].alamat),
                          leading: CircleAvatar(
                            child: Text((i + 1).toString()),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                // Kirim data properti ke halaman detail
                                builder: (ctx) =>
                                    PropertiDetailPage(properti: properti),
                              ),
                            );
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
      // Tombol '+' untuk menambah properti baru
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const TambahPropertiScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
