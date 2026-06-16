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

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmFocus = FocusNode();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmFocus.dispose();
    super.dispose();
  }

  void _nextFocus(FocusNode current, FocusNode next) {
    current.unfocus();
    FocusScope.of(context).requestFocus(next);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: AppColors.textWhite, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(state.message)),
                ],
              ),
              backgroundColor: AppColors.success,
            ),
          );
          context.go(RouteNames.login);
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
                  const SizedBox(height: AppSpacing.lg),

                  // Back button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Icon(Icons.arrow_back_rounded,
                          size: 20, color: AppColors.textPrimary),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  Text(l10n.signup, style: AppTextStyles.displayLarge),

                  const SizedBox(height: AppSpacing.sm),

                  Text(
                    'Create your account to get started',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxxl),

                  // Full Name
                  CustomTextField(
                    controller: _nameController,
                    hintText: l10n.fullName,
                    prefixIcon: Icons.person_outline_rounded,
                    focusNode: _nameFocus,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () => _nextFocus(_nameFocus, _phoneFocus),
                    validator: (value) =>
                        Validators.validateName(context, value),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Phone
                  CustomTextField(
                    controller: _phoneController,
                    hintText: l10n.phoneNumber,
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    focusNode: _phoneFocus,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () =>
                        _nextFocus(_phoneFocus, _emailFocus),
                    validator: (value) =>
                        Validators.validatePhone(context, value),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Email
                  CustomTextField(
                    controller: _emailController,
                    hintText: l10n.email,
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    focusNode: _emailFocus,
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () =>
                        _nextFocus(_emailFocus, _passwordFocus),
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
                    textInputAction: TextInputAction.next,
                    onEditingComplete: () =>
                        _nextFocus(_passwordFocus, _confirmFocus),
                    validator: (value) =>
                        Validators.validatePassword(context, value),
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Confirm Password
                  CustomTextField(
                    controller: _confirmPasswordController,
                    hintText: l10n.confirmPassword,
                    prefixIcon: Icons.lock_outline_rounded,
                    obscureText: true,
                    focusNode: _confirmFocus,
                    textInputAction: TextInputAction.done,
                    validator: (value) =>
                        Validators.validateConfirmPassword(
                      context,
                      value,
                      _passwordController.text,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Signup Button
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return PrimaryButton(
                        text: l10n.signup,
                        isLoading: state is AuthLoading,
                        onPressed: () {
                          FocusScope.of(context).unfocus();
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                                  SignUpRequested(
                                    fullName: _nameController.text.trim(),
                                    phone: _phoneController.text.trim(),
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

                  // Login link
                  Center(
                    child: TextButton(
                      onPressed: () => context.pop(),
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account? ',
                          style: AppTextStyles.bodyMedium,
                          children: [
                            TextSpan(
                              text: l10n.login,
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

                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}