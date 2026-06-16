import 'package:flutter/material.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_spacing.dart';
import '../../core/themes/app_text_styles.dart';

class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onAction;

  const EmptyStateWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.sourceBadgeBackground,
                borderRadius: BorderRadius.circular(48),
              ),
              child: Icon(icon, size: 48, color: AppColors.sourceBadgeText),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text(title, style: AppTextStyles.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.sm),
            Text(subtitle,
                style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
            if (buttonText != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xxl),
              TextButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.refresh_rounded),
                label: Text(buttonText!),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  textStyle: AppTextStyles.labelMedium,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}