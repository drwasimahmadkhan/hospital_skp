import 'package:intl/intl.dart';

class AppDateUtils {
  AppDateUtils._();

  static final _day = DateFormat('yyyy-MM-dd');

  static String formatDay(DateTime d) => _day.format(d);

  static DateTime? parseDay(String s) => _day.tryParse(s);

  static String queueDocId(String doctorId, String date) => '${doctorId}_$date';

  static List<DateTime> nextDays(int count, {DateTime? from}) {
    final start = from ?? DateTime.now();
    return List.generate(
      count,
      (i) => DateTime(start.year, start.month, start.day + i),
    );
  }
}