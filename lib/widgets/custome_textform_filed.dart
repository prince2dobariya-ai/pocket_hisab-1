import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_hisab/constants/app_theme.dart';

class CustomTextField extends StatelessWidget {
  final String labelText;
  final String? hintText;
  final int? maxLine, minLine, maxLength;
  final TextInputType? keyboardType;
  final bool isRequired;
  final bool? readOnly;
  final TextEditingController controller;
  final void Function(String)? onChange;
  final void Function()? onTap;
  final IconButton? suffixIcon;
  final bool? autoFocus;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextField({
    super.key,
    required this.labelText,
    this.hintText,
    this.keyboardType,
    this.isRequired = false,
    this.readOnly = false,
    this.maxLine = 1,
    this.minLine = 1,
    this.maxLength,
    this.onChange,
    this.onTap,
    required this.controller,
    this.suffixIcon,
    this.autoFocus,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      autofocus: autoFocus ?? false,
      controller: controller,
      minLines: minLine,
      maxLines: maxLine,
      readOnly: readOnly ?? false,
      onChanged: onChange,
      maxLength: maxLength,
      onTapOutside: (event) {
        FocusScope.of(context).unfocus();
      },
      inputFormatters: inputFormatters,
      textInputAction: TextInputAction.next,
      onTap: onTap,
      decoration: InputDecoration(
        suffixIcon: suffixIcon,
        labelText: labelText,
        hintText: hintText,
        labelStyle: const TextStyle(fontSize: 14),
        hintStyle: TextStyle(color: Colors.grey[500]),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
      keyboardType: keyboardType,
      validator: (value) {
        if (isRequired && (value == null || value.isEmpty)) {
          return '${labelText.replaceAll('*', '').toLowerCase()} is required';
        } else if (keyboardType == TextInputType.emailAddress) {
          if (value?.trim().isNotEmpty ?? false) {
            final bool emailValid = RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
            ).hasMatch(value ?? '');
            return emailValid ? null : "Enter valid Email Address";
          }
          return null;
        } else if (keyboardType == TextInputType.phone) {
          if (value!.length < 10) {
            return 'Contact Number at least 10 digit!';
          }
        }
        return null;
      },
    );
  }
}
