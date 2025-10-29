import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/constants/app_color.dart';
import 'text_field_decoration.dart';

class PrimaryTextFormField extends StatelessWidget {
  final String? label;
  final TextEditingController? controller;
  final TextInputAction? textInputAction;
  final TextInputType? textInputType;
  final String? Function(String?)? validation;
  final List<TextInputFormatter>? inputFormatters;

  const PrimaryTextFormField({
    super.key,
    this.label,
    this.controller,
    this.textInputAction,
    this.textInputType,
    this.validation,
    this.inputFormatters,
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
      inputFormatters: inputFormatters,
      validator: validation,
      decoration: textFieldMainDecoration(
        hintText: label ?? '',
        labelText: label ?? '',
        labelStyle: const TextStyle(fontSize: 14, color: AppColors.textLight),
      ),
    );
  }
}
