import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/localization/localization_service.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/themes/app_spacing.dart';
import '../../../../core/themes/app_radius.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../dependency_injection/injection.dart';
import '../../../../routes/route_names.dart';

class LanguageSelectPage extends StatefulWidget {
  const LanguageSelectPage({super.key});

  @override
  State<LanguageSelectPage> createState() => _LanguageSelectPageState();
}

class _LanguageSelectPageState extends State<LanguageSelectPage>
    with SingleTickerProviderStateMixin {
  String _selectedCode = 'en';
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _selectedCode = sl<LocalizationService>().currentLocale.languageCode;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Spacer(),

                // Icon
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.sourceBadgeBackground,
                    borderRadius: AppRadius.lgAll,
                  ),
                  child: const Icon(
                    Icons.language_rounded,
                    size: 36,
                    color: AppColors.sourceBadgeText,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),

                Text(
                  'Choose your\nlanguage',
                  style: AppTextStyles.displayLarge,
                ),

                const SizedBox(height: AppSpacing.sm),

                Text(
                  'Elige tu idioma',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: AppSpacing.xxxl),

                // English
                _LanguageTile(
                  code: 'en',
                  label: 'English',
                  nativeLabel: 'English',
                  flag: '🇬🇧',
                  isSelected: _selectedCode == 'en',
                  onTap: () => setState(() => _selectedCode = 'en'),
                ),

                const SizedBox(height: AppSpacing.md),

                // Spanish
                _LanguageTile(
                  code: 'es',
                  label: 'Spanish',
                  nativeLabel: 'Español',
                  flag: '🇪🇸',
                  isSelected: _selectedCode == 'es',
                  onTap: () => setState(() => _selectedCode = 'es'),
                ),

                const Spacer(),

                PrimaryButton(
                  text: 'Continue / Continuar',
                  onPressed: () async {
                    await sl<LocalizationService>()
                        .setLocale(Locale(_selectedCode));
                    if (mounted) context.go(RouteNames.splash);
                  },
                ),

                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageTile extends StatelessWidget {
  final String code;
  final String label;
  final String nativeLabel;
  final String flag;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageTile({
    required this.code,
    required this.label,
    required this.nativeLabel,
    required this.flag,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.surface,
          borderRadius: AppRadius.lgAll,
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nativeLabel, style: AppTextStyles.headlineSmall),
                  Text(label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      )),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: AppColors.textWhite)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}