import 'package:flutter/material.dart';
import 'package:get/get.dart';

void showCustomSnackbar(
  String title,
  String message, {
  Color? backgroundColor,
  Color? colorText,
  Duration? duration,
  dynamic snackPosition,
  Widget? icon,
}) {
  final context = Get.context;
  if (context == null) return;

  final isError =
      title.toLowerCase().contains('error') ||
      message.toLowerCase().contains('fail') ||
      message.toLowerCase().contains('insufficient');
  final isSuccess =
      title.toLowerCase().contains('success') ||
      message.toLowerCase().contains('success') ||
      title.toLowerCase().contains('info') ||
      title.toLowerCase().contains('deleted') ||
      title.toLowerCase().contains('welcome');

  final isDark = Theme.of(context).brightness == Brightness.dark;

  final resolvedBgColor =
      backgroundColor ??
      (isError
          ? (isDark ? const Color(0xFF2C1E1E) : Colors.red.shade50)
          : (isSuccess
                ? (isDark ? const Color(0xFF1E2C1E) : Colors.green.shade50)
                : (isDark ? Colors.grey.shade900 : Colors.white)));

  final resolvedTextColor =
      colorText ??
      (isError
          ? (isDark ? Colors.red.shade200 : Colors.red.shade900)
          : (isSuccess
                ? (isDark ? Colors.green.shade200 : Colors.green.shade900)
                : (isDark ? Colors.white : Colors.black87)));

  final resolvedSubTextColor =
      colorText?.withValues(alpha: 0.8) ??
      (isError
          ? (isDark ? Colors.red.shade100 : Colors.red.shade700)
          : (isSuccess
                ? (isDark ? Colors.green.shade100 : Colors.green.shade700)
                : (isDark ? Colors.white70 : Colors.black54)));

  final resolvedIcon =
      icon ??
      Icon(
        isError
            ? Icons.error_outline_rounded
            : (isSuccess
                  ? Icons.check_circle_outline_rounded
                  : Icons.info_outline_rounded),
        color: isError
            ? (isDark ? Colors.red.shade300 : Colors.red)
            : (isSuccess
                  ? (isDark ? Colors.green.shade300 : Colors.green)
                  : (isDark ? Colors.blue.shade300 : Colors.blue)),
        size: 24,
      );

  final borderColor = isError
      ? (isDark
            ? Colors.red.shade900.withValues(alpha: 0.5)
            : Colors.red.shade200)
      : (isSuccess
            ? (isDark
                  ? Colors.green.shade900.withValues(alpha: 0.5)
                  : Colors.green.shade200)
            : (isDark ? Colors.grey.shade800 : Colors.grey.shade300));

  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          resolvedIcon,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: resolvedTextColor,
                    fontSize: 14,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: TextStyle(
                    color: resolvedSubTextColor,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: resolvedBgColor,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: borderColor, width: 1),
      ),
      duration: duration ?? const Duration(seconds: 3),
      elevation: 4,
    ),
  );
}
