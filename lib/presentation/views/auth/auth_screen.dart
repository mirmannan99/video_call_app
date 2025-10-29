import 'package:flutter/material.dart';

import '../../widgets/buttons/primary_button.dart';
import '../../widgets/logo/primary_app_logo.dart';
import '../../widgets/text_fields/primary_password_field.dart';
import '../../widgets/text_fields/primay_text_form_fields.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();
  bool _obscure = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final String v = value?.trim() ?? '';
    if (v.isEmpty) return 'Email is required';
    final emailReg = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,}$');
    if (!emailReg.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    final String v = value ?? '';
    if (v.isEmpty) return 'Password is required';
    if (v.length < 6) return 'Minimum 6 characters';
    return null;
  }

  Future<void> _submit() async {
    final form = _formKey.currentState;
    if (form == null) return;
    if (!form.validate()) return;
    setState(() => _isLoading = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Validation passed')));
  }

  @override
  Widget build(BuildContext context) {
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
                    controller: _emailController,
                    label: 'Email',
                    textInputAction: TextInputAction.next,
                    validation: _validateEmail,
                  ),
                  const SizedBox(height: 16),
                  PrimaryPasswordFormField(
                    controller: _passwordController,
                    isObscure: _obscure,
                    label: 'Password',
                    onShowPassword: () {
                      setState(() => _obscure = !_obscure);
                    },
                    validation: _validatePassword,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 24),
                  PrimaryButton(
                    title: 'Log in',
                    isLoading: _isLoading,
                    onPressed: _isLoading ? null : _submit,
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
