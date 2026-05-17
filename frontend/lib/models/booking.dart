class BookingModel {
  final int? bookingID;
  final String zone;
  final String vehicle;
  final int hours;
  final double rate;

  const BookingModel({
    this.bookingID,
    required this.zone,
    required this.vehicle,
    required this.hours,
    required this.rate,
  });

  double get total => hours * rate;

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingID: json['bookingID'] as int?,
      zone: json['zone'] as String? ?? '',
      vehicle: json['vehicle'] as String? ?? '',
      hours: json['hours'] as int? ?? 1,
      rate: (json['rate'] as num?)?.toDouble() ?? 4.5,
    );
  }
}