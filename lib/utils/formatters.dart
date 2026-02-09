import 'package:intl/intl.dart';

class Formatters {
  static String compactNumber(int value) {
    return NumberFormat.compact().format(value);
  }
}
