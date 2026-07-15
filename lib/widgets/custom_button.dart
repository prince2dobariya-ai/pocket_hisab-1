import 'package:flutter/material.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/widgets/custom_text.dart';

class CustomButton extends StatelessWidget {
  final String title;
  final Color? color;
  final VoidCallback onTap;

  const CustomButton({
    super.key,
    required this.title,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color ?? context.themePrimary),
        child: Center(child: AppText(title, color: Colors.white)),
      ),
    );
  }
}
