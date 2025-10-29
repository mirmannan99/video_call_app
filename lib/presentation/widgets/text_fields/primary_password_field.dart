import 'package:flutter/material.dart';

import '../../../style/app_color.dart';
import 'text_field_decoration.dart';

class PrimaryPasswordFormField extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final String? Function(String?)? validation;
  final void Function()? onShowPassword;
  final bool isObscure;

  const PrimaryPasswordFormField({
    super.key,
    this.label,
    this.controller,
    this.textInputAction,
    this.textInputType,
    this.validation,
    this.onShowPassword,
    required this.isObscure,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      style: const TextStyle(
        fontSize: 18,
        color: AppColors.textDark,
        height: 1,
        fontWeight: FontWeight.w500,
      ),
      controller: controller,
      textInputAction: textInputAction,
      keyboardType: textInputType,
      cursorColor: AppColors.primary,
      validator: validation,
      decoration: passwordFieldMainDecoration(
        hintText: label!,
        labelText: label!,
        labelStyle: const TextStyle(fontSize: 14, color: AppColors.textLight),
        isObscure: isObscure,
        onShowPassword: onShowPassword ?? (() {}),
      ),
    );
  }
}
