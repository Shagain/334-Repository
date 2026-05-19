/// Australia/Sydney wall clock and UTC helpers (AEST UTC+10 / AEDT UTC+11).
class SydneyTime {
  SydneyTime._();

  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  static DateTime nowUtc() => DateTime.now().toUtc();

  /// Current instant as Sydney wall-clock components (isUtc: false).
  static DateTime nowSydney() => fromUtc(nowUtc());

  /// Build a UTC instant from Sydney local date/time.
  static DateTime sydneyDateTime(int year, int month, int day, int hour, [int minute = 0]) {
    return toUtc(DateTime(year, month, day, hour, minute));
  }

  /// UTC → Sydney wall clock (for display).
  static DateTime fromUtc(DateTime utc) {
    final u = utc.toUtc();
    final offset = _offsetMinutes(u);
    final ms = u.millisecondsSinceEpoch + offset * 60000;
    final t = DateTime.fromMillisecondsSinceEpoch(ms, isUtc: true);
    return DateTime(t.year, t.month, t.day, t.hour, t.minute, t.second);
  }

  /// Sydney wall clock → UTC (for storage).
  static DateTime toUtc(DateTime sydneyWall) {
    var utc = DateTime.utc(
      sydneyWall.year,
      sydneyWall.month,
      sydneyWall.day,
      sydneyWall.hour,
      sydneyWall.minute,
      sydneyWall.second,
    ).subtract(const Duration(hours: 10));
    for (var i = 0; i < 2; i++) {
      final offset = _offsetMinutes(utc);
      utc = DateTime.utc(
        sydneyWall.year,
        sydneyWall.month,
        sydneyWall.day,
        sydneyWall.hour,
        sydneyWall.minute,
        sydneyWall.second,
      ).subtract(Duration(minutes: offset));
    }
    return utc;
  }

  static String formatTime(DateTime utcInstant) {
    final s = fromUtc(utcInstant.toUtc());
    final hour = s.hour == 0 ? 12 : (s.hour > 12 ? s.hour - 12 : s.hour);
    final minute = s.minute.toString().padLeft(2, '0');
    final suffix = s.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $suffix';
  }

  static String formatSessionRange(DateTime startUtc, DateTime endUtc) {
    final start = fromUtc(startUtc.toUtc());
    final month = _months[start.month - 1];
    return '$month ${start.day}, ${formatTime(startUtc)} - ${formatTime(endUtc)}';
  }

  /// e.g. "Today" / "Tomorrow" / "Mon 19 May" in Sydney.
  static String formatDayLabel(DateTime utcInstant) {
    final s = fromUtc(utcInstant.toUtc());
    final today = nowSydney();
    final tomorrow = DateTime(today.year, today.month, today.day + 1);

    if (s.year == today.year && s.month == today.month && s.day == today.day) {
      return 'Today';
    }
    if (s.year == tomorrow.year && s.month == tomorrow.month && s.day == tomorrow.day) {
      return 'Tomorrow';
    }
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[s.weekday - 1]} ${s.day} ${_months[s.month - 1]}';
  }

  static String formatLongDate(DateTime sydneyWall) {
    const weekdays = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday',
    ];
    return '${weekdays[sydneyWall.weekday - 1]}, ${sydneyWall.day} '
        '${_months[sydneyWall.month - 1]} ${sydneyWall.year}';
  }

  static String timezoneAbbreviation([DateTime? utcInstant]) {
    final u = (utcInstant ?? nowUtc()).toUtc();
    return _isDaylightSaving(u) ? 'AEDT' : 'AEST';
  }

  static int _offsetMinutes(DateTime utc) {
    return _isDaylightSaving(utc.toUtc()) ? 11 * 60 : 10 * 60;
  }

  /// Australian DST: first Sun Oct 02:00 AEST → first Sun Apr 03:00 AEDT.
  static bool _isDaylightSaving(DateTime utc) {
    final y = utc.year;
    final dstStart = _dstStartUtc(y);
    final dstEnd = _dstEndUtc(y);

    if (dstStart.isBefore(dstEnd)) {
      return !utc.isBefore(dstStart) && utc.isBefore(dstEnd);
    }
    // Southern hemisphere: DST spans Oct–Apr across calendar years.
    return !utc.isBefore(dstStart) || utc.isBefore(dstEnd);
  }

  static DateTime _dstStartUtc(int year) {
    final firstSunOct = _firstSunday(year, 10);
    // 02:00 AEST = UTC+10 → previous day 16:00 UTC
    return DateTime.utc(firstSunOct.year, firstSunOct.month, firstSunOct.day - 1, 16);
  }

  static DateTime _dstEndUtc(int year) {
    final firstSunApr = _firstSunday(year, 4);
    // 03:00 AEDT → 02:00 AEST: 02:00 AEST = UTC+10
    return DateTime.utc(firstSunApr.year, firstSunApr.month, firstSunApr.day, 16);
  }

  static DateTime _firstSunday(int year, int month) {
    var day = DateTime(year, month, 1);
    while (day.weekday != DateTime.sunday) {
      day = day.add(const Duration(days: 1));
    }
    return day;
  }
}
