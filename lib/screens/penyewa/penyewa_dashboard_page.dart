// lib/screens/penyewa/penyewa_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/models/pembayaran.dart';
import 'package:kosku_app/providers/pembayaran_provider.dart';
import 'package:kosku_app/screens/penyewa/pembayaran_page.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class PenyewaDashboardPage extends StatefulWidget {
  const PenyewaDashboardPage({super.key}); // Constructor sudah benar

  @override
  State<PenyewaDashboardPage> createState() => _PenyewaDashboardPageState();
}

class _PenyewaDashboardPageState extends State<PenyewaDashboardPage> {
  // ... (SEMUA KODE LAMA ANDA: _isInit, _isLoading, didChangeDependencies, _refreshData)
  
  bool _isInit = true;
  bool _isLoading = false;
  final formatRupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void didChangeDependencies() {
    if (_isInit) {
      setState(() { _isLoading = true; });
      Provider.of<PembayaranProvider>(context, listen: false)
          .fetchMyPayments()
          .then((_) {
        setState(() { _isLoading = false; });
      });
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _refreshData(BuildContext context) async {
    await Provider.of<PembayaranProvider>(context, listen: false)
        .fetchMyPayments();
  }
  
  @override
  Widget build(BuildContext context) {
    // TIDAK ADA SCAFFOLD ATAU APPBAR DI SINI
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: () => _refreshData(context),
            child: Consumer<PembayaranProvider>(
              builder: (ctx, provider, _) {
                // ... (Sisa kode ListView dan helper Anda)
                final tagihanAktif = provider.tagihanAktif;
                final riwayat = provider.riwayatPembayaran;

                return ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    if (tagihanAktif != null)
                      _buildTagihanAktifCard(context, tagihanAktif)
                    else
                      _buildTagihanAmanCard(),
                    const SizedBox(height: 20),
                    const Text(
                      "Riwayat Pembayaran",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    if (riwayat.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: Center(child: Text("Belum ada riwayat pembayaran.")),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: riwayat.length,
                        itemBuilder: (ctx, i) {
                          final tagihan = riwayat[i];
                          return _buildRiwayatTile(tagihan);
                        },
                      ),
                  ],
                );
              },
            ),
          );
  }

  // ... (SEMUA KODE WIDGET HELPER: _buildTagihanAktifCard, _buildTagihanAmanCard, _buildRiwayatTile)
  
  Widget _buildTagihanAktifCard(BuildContext context, Pembayaran tagihan) {
    // ... (kode _buildTagihanAktifCard Anda)
    return Card(
      color: Colors.orange[50],
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("TAGIHAN BULAN INI", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
            const SizedBox(height: 10),
            Text(
              '${tagihan.bulan} ${tagihan.tahun}',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              'Kamar ${tagihan.kamarNomor ?? 'N/A'}',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              formatRupiah.format(tagihan.jumlah),
              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.orange),
            ),
            const SizedBox(height: 15),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (ctx) => PembayaranPage(tagihan: tagihan),
                  ));
                },
                child: const Text("Bayar Tagihan Sekarang"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagihanAmanCard() {
    // ... (kode _buildTagihanAmanCard Anda)
    return Card(
      color: Colors.green[50],
      elevation: 4,
      child: const Padding(
        padding: EdgeInsets.all(24.0),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 40),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                "Semua tagihan lunas!\nAnda tidak memiliki tagihan aktif.",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRiwayatTile(Pembayaran tagihan) {
    // ... (kode _buildRiwayatTile Anda)
    return ListTile(
      title: Text('${tagihan.bulan} ${tagihan.tahun}'),
      subtitle: Text('Kamar ${tagihan.kamarNomor ?? 'N/A'}'),
      trailing: Chip(
        label: Text(
          tagihan.status,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: tagihan.status == 'Lunas' ? Colors.green : Colors.red,
      ),
    );
  }
}