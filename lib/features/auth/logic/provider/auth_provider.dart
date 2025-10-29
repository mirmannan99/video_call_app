import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:video_call_app/features/users/presentation/user_list_screen.dart';

import '../../../../data/hive/hive_helper.dart';

final authProvider = ChangeNotifierProvider<AuthProvider>((ref) {
  return AuthProvider();
});

class AuthProvider extends ChangeNotifier {
  final String dummyEmail = 'test@example.com';
  final String dummyPassword = 'password123';

  final TextEditingController emailController = TextEditingController(
    text: "test@example.com",
  );

  final TextEditingController passwordController = TextEditingController(
    text: "password123",
  );

  bool showPassword = false;
  bool isLoading = false;

  void toggleShowPassword() {
    showPassword = !showPassword;
    notifyListeners();
  }

  void toggleLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  void submit(BuildContext context) async {
    try {
      if (emailController.text.trim() == dummyEmail &&
          passwordController.text.trim() == dummyPassword) {
        toggleLoading();
        await Future.delayed(const Duration(seconds: 2));
        await HiveHelper.saveAccessToken(accessToken: "dummy_access_token");
        toggleLoading();
        if (!context.mounted) return;
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const UserListScreen()));
      } else {
        log('Authentication failed: Invalid email or password');
      }
    } catch (e) {
      log('Authentication failed: $e');
      if (isLoading) {
        toggleLoading();
      }
    } finally {
      if (isLoading) {
        toggleLoading();
      }
    }
  }
}
