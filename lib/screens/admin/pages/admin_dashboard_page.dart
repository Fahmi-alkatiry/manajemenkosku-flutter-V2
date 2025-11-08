// lib/screens/admin/admin_dashboard_page.dart
import 'package:flutter/material.dart';
import 'package:kosku_app/providers/dashboard_provider.dart';
import 'package:provider/provider.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  bool _isInit = true;

  @override
  void didChangeDependencies() {
    if (_isInit) {
      // Ambil data statistik saat halaman dimuat
      Provider.of<DashboardProvider>(context, listen: false).fetchStats();
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  Future<void> _refreshData(BuildContext context) async {
    await Provider.of<DashboardProvider>(context, listen: false).fetchStats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar akan di-handle oleh AdminHomeScreen
      body: RefreshIndicator(
        onRefresh: () => _refreshData(context),
        child: Consumer<DashboardProvider>(
          builder: (ctx, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (provider.stats == null) {
               return const Center(child: Text("Gagal memuat data dashboard"));
            }

            final stats = provider.stats!;

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                const Text(
                  "Ringkasan Bisnis Anda",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                
                // Grid Kartu Statistik
                GridView.count(
                  crossAxisCount: 2, // 2 kolom
                  shrinkWrap: true, // Agar bisa di dalam ListView
                  physics: const NeverScrollableScrollPhysics(), // Agar tidak scroll sendiri
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.0, // Rasio lebar:tinggi kartu
                  children: [
                    _buildStatCard("Total Properti", stats.totalProperti.toString(), Colors.blue, Icons.home_work),
                    _buildStatCard("Total Kamar", stats.totalKamar.toString(), Colors.purple, Icons.bed),
                    _buildStatCard("Kamar Terisi", stats.kamarTerisi.toString(), Colors.green, Icons.person),
                    _buildStatCard("Kamar Kosong", stats.kamarTersedia.toString(), Colors.orange, Icons.meeting_room),
                  ],
                ),
                
                const SizedBox(height: 30),

                // Kartu Peringatan Tagihan
                Card(
                  color: Colors.red[50],
                  elevation: 4,
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.red, size: 40),
                    title: Text("${stats.tagihanPending} Tagihan Menunggu", 
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 18)),
                    subtitle: const Text("Segera verifikasi di tab Verifikasi."),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // Widget helper untuk membuat kartu
  Widget _buildStatCard(String title, String count, Color color, IconData icon) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 10),
            Text(
              count,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color),
            ),
            Text(
              title,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}