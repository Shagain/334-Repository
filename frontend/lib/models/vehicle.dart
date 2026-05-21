class Vehicle {
  final int? vehicleID;
  final String licensePlate;
  final int? userID;

  const Vehicle({
    this.vehicleID,
    required this.licensePlate,
    this.userID,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleID: json['vehicleID'] as int?,
      licensePlate: json['licensePlate'] as String? ?? '',
      userID: json['userID'] as int?,
    );
  }
}