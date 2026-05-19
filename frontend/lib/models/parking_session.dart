import '../utils/sydney_time.dart';

enum SessionStatus { active, upcoming, history }

class ParkingSession {
  const ParkingSession({
    required this.id,
    required this.zoneTitle,
    required this.vehiclePlate,
    required this.driverName,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.rate = 4.5,
  });

  final String id;
  final String zoneTitle;
  final String vehiclePlate;
  final String driverName;
  /// Stored as UTC.
  final DateTime startTime;
  /// Stored as UTC.
  final DateTime endTime;
  final SessionStatus status;
  final double rate;

  int get hours {
    final diff = endTime.toUtc().difference(startTime.toUtc()).inMinutes;
    return diff <= 0 ? 1 : ((diff + 59) ~/ 60);
  }

  double get total => hours * rate;

  /// Derived from Sydney clock vs session start/end.
  SessionStatus get effectiveStatus {
    final now = SydneyTime.nowUtc();
    final start = startTime.toUtc();
    final end = endTime.toUtc();
    if (now.isBefore(start)) return SessionStatus.upcoming;
    if (now.isAfter(end)) return SessionStatus.history;
    return SessionStatus.active;
  }

  String get statusLabel {
    switch (effectiveStatus) {
      case SessionStatus.active:
        return 'ACTIVE';
      case SessionStatus.upcoming:
        return 'UPCOMING';
      case SessionStatus.history:
        return 'HISTORY';
    }
  }

  String get dateTimeLine =>
      '${SydneyTime.formatSessionRange(startTime, endTime)} ${SydneyTime.timezoneAbbreviation(startTime)}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'zoneTitle': zoneTitle,
        'vehiclePlate': vehiclePlate,
        'driverName': driverName,
        'startTime': startTime.toUtc().toIso8601String(),
        'endTime': endTime.toUtc().toIso8601String(),
        'status': status.name,
        'rate': rate,
      };

  factory ParkingSession.fromJson(Map<String, dynamic> json) {
    return ParkingSession(
      id: json['id'] as String? ?? '',
      zoneTitle: json['zoneTitle'] as String? ?? '',
      vehiclePlate: json['vehiclePlate'] as String? ?? '',
      driverName: json['driverName'] as String? ?? '',
      startTime: DateTime.parse(json['startTime'] as String).toUtc(),
      endTime: DateTime.parse(json['endTime'] as String).toUtc(),
      status: SessionStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => SessionStatus.upcoming,
      ),
      rate: (json['rate'] as num?)?.toDouble() ?? 4.5,
    );
  }

  ParkingSession copyWith({
    String? zoneTitle,
    DateTime? startTime,
    DateTime? endTime,
    SessionStatus? status,
  }) {
    return ParkingSession(
      id: id,
      zoneTitle: zoneTitle ?? this.zoneTitle,
      vehiclePlate: vehiclePlate,
      driverName: driverName,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      rate: rate,
    );
  }
}
