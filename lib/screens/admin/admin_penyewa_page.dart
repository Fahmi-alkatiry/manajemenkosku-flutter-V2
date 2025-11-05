// lib/screens/admin/admin_penyewa_page.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/providers/user_provider.dart';
import 'package:kosku_app/screens/admin/tambah_penyewa_page.dart';
import 'package:provider/provider.dart';
import 'package:kosku_app/screens/admin/detail_penyewa_page.dart'; // <-- 1. IMPORT BARU

class AdminPenyewaPage extends StatefulWidget {
  const AdminPenyewaPage({super.key});

  @override
  State<AdminPenyewaPage> createState() => _AdminPenyewaPageState();
}

class _AdminPenyewaPageState extends State<AdminPenyewaPage> {
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      // Panggil UserProvider untuk ambil data
      Provider.of<UserProvider>(context, listen: false).fetchPenyewa().then((
        _,
      ) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _refreshData(BuildContext context) async {
    await Provider.of<UserProvider>(context, listen: false).fetchPenyewa();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar ini akan ditampilkan oleh 'AdminHomeScreen'
      // Jadi kita biarkan polos
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _refreshData(context),
              child: Consumer<UserProvider>(
                builder: (ctx, provider, _) {
                  if (provider.penyewaList.isEmpty) {
                    return const Center(child: Text("Belum ada data penyewa."));
                  }
                  return ListView.builder(
                    itemCount: provider.penyewaList.length,
                    itemBuilder: (ctx, i) {
                      final penyewa = provider.penyewaList[i];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(penyewa.nama[0]), // Inisial
                        ),
                        title: Text(penyewa.nama),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // Kirim data 'penyewa' (UserSimple)
                              builder: (ctx) =>
                                  DetailPenyewaPage(penyewa: penyewa),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const TambahPenyewaPage()),
          );
        },
        child: const Icon(Icons.add),
        tooltip: "Tambah Penyewa",
      ),
    );
  }
}
