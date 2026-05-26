import 'package:intl/intl.dart';

abstract final class DateFormatter {
  static String full(DateTime date) =>
      DateFormat("d 'de' MMMM 'de' yyyy", 'pt_BR').format(date);

  static String monthYear(DateTime date) =>
      DateFormat('MMMM yyyy', 'pt_BR').format(date);

  static String short(DateTime date) =>
      DateFormat('dd/MM/yyyy').format(date);
}
