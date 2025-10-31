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

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

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
        clearControllers();
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const UserListScreen()));
      } else {
        SnackBar snackBar = const SnackBar(
          content: Text(
            'Invalid email or password',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
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

  clearControllers() {
    emailController.clear();
    passwordController.clear();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
