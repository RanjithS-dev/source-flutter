class DashboardSummary {
  const DashboardSummary({
    required this.totalLands,
    required this.activeWorkers,
    required this.dailyHarvest,
    required this.totalRevenue,
  });

  final int totalLands;
  final int activeWorkers;
  final int dailyHarvest;
  final double totalRevenue;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalLands: json['totalLands'] as int? ?? 0,
      activeWorkers: json['activeWorkers'] as int? ?? 0,
      dailyHarvest: json['dailyHarvest'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
    );
  }
}
