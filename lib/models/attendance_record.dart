class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.employeeCode,
    required this.employeeName,
    required this.department,
    required this.designation,
    required this.date,
    required this.status,
    required this.workedHours,
    required this.checkIn,
    required this.checkOut,
    required this.notes,
  });

  final String id;
  final String employeeId;
  final String employeeCode;
  final String employeeName;
  final String department;
  final String designation;
  final DateTime date;
  final String status;
  final double workedHours;
  final String checkIn;
  final String? checkOut;
  final String? notes;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      id: json['id'] as String? ?? '',
      employeeId: json['employeeId'] as String? ?? '',
      employeeCode: json['employeeCode'] as String? ?? '',
      employeeName: json['employeeName'] as String? ?? '',
      department: json['department'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      status: json['status'] as String? ?? 'present',
      workedHours: (json['workedHours'] as num?)?.toDouble() ?? 0,
      checkIn: json['checkIn'] as String? ?? '',
      checkOut: json['checkOut'] as String?,
      notes: json['notes'] as String?,
    );
  }

  String get dateLabel {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
