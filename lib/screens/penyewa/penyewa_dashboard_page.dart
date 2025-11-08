// lib/screens/penyewa/penyewa_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kosku_app/models/pembayaran.dart';
import 'package:kosku_app/providers/pembayaran_provider.dart';
import 'package:kosku_app/screens/penyewa/pembayaran_page.dart';
import 'package:provider/provider.dart';

class PenyewaDashboardPage extends StatefulWidget {
  const PenyewaDashboardPage({super.key});

  @override
  State<PenyewaDashboardPage> createState() => _PenyewaDashboardPageState();
}

class _PenyewaDashboardPageState extends State<PenyewaDashboardPage> {
  bool _isInit = true;
  bool _isLoading = false;

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

  // Helper format mata uang
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  @override
  Widget build(BuildContext context) {
    // Kita gunakan Scaffold di sini karena ini adalah 'isi' dari tab,
    // tapi kita hapus AppBar agar AppBar dari shell (PenyewaHomeScreen) yang dipakai.
    // Jika Anda ingin header biru ini menggantikan AppBar, kita perlu ubah
    // strukturnya sedikit, tapi untuk sekarang, ini akan bekerja di dalam shell.

    // Untuk UI baru, kita hapus Scaffold dan biarkan ListView
    
    return Container(
      color: Colors.grey[50], // Pindahkan background color ke sini
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => _refreshData(context),
              child: Consumer<PembayaranProvider>(
                builder: (ctx, provider, _) {
                  final tagihanAktifList = provider.tagihanAktifList; 
                  final riwayat = provider.riwayatPembayaran;
                  final hasPendingBill = tagihanAktifList.isNotEmpty;

                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      // Header (dari UI baru Anda)
                      Container(
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(24),
                          ),
                        ),
                        padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Selamat Datang", // TODO: Ganti dengan nama user
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "Kelola pembayaran kos Anda",
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Tagihan Bulan Ini (dari UI baru Anda)
                     // Logika BARU: Tampilkan list jika ada, atau kartu 'lunas' jika tidak ada
                      if (!hasPendingBill)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Transform.translate(
                            offset: const Offset(0, -24),
                            child: _buildAllPaidCard(),
                          ),
                        )
                      else
                        // Jika ada tagihan, tampilkan sebagai list
                        ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: tagihanAktifList.length,
                          itemBuilder: (ctx, i) {
                            // Terapkan 'transform' ke item pertama
                            final card = _buildPendingBillCard(context, tagihanAktifList[i]);
                            if (i == 0) {
                              return Transform.translate(
                                offset: const Offset(0, -24),
                                child: card,
                              );
                            }
                            // Tampilkan kartu biasa untuk sisa tagihan
                            return Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: card,
                            );
                          },
                        ),

                      // Riwayat Pembayaran (dari UI baru Anda)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Riwayat Pembayaran",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                            if (riwayat.isEmpty)
                              const Center(child: Text("Belum ada riwayat pembayaran."))
                            else
                              Column(
                                // Gunakan data riwayat dari provider
                                children: riwayat.map((payment) {
                                  return _buildHistoryItem(payment);
                                }).toList(),
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
    );
  }

  // ========== COMPONENTS (Diadaptasi dari UI Anda + Data Provider) ==========

  Widget _buildPendingBillCard(BuildContext context, Pembayaran tagihan) {
    final String dueDate = tagihan.tanggalJatuhTempo != null
        ? DateFormat('dd MMM yyyy').format(tagihan.tanggalJatuhTempo!)
        : 'N/A';
        
    return Card(
      color: Colors.orange.shade100,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.orange.shade300.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.credit_card, color: Colors.orange),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tagihan Bulan Ini",
                    style: TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${tagihan.bulan} ${tagihan.tahun}', // Data dari Provider
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatCurrency(tagihan.jumlah), // Data dari Provider
                    style: const TextStyle(
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Kita belum punya 'dueDate' di model, jadi kita sembunyikan
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          color: Colors.orange.shade700, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        "Jatuh tempo: $dueDate", // <-- Tampilkan data
                        style: TextStyle(
                          color: Colors.orange.shade700,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      // Tombol dihubungkan ke Halaman Pembayaran
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => PembayaranPage(tagihan: tagihan),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Bayar Tagihan Sekarang"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllPaidCard() {
    // Widget ini statis, jadi tidak perlu diubah
    return Card(
      color: Colors.green.shade100,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green.shade300.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle, color: Colors.green),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Semua Tagihan Lunas",
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    "Tidak ada tagihan yang perlu dibayar",
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem(Pembayaran payment) {
    final isLunas = payment.status == 'Lunas';
    // Format tanggal bayar jika ada
    final String paidDate = payment.tanggalBayar != null
        ? DateFormat('dd MMM yyyy').format(payment.tanggalBayar!)
        : 'Menunggu'; // Tampilkan 'Menunggu' jika Ditolak/Pending

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isLunas
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLunas ? Icons.check_circle : Icons.cancel,
                    color: isLunas ? Colors.green : Colors.redAccent,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${payment.bulan} ${payment.tahun}', // Data dari Provider
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      paidDate, // Data dari Provider
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatCurrency(payment.jumlah), // Data dari Provider
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  payment.status, // Data dari Provider
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isLunas ? Colors.green : Colors.redAccent,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}