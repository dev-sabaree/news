import 'package:flutter/material.dart';
import 'package:newsapp/l10n/app_localizations.dart';
import 'package:newsapp/core/localization/localization_service.dart';
import 'package:newsapp/dependency_injection/injection.dart';

class LanguageSwitcher extends StatelessWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final localizationService = sl<LocalizationService>();
    final currentLocale = localizationService.currentLocale;

    return PopupMenuButton<Locale>(
      icon: const Icon(Icons.language),
      tooltip: l10n.selectLanguage,
      onSelected: (locale) {
        localizationService.setLocale(locale);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: const Locale('en'),
          child: Row(
            children: [
              if (currentLocale.languageCode == 'en')
                const Icon(Icons.check, size: 18),
              if (currentLocale.languageCode != 'en')
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              Text(l10n.english),
            ],
          ),
        ),
        PopupMenuItem(
          value: const Locale('es'),
          child: Row(
            children: [
              if (currentLocale.languageCode == 'es')
                const Icon(Icons.check, size: 18),
              if (currentLocale.languageCode != 'es')
                const SizedBox(width: 18),
              const SizedBox(width: 8),
              Text(l10n.spanish),
            ],
          ),
        ),
      ],
    );
  }
}