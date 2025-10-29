import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../widgets/buttons/primary_button.dart';
import '../../../widgets/logo/primary_app_logo.dart';
import '../../../widgets/text_fields/primary_password_field.dart';
import '../../../widgets/text_fields/primay_text_form_fields.dart';
import '../logic/auth_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final authWatch = ref.watch(authProvider);
    final authRead = ref.read(authProvider);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const PrimaryAppLogo(size: 96),
                  const SizedBox(height: 24),
                  PrimaryTextFormField(
                    controller: authWatch.emailController,
                    label: 'Email',
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.emailAddress,
                    inputFormatters: [],
                    validation: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (value.contains(' ')) {
                        return 'Email cannot contain spaces';
                      }
                      final emailReg = RegExp(
                        r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
                      );
                      if (!emailReg.hasMatch(value)) {
                        return 'Enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  PrimaryPasswordFormField(
                    controller: authWatch.passwordController,
                    isObscure: authWatch.showPassword,

                    label: 'Password',
                    hideShowPassword: () {
                      authRead.toggleShowPassword();
                    },
                    validation: (v) {
                      final value = (v ?? '').trim();
                      if (value.isEmpty) {
                        return 'Please enter your password';
                      }

                      return null;
                    },
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    title: 'Log in',
                    isLoading: false,
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        authRead.submit(context);
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
