class Employee {
  const Employee({
    required this.id,
    required this.employeeCode,
    required this.fullName,
    required this.department,
    required this.designation,
    required this.email,
    required this.phoneNumber,
    required this.joinedOn,
  });

  final String id;
  final String employeeCode;
  final String fullName;
  final String department;
  final String designation;
  final String email;
  final String phoneNumber;
  final DateTime joinedOn;

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as String? ?? '',
      employeeCode: json['employeeCode'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      department: json['department'] as String? ?? '',
      designation: json['designation'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      joinedOn: DateTime.tryParse(json['joinedOn'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'employeeCode': employeeCode,
      'fullName': fullName,
      'department': department,
      'designation': designation,
      'email': email,
      'phoneNumber': phoneNumber,
      'joinedOn': joinedOnLabel,
    };
  }

  String get joinedOnLabel => _dateOnly(joinedOn);

  Employee copyWith({
    String? id,
    String? employeeCode,
    String? fullName,
    String? department,
    String? designation,
    String? email,
    String? phoneNumber,
    DateTime? joinedOn,
  }) {
    return Employee(
      id: id ?? this.id,
      employeeCode: employeeCode ?? this.employeeCode,
      fullName: fullName ?? this.fullName,
      department: department ?? this.department,
      designation: designation ?? this.designation,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      joinedOn: joinedOn ?? this.joinedOn,
    );
  }
}

String _dateOnly(DateTime value) {
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');
  return '${value.year}-$month-$day';
}
