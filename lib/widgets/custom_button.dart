import 'package:flutter/material.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/widgets/custom_text.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const CustomButton({super.key, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: .infinity,
        padding: .symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: .circular(12),
          color: AppColors.primary,
        ),
        child: Center(child: AppText(title, color: Colors.white)),
      ),
    );
  }
}
