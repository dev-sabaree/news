import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:newsapp/l10n/app_localizations.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../routes/route_names.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(RouteNames.news);
        }
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.textWhite, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.xxxl),

                  // Logo
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.newspaper_rounded,
                      color: AppColors.textWhite,
                      size: 30,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  Text(l10n.login, style: AppTextStyles.displayLarge),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'Welcome back! Sign in to continue',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Email
                  CustomTextField(
                    controller: _emailController,
                    hintText: l10n.email,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _emailFocus,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () {
                      _emailFocus.unfocus();
                      FocusScope.of(context).requestFocus(_passwordFocus);
                    },
                    validator: (value) =>
                        Validators.validateEmail(context, value),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Password
                  CustomTextField(
                    controller: _passwordController,
                    hintText: l10n.password,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    focusNode: _passwordFocus,
                    textInputAction: TextInputAction.done,
                    validator: (value) =>
                        Validators.validatePassword(context, value),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Login Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        text: l10n.login,
                        isLoading: state is AuthLoading,
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                                  LoginRequested(
                                    email: _emailController.text.trim(),
                                    password: _passwordController.text.trim(),
                                  ),
                                );
                          }
                        },
                      );
                    },
                  ),

                  const SizedBox(height: AppSpacing.xl),

                  // Signup link
                  Center(
                    child: TextButton(
                      onPressed: () => context.push(RouteNames.signup),
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account? ",
                          style: AppTextStyles.bodyMedium,
                          children: [
                            TextSpan(
                              text: l10n.signup,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
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