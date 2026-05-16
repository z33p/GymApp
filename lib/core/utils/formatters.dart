import 'package:intl/intl.dart';

class Formatters {
  const Formatters._();

  static final DateFormat _dateTime = DateFormat('EEE, MMM d • h:mm a');
  static final DateFormat _shortDate = DateFormat('MMM d');

  static String dateTime(DateTime value) => _dateTime.format(value.toLocal());
  static String shortDate(DateTime value) => _shortDate.format(value.toLocal());

  static String duration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  static String? calories(double? kcal) => kcal == null ? null : '${kcal.round()} kcal';
  static String? distanceMeters(double? meters) {
    if (meters == null) return null;
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
    return '${meters.round()} m';
  }
}
