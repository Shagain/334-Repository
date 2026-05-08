class Vehicle {
  final int vehicleId;
  final String licensePlate;
  final int? userId;

  const Vehicle({
    required this.vehicleId,
    required this.licensePlate,
    this.userId,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      vehicleId: json['vehicleID'] as int,
      licensePlate: json['licensePlate'] as String,
      userId: json['userID'] as int?,
    );
  }
}