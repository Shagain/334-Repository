import '../utils/sydney_time.dart';

class Booking {
  final String zone;
  final String vehicle;
  final int hours;
  final double rate;
  final String paymentMethod;
  final DateTime paidAt;
  final String driverName;

  const Booking({
    required this.zone,
    required this.vehicle,
    required this.hours,
    required this.rate,
    required this.paymentMethod,
    required this.paidAt,
    this.driverName = '',
  });

  double get total => hours * rate;

  String get totalText => '\$${total.toStringAsFixed(2)}';

  String get durationText => "$hours ${hours == 1 ? 'hour' : 'hours'}";

  String get dateText => SydneyTime.formatDayLabel(paidAt);

  String get timeText {
    final end = paidAt.toUtc().add(Duration(hours: hours));
    return '${SydneyTime.formatTime(paidAt)} - ${SydneyTime.formatTime(end)} '
        '${SydneyTime.timezoneAbbreviation(paidAt)}';
  }
}

class AppState {
  static final List<Booking> paidBookings = <Booking>[];

  static void addPaidBooking(Booking booking) {
    paidBookings.insert(0, booking);
  }
}
