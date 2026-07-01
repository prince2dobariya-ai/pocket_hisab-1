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
  final tomorrow = today.add(const Duration(days: 1));
  final yesterday = today.subtract(const Duration(days: 1));
  final inputDate = DateTime(date.year, date.month, date.day);

  if (inputDate == today) {
    return "Today, ${DateFormat('MMM dd').format(date)}";
  } else if (inputDate == yesterday) {
    return "Yesterday, ${DateFormat('MMM dd').format(date)}";
  } else if (inputDate == tomorrow) {
    return "Tomorrow, ${DateFormat('MMM dd').format(date)}";
  } else {
    return DateFormat('MMM dd, yyyy').format(date);
  }
}
