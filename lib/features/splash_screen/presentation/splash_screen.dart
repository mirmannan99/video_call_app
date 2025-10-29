import 'package:flutter/material.dart';
import 'package:video_call_app/core/style/app_color.dart';
import 'package:video_call_app/features/auth/presentation/auth_screen.dart';
import 'package:video_call_app/widgets/logo/primary_app_logo.dart';

import '../../../configs/dependency_injection.dart';
import '../../../core/controller/global_naviagtor.dart';
import '../../../data/hive/hive_helper.dart';
import '../../users/presentation/user_list_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _animate = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _animate = true);
    });
    checkLoginStatus();
  }

  checkLoginStatus() async {
    await Future.delayed(const Duration(seconds: 2));
    final isLoggedIn = await HiveHelper.getAuthToken() != null;
    if (mounted) {
      if (isLoggedIn) {
        locator<GlobalNavigator>().navigatorKey.currentState?.push(
          MaterialPageRoute(builder: (_) => const UserListScreen()),
        );
      } else {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const AuthScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primary;
    final onPrimary = AppColors.textDark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withAlpha(100), color.withAlpha(10)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                opacity: _animate ? 1 : 0,
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOut,
                child: Container(
                  width: 220,
                  height: 220,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withAlpha(30),
                        blurRadius: 40,
                        spreadRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),

              AnimatedScale(
                scale: _animate ? 1 : 0.86,
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutBack,
                child: AnimatedOpacity(
                  opacity: _animate ? 1 : 0,
                  duration: const Duration(milliseconds: 650),
                  curve: Curves.easeOut,
                  child: const PrimaryAppLogo(size: 160),
                ),
              ),
              const SizedBox(height: 28),

              SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  backgroundColor: onPrimary.withAlpha(20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
