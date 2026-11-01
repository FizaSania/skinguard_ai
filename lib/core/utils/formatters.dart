import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final _day = DateFormat('dd MMM');
  static final _full = DateFormat('dd MMM yyyy');
  static final _fullTime = DateFormat('dd MMM yyyy, HH:mm');

  static String dayMonth(DateTime d) => _day.format(d);
  static String date(DateTime d) => _full.format(d);
  static String dateTime(DateTime d) => _fullTime.format(d);
}
