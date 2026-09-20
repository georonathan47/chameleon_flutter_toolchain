extension DateExtensionX on DateTime {
  // ==========================================
  // 🧮 DATE MATH & HELPERS
  // ==========================================

  // A getter to check if the DateTime is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Cleaner syntax to add days: date.addDays(5)
  DateTime addDays(int days) {
    return add(Duration(days: days));
  }

  /// Cleaner syntax to subtract days: date.subtractDays(3)
  DateTime subtractDays(int days) {
    return subtract(Duration(days: days));
  }

  /// Correctly shifts months forward, handling variable month lengths
  DateTime addMonths(int months) {
    var newYear = year;
    var newMonth = month + months;

    while (newMonth > 12) {
      newYear++;
      newMonth -= 12;
    }
    while (newMonth < 1) {
      newYear--;
      newMonth += 12;
    }

    // Handle month-end overflow (e.g., Jan 31 + 1 month becomes Feb 28/29)
    final daysInNewMonth = DateTime(newYear, newMonth + 1, 0).day;
    final newDay = day > daysInNewMonth ? daysInNewMonth : day;

    return DateTime(
      newYear,
      newMonth,
      newDay,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  /// Correctly shifts months forward, handling variable month lengths
  DateTime subtractMonths(int months) {
    var newYear = year;
    var newMonth = month + months;

    while (newMonth > 12) {
      newYear++;
      newMonth -= 12;
    }
    while (newMonth < 1) {
      newYear--;
      newMonth += 12;
    }

    // Handle month-end overflow (e.g., Jan 31 + 1 month becomes Feb 28/29)
    final daysInNewMonth = DateTime(newYear, newMonth + 1, 0).day;
    final newDay = day > daysInNewMonth ? daysInNewMonth : day;

    return DateTime(
      newYear,
      newMonth,
      newDay,
      hour,
      minute,
      second,
      millisecond,
      microsecond,
    );
  }

  /// Shifts the calendar year forward or backward
  DateTime addYears(int years) {
    return addMonths(years * 12);
  }

  /// Shifts the calendar year backward
  DateTime subtractYears(int years) {
    return addYears(-years);
  }

  /// Calculates exact age in years based on this birthdate
  int get age {
    final now = DateTime.now();
    var age = now.year - year;
    if (now.month < month || (now.month == month && now.day < day)) {
      age--;
    }
    return age;
  }

  /// Returns the total number of days (28, 29, 30, or 31) for that month
  int get daysInMonth {
    // Setting day to 0 points to the last day of the previous month
    return DateTime(year, month + 1, 0).day;
  }

  // ==========================================
  // 📝 FORMATTING & STRING GETTERS
  // ==========================================

  /// Returns full name of the day (e.g., "Monday")
  String get dayName {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return days[weekday - 1];
  }

  /// Returns short name of the day (e.g., "Mon")
  String get dayNameShort {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  /// Returns full name of the month (e.g., "January")
  String get monthName {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[month - 1];
  }

  /// Returns short name of the month (e.g., "Jan")
  String get monthNameShort {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }

  /// Returns YYYY-MM-DD layout without the time stamp
  String get toIsoDateString {
    final y = year.toString().padLeft(4, '0');
    final m = month.toString().padLeft(2, '0');
    final d = day.toString().padLeft(2, '0');
    return '$d-$m-$y';
  }

  /// Formats date for HTTP header requirements (RFC 1123 format)
  String get toHttpHeaderDate {
    final utcDate = toUtc();
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final weekday = weekdays[utcDate.weekday - 1];
    final day = utcDate.day.toString().padLeft(2, '0');
    final mth = months[utcDate.month - 1];
    final year = utcDate.year;
    final hr = utcDate.hour.toString().padLeft(2, '0');
    final min = utcDate.minute.toString().padLeft(2, '0');
    final sec = utcDate.second.toString().padLeft(2, '0');

    return '$weekday, $day $mth $year $hr:$min:$sec GMT';
  }
}
