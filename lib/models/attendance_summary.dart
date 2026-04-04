class AttendanceSummary {
  const AttendanceSummary({
    required this.todayPresent,
    required this.lateArrivals,
    required this.remoteEmployees,
    required this.attendanceRate,
  });

  final int todayPresent;
  final int lateArrivals;
  final int remoteEmployees;
  final int attendanceRate;

  factory AttendanceSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceSummary(
      todayPresent: json['todayPresent'] as int? ?? 0,
      lateArrivals: json['lateArrivals'] as int? ?? 0,
      remoteEmployees: json['remoteEmployees'] as int? ?? 0,
      attendanceRate: json['attendanceRate'] as int? ?? 0,
    );
  }
}
