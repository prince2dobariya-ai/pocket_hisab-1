import 'package:flutter/material.dart';
import 'package:pocket_hisab/constants/app_theme.dart';

class AppText extends StatelessWidget {
  final String text;

  final double? size;
  final FontWeight? fontWeight;
  final Color? color;
  final int? maxLines;
  final TextAlign? textAlign;

  const AppText(
      this.text, {
        super.key,
        this.size,
        this.fontWeight,
        this.color,
        this.maxLines,
        this.textAlign,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines,
      textAlign: textAlign,

      overflow: TextOverflow.ellipsis,

      style: TextStyle(
        fontSize: size ?? 16,
        fontWeight: fontWeight ?? FontWeight.w500,
        color: color ?? AppColors.textDark,
        fontFamily: 'Poppins',
      ),
    );
  }
}


class HeadingText extends StatelessWidget {
  final String text;
  final Color? color;

  const HeadingText(
      this.text, {
        super.key,
        this.color,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: color ?? AppColors.textDark,
        fontFamily: 'Poppins',
      ),
    );
  }
}


class PriceText extends StatelessWidget {
  final double amount;
  final Color? color;
  final double? size;

  const PriceText(
      this.amount, {
        super.key,
        this.color,
        this.size,
      });

  @override
  Widget build(BuildContext context) {
    return Text(
      "₹ ${amount.toStringAsFixed(0)}",

      style: TextStyle(
        fontSize: size ?? 20,
        fontWeight: FontWeight.bold,
        color: color ?? AppColors.primary,
        fontFamily: 'Poppins',
      ),
    );
  }
}