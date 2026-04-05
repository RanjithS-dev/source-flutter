class LandProductionReportItem {
  const LandProductionReportItem({
    required this.name,
    required this.village,
    required this.totalCoconuts,
  });

  final String name;
  final String village;
  final int totalCoconuts;

  factory LandProductionReportItem.fromJson(Map<String, dynamic> json) {
    return LandProductionReportItem(
      name: json['name'] as String? ?? '',
      village: json['village'] as String? ?? '',
      totalCoconuts: json['totalCoconuts'] as int? ?? 0,
    );
  }
}

class EmployeeWorkReportItem {
  const EmployeeWorkReportItem({
    required this.name,
    required this.assignmentCount,
    required this.department,
  });

  final String name;
  final int assignmentCount;
  final String department;

  factory EmployeeWorkReportItem.fromJson(Map<String, dynamic> json) {
    return EmployeeWorkReportItem(
      name: json['name'] as String? ?? '',
      assignmentCount: json['assignmentCount'] as int? ?? 0,
      department: json['department'] as String? ?? '',
    );
  }
}

class ProfitLossReport {
  const ProfitLossReport({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.totalProfit,
  });

  final double totalRevenue;
  final double totalExpenses;
  final double totalProfit;

  factory ProfitLossReport.fromJson(Map<String, dynamic> json) {
    return ProfitLossReport(
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0,
      totalExpenses: (json['totalExpenses'] as num?)?.toDouble() ?? 0,
      totalProfit: (json['totalProfit'] as num?)?.toDouble() ?? 0,
    );
  }
}
