import 'package:intl/intl.dart';

class CurrencyHelper {
  static String format(double amount) {
    return NumberFormat.currency(
      locale: 'en_IN',
      symbol: '₹ ',
      decimalDigits: 0,
    ).format(amount);
  }
}

String getDateTitle(DateTime date) {
  final now = DateTime.now();

  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));

  if (date == today) {
    return "Today, ${DateFormat('MMMM dd').format(date)}";
  } else if (date == yesterday) {
    return "Yesterday";
  } else {
    return DateFormat('MMMM dd, yyyy').format(date);
  }
}