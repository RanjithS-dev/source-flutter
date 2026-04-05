class WorkLog {
  const WorkLog({
    required this.id,
    required this.workDate,
    required this.landName,
    required this.coconutCount,
    required this.bagCount,
    required this.assignmentCount,
  });

  final String id;
  final String workDate;
  final String landName;
  final int coconutCount;
  final int bagCount;
  final int assignmentCount;

  factory WorkLog.fromJson(Map<String, dynamic> json) {
    final land = json['land'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final assignments = json['assignments'] as List<dynamic>? ?? <dynamic>[];
    return WorkLog(
      id: json['id']?.toString() ?? '',
      workDate: json['work_date'] as String? ?? '',
      landName: land['name'] as String? ?? '',
      coconutCount: json['coconut_count'] as int? ?? 0,
      bagCount: json['bag_count'] as int? ?? 0,
      assignmentCount: assignments.length,
    );
  }
}
