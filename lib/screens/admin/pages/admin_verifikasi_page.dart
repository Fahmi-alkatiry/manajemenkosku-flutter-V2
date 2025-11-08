// lib/screens/admin/admin_verifikasi_page.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/providers/pembayaran_provider.dart';
import 'package:kosku_app/screens/admin/forms/tambah_tagihan_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Untuk format Rupiah
import 'package:kosku_app/screens/admin/details/detail_verifikasi_page.dart'; // <-- 1. IMPORT

class AdminVerifikasiPage extends StatefulWidget {
  const AdminVerifikasiPage({super.key});

  @override
  State<AdminVerifikasiPage> createState() => _AdminVerifikasiPageState();
}

class _AdminVerifikasiPageState extends State<AdminVerifikasiPage> {
  bool _isInit = true;
  bool _isLoading = false;
  final formatRupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() {
        _isLoading = true;
      });
      // Ambil daftar tagihan pending saat halaman dimuat
      Provider.of<PembayaranProvider>(
        context,
        listen: false,
      ).fetchPendingPayments().then((_) {
        setState(() {
          _isLoading = false;
        });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _refreshData(BuildContext context) async {
    await Provider.of<PembayaranProvider>(
      context,
      listen: false,
    ).fetchPendingPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _refreshData(context),
              child: Consumer<PembayaranProvider>(
                builder: (ctx, provider, _) {
                  if (provider.pendingPayments.isEmpty) {
                    return const Center(
                      child: Text("Tidak ada tagihan pending."),
                    );
                  }
                  return ListView.builder(
                    itemCount: provider.pendingPayments.length,
                    itemBuilder: (ctx, i) {
                      final tagihan = provider.pendingPayments[i];
                      return ListTile(
                        title: Text(
                          '${tagihan.penyewaNama ?? '...'} - ${tagihan.kamarNomor ?? '...'}',
                        ),
                        subtitle: Text('${tagihan.bulan} ${tagihan.tahun}'),
                        trailing: Text(
                          formatRupiah.format(tagihan.jumlah),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              // Kirim data tagihan yang diklik
                              builder: (ctx) =>
                                  DetailVerifikasiPage(tagihan: tagihan),
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
          // Navigasi ke Halaman Tambah Tagihan
          Navigator.push(
            context,
            MaterialPageRoute(builder: (ctx) => const TambahTagihanPage()),
          );
        },
        tooltip: "Buat Tagihan Baru",
        child: const Icon(Icons.add),
      ),
    );
  }
}
