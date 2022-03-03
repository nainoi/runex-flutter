import 'package:intl/intl.dart';

class DateTimeUtils {
  static String getMonth(DateTime dateTime) {
    var formatter = DateFormat('MMM');
    return formatter.format(dateTime);
  }

  static String getDayOfMonth(DateTime dateTime) {
    var formatter = DateFormat('dd');
    return formatter.format(dateTime);
  }

  static String getMonthAndYear(DateTime dateTime) {
    var formatter = DateFormat('MMMM yyyy');
    return formatter.format(dateTime);
  }

  static String getFullDate(DateTime dateTime) {
    var formatter = DateFormat('dd MMM, yyyy');
    return formatter.format(dateTime);
  }

  static String getFullDateAndFullTime(DateTime dateTime) {
    var formatter = DateFormat('dd MMM, yyyy');
    var timeFormatter = DateFormat('Hm');
    return formatter.format(dateTime) + " ${timeFormatter.format(dateTime)}";
  }

  static String getDayOfWeek(DateTime dateTime) {
    var formatter = DateFormat('EEEE');
    return formatter.format(dateTime);
  }

  static String getFullTime(DateTime dateTime) {
    var formatter = DateFormat('Hms');
    return formatter.format(dateTime);
  }

  static String getFullDateInNumber(DateTime dateTime) {
    var formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(dateTime);
  }

  static String getFullTimeFromSecond(int seconds) {
    return '${(Duration(seconds: seconds))}'.split('.')[0].padLeft(8, '0');
  }
}
