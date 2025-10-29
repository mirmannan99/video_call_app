import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // singleton class with no instance variable and no constructor method
  static const Color primary = Color(0xFFd32a31);
  static const Color secondary = Color(0xFF272f6c);

  static const Color textDark = Color(0xFF2A3439);
  static const Color textLight = Color(0xFF818181);
  static const Color accent = Color(0xFF9D643E);

  static const Color primaryColor = Color(0xFF007bff);
  static const Color secondaryColor = Color(0xFF6c757d);
  static const Color success = Color(0xFF28a745);
  static const Color danger = Color(0xFFdc3545);
  static const Color warning = Color(0xFFffc107);
  static const Color info = Color(0xFF17a2b8);
  static const Color light = Color(0xFFf8f9fa);
  static const Color dark = Color(0xFF343a40);
  static const Color muted = Color(0xFF6c757d);
  static const Color white = Color(0xFFFFFFFF);

  static const Color shimmerBase = Color.fromARGB(255, 215, 215, 215);
  static const Color shimmerHighlight = Color.fromARGB(255, 201, 201, 201);
}
