import 'package:flutter/material.dart';
import 'package:newsapp/l10n/app_localizations.dart';

class Validators {
  Validators._();

  static String? validateName(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l10n.fieldRequired;
    }
    return null;
  }

  static String? validatePhone(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l10n.fieldRequired;
    }
    final normalized = value.trim().replaceAll(RegExp(r'[\s().-]'), '');
    if (!RegExp(r'^\+?[1-9]\d{7,14}$').hasMatch(normalized)) {
      return l10n.invalidPhone;
    }
    return null;
  }

  static String? validateEmail(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l10n.fieldRequired;
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return l10n.invalidEmail;
    }
    return null;
  }

  static String? validatePassword(BuildContext context, String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l10n.fieldRequired;
    }
    if (value.length < 6) {
      return l10n.passwordTooShort;
    }
    return null;
  }

  static String? validateConfirmPassword(
    BuildContext context,
    String? value,
    String password,
  ) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) {
      return l10n.fieldRequired;
    }
    if (value != password) {
      return l10n.passwordsDoNotMatch;
    }
    return null;
  }
}
