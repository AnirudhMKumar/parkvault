import 'package:intl/intl.dart';

class DateUtils {
  static String formatDateTime(String dateTimeStr) {
    try {
      final dt = DateTime.parse(dateTimeStr);
      return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
    } catch (e) {
      return dateTimeStr;
    }
  }

  static String formatDate(String dateStr) {
    try {
      final dt = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(dt);
    } catch (e) {
      return dateStr;
    }
  }

  static String formatDuration(int minutes) {
    if (minutes < 60) {
      return '${minutes}m';
    }
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    if (hours < 24) {
      return '${hours}h ${mins}m';
    }
    final days = hours ~/ 24;
    final remainingHours = hours % 24;
    return '${days}d ${remainingHours}h';
  }

  static String getCurrentDateTime() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
  }

  static String getCurrentDate() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  static int calculateDurationMinutes(String entryTime, String? exitTime) {
    try {
      final entry = DateTime.parse(entryTime);
      final exit = exitTime != null ? DateTime.parse(exitTime) : DateTime.now();
      return exit.difference(entry).inMinutes;
    } catch (e) {
      return 0;
    }
  }
}
