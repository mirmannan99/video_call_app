import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:video_call_app/features/video_call/presentation/video_call_screen.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider();
});

class AuthProvider extends ChangeNotifier {
  final String dummyEmail = 'test@example.com';
  final String dummyPassword = 'password123';
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController(
    text: "test@example.com",
  );

  final TextEditingController passwordController = TextEditingController(
    text: "password123",
  );

  bool showPassword = false;

  void toggleShowPassword() {
    showPassword = !showPassword;
    notifyListeners();
  }

  void submit(BuildContext context) {
    if (formKey.currentState?.validate() ?? false) {
      if (emailController.text.trim() == dummyEmail &&
          passwordController.text.trim() == dummyPassword) {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const VideoCallScreen()));
      } else {
        log('Authentication failed: Invalid email or password');
      }
    }
  }
}
