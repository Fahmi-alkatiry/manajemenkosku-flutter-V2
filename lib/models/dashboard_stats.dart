// lib/models/dashboard_stats.dart
class DashboardStats {
  final int totalProperti;
  final int totalKamar;
  final int kamarTerisi;
  final int kamarTersedia;
  final int tagihanPending;

  DashboardStats({
    required this.totalProperti,
    required this.totalKamar,
    required this.kamarTerisi,
    required this.kamarTersedia,
    required this.tagihanPending,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      totalProperti: json['totalProperti'] ?? 0,
      totalKamar: json['totalKamar'] ?? 0,
      kamarTerisi: json['kamarTerisi'] ?? 0,
      kamarTersedia: json['kamarTersedia'] ?? 0,
      tagihanPending: json['tagihanPending'] ?? 0,
    );
  }
}