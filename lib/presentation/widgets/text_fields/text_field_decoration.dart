import 'package:flutter/material.dart';

import '../../../style/app_color.dart';
import '../dimension.dart';

InputDecoration textFieldMainDecoration({
  required String hintText,
  Icon? icon,
  required String labelText,
  TextStyle? labelStyle,
}) {
  const defaultLabelStyle = TextStyle(fontSize: 14);
  final updatedLabelStyle =
      labelStyle?.merge(
        TextStyle(
          fontSize: defaultLabelStyle.fontSize,
          color: AppColors.primary,
        ),
      ) ??
      defaultLabelStyle;

  return InputDecoration(
    prefixIcon: icon,
    filled: true,
    fillColor: Colors.transparent,
    hintText: hintText,
    counterText: '',
    labelText: labelText,
    labelStyle: updatedLabelStyle,
    hintStyle: const TextStyle(fontSize: 14),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.textDark),
      borderRadius: Dimensions.defaultBorderRadius,
    ),
    border: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.textDark),
      borderRadius: Dimensions.defaultBorderRadius,
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: AppColors.accent.withOpacity(0.5),
        width: 2,
      ),
      borderRadius: Dimensions.defaultBorderRadius,
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.secondary, width: 2),
      borderRadius: Dimensions.defaultBorderRadius,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
  );
}

InputDecoration passwordFieldMainDecoration({
  required String hintText,
  Icon? icon,
  required String labelText,
  TextStyle? labelStyle,
  required bool isObscure,
  required void Function() onShowPassword,
}) {
  const defaultLabelStyle = TextStyle(fontSize: 14);
  final updatedLabelStyle =
      labelStyle?.merge(
        TextStyle(
          fontSize: defaultLabelStyle.fontSize,
          color: AppColors.primary,
        ),
      ) ??
      defaultLabelStyle;

  return InputDecoration(
    prefixIcon: icon,
    filled: true,
    fillColor: Colors.transparent,
    hintText: hintText,
    counterText: '',
    labelText: labelText,
    labelStyle: updatedLabelStyle,
    hintStyle: const TextStyle(fontSize: 14),
    errorStyle: const TextStyle(
      fontSize: 12,
      color: AppColors.danger,
      height: 0,
      fontWeight: FontWeight.w500,
    ),
    suffixIcon: IconButton(
      color: isObscure ? AppColors.primary : AppColors.secondary,
      icon: Icon(isObscure ? Icons.visibility : Icons.visibility_off),
      onPressed: onShowPassword,
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.textDark),
      borderRadius: Dimensions.defaultBorderRadius,
    ),
    border: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.textDark),
      borderRadius: Dimensions.defaultBorderRadius,
    ),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(
        color: AppColors.danger.withOpacity(0.5),
        width: 2,
      ),
      borderRadius: Dimensions.defaultBorderRadius,
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: const BorderSide(color: AppColors.secondary, width: 2),
      borderRadius: Dimensions.defaultBorderRadius,
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
  );
}
