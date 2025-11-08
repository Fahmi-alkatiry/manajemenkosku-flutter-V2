// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/providers/auth_provider.dart';
import 'package:kosku_app/providers/properti_provider.dart';
import 'package:kosku_app/screens/admin/forms/tambah_properti_screen.dart'; // Impor layar tambah
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isInit = true;
  bool _isLoading = false;

  @override
  void didChangeDependencies() {
    // Ambil data properti saat halaman ini dimuat
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      Provider.of<PropertiProvider>(context).fetchProperti().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  // Fungsi untuk refresh data
  Future<void> _refreshProperti(BuildContext context) async {
    await Provider.of<PropertiProvider>(context, listen: false).fetchProperti();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Properti Saya"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Provider.of<AuthProvider>(context, listen: false).logout();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _refreshProperti(context), // Tarik untuk refresh
              child: Consumer<PropertiProvider>(
                builder: (ctx, propertiData, _) {
                  if (propertiData.items.isEmpty) {
                    return const Center(
                      child: Text("Belum ada properti. Silakan tambahkan."),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: propertiData.items.length,
                      itemBuilder: (ctx, i) => ListTile(
                        title: Text(propertiData.items[i].namaProperti),
                        subtitle: Text(propertiData.items[i].alamat),
                        leading: CircleAvatar(
                          child: Text((i + 1).toString()),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
      // Tombol FAB untuk menambah properti
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