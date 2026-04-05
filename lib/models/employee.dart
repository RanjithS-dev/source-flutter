class Employee {
  const Employee({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.role,
    required this.department,
    required this.designation,
    required this.email,
    required this.phoneNumber,
    required this.dailyWage,
    required this.joinedOn,
    required this.isActive,
    required this.notes,
  });

  final String id;
  final String employeeCode;
  final String fullName;
  final String role;
  final String department;
  final String designation;
  final String email;
  final String phoneNumber;
  final double dailyWage;
  final DateTime joinedOn;
  final bool isActive;
  final String notes;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id']?.toString() ?? '',
      employeeCode: json['employee_code'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      role: json['role'] as String? ?? 'worker',
      department: json['department'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      dailyWage: (json['daily_wage'] as num?)?.toDouble() ?? 0,
      joinedOn: DateTime.tryParse(json['joined_on'] as String? ?? '') ??
          DateTime.now(),
      isActive: json['is_active'] as bool? ?? true,
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'employee_code': employeeCode,
      'full_name': fullName,
      'role': role,
      'department': department,
      'designation': designation,
      'email': email,
      'phone_number': phoneNumber,
      'daily_wage': dailyWage,
      'joined_on': joinedOnLabel,
      'is_active': isActive,
      'notes': notes,
    };
  }

  String get joinedOnLabel => _dateOnly(joinedOn);

  Employee copyWith({
    String? id,
    String? employeeCode,
    String? fullName,
    String? role,
    String? department,
    String? designation,
    String? email,
    String? phoneNumber,
    double? dailyWage,
    DateTime? joinedOn,
    bool? isActive,
    String? notes,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeCode: employeeCode ?? this.employeeCode,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dailyWage: dailyWage ?? this.dailyWage,
      joinedOn: joinedOn ?? this.joinedOn,
      isActive: isActive ?? this.isActive,
      notes: notes ?? this.notes,
    );
  }
}

String _dateOnly(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
