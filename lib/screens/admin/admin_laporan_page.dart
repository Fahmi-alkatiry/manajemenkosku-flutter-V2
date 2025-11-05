// lib/screens/admin/admin_laporan_page.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/models/pembayaran.dart';
import 'package:kosku_app/providers/pembayaran_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AdminLaporanPage extends StatefulWidget {
  const AdminLaporanPage({super.key});

  @override
  State<AdminLaporanPage> createState() => _AdminLaporanPageState();
}

class _AdminLaporanPageState extends State<AdminLaporanPage> {
  bool _isInit = true;
  bool _isLoading = false;
  final formatRupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
  
  // Status filter yang dipilih (default: Lunas)
  String? _selectedStatus = 'Lunas';
  final List<String?> _filterOptions = ['Lunas', 'Ditolak', 'Pending', null]; // null = Semua

  @override
  void didChangeDependencies() {
    if (_isInit) {
      _loadData();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _loadData() async {
    setState(() { _isLoading = true; });
    // Panggil fetchReportPayments dengan filter status yang dipilih
    await Provider.of<PembayaranProvider>(context, listen: false)
        .fetchReportPayments(status: _selectedStatus);
    setState(() { _isLoading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar akan di-handle oleh AdminHomeScreen
      body: Column(
        children: [
          // === Filter Bar ===
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text("Filter Status: ", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String?>(
                    value: _selectedStatus,
                    isExpanded: true,
                    items: _filterOptions.map((String? status) {
                      return DropdownMenuItem<String?>(
                        value: status,
                        child: Text(status ?? 'Semua Status'),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedStatus = newValue;
                      });
                      _loadData(); // Reload data saat filter berubah
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // === Daftar Laporan ===
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Consumer<PembayaranProvider>(
                    builder: (ctx, provider, _) {
                      final laporanList = provider.reportPayments;
                      
                      if (laporanList.isEmpty) {
                        return const Center(child: Text("Tidak ada data laporan."));
                      }

                      // Hitung total pendapatan (hanya yang Lunas)
                      double totalPendapatan = 0;
                      for (var p in laporanList) {
                        if (p.status == 'Lunas') totalPendapatan += p.jumlah;
                      }

                      return Column(
                        children: [
                          // Kartu Ringkasan (Opsional, tapi bagus)
                          if (_selectedStatus == 'Lunas' || _selectedStatus == null)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16.0),
                              color: Colors.green[50],
                              child: Text(
                                "Total Pendapatan: ${formatRupiah.format(totalPendapatan)}",
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          
                          // List Laporan
                          Expanded(
                            child: ListView.builder(
                              itemCount: laporanList.length,
                              itemBuilder: (ctx, i) {
                                final tagihan = laporanList[i];
                                return _buildLaporanTile(tagihan);
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLaporanTile(Pembayaran tagihan) {
    Color statusColor = Colors.grey;
    if (tagihan.status == 'Lunas') statusColor = Colors.green;
    if (tagihan.status == 'Ditolak') statusColor = Colors.red;
    if (tagihan.status == 'Pending') statusColor = Colors.orange;

    return ListTile(
      title: Text('${tagihan.penyewaNama ?? '...'} (${tagihan.kamarNomor ?? '...'})'),
      subtitle: Text('${tagihan.bulan} ${tagihan.tahun}'),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(formatRupiah.format(tagihan.jumlah), style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(tagihan.status, style: TextStyle(color: statusColor, fontSize: 12)),
        ],
      ),
      onTap: () {
        // Opsional: Buka detail tagihan jika perlu
      },
    );
  }
}