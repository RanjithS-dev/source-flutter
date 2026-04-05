class Vehicle {
  const Vehicle({
    required this.id,
    required this.registrationNumber,
    required this.vehicleType,
  });

  final String id;
  final String registrationNumber;
  final String vehicleType;

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id']?.toString() ?? '',
      registrationNumber: json['registration_number'] as String? ?? '',
      vehicleType: json['vehicle_type'] as String? ?? '',
    );
  }
}
