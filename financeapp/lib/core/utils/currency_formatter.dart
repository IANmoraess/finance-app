import 'package:intl/intl.dart';

abstract final class CurrencyFormatter {
  static final _brl     = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 2);
  static final _compact = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$', decimalDigits: 0);

  static String format(double value)        => _brl.format(value);
  static String formatCompact(double value) => _compact.format(value);

  static String signed(double value, {required bool isCredit}) {
    final sign = isCredit ? '+ ' : '- ';
    return '$sign${format(value.abs())}';
  }
}
