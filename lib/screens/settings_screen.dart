import 'package:flutter/material.dart';
import 'about_screen.dart';
import '../services/language_service.dart';
import '../services/theme_service.dart';
import '../utils/app_strings.dart';

/// شاشة الإعدادات (Settings Screen).
///
/// تحتوي مفتاحين فعّالين فعلياً (وليسا للعرض فقط):
/// - الوضع الليلي: يبدّل [ThemeService] ويُحفظ في SharedPreferences.
/// - اللغة: يبدّل [LanguageService] بين العربية والإنجليزية ويُحفظ أيضاً.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.instance.languageCode,
      builder: (context, languageCode, _) {
        String t(String key) => AppStrings.t(key, languageCode);

        return Scaffold(
          appBar: AppBar(title: Text(t('settings_title'))),
          body: ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              // --- الوضع الليلي ---
              ValueListenableBuilder<ThemeMode>(
                valueListenable: ThemeService.instance.themeMode,
                builder: (context, mode, __) {
                  return SwitchListTile(
                    secondary: const Icon(Icons.dark_mode_rounded),
                    title: Text(t('dark_mode')),
                    value: mode == ThemeMode.dark,
                    onChanged: (_) => ThemeService.instance.toggleTheme(),
                  );
                },
              ),
              const Divider(height: 1),

              // --- اللغة ---
              ListTile(
                leading: const Icon(Icons.language_rounded),
                title: Text(t('language')),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: _LanguageOptionButton(
                          label: t('english'),
                          isSelected: languageCode == 'en',
                          onTap: () {
                            if (languageCode != 'en') {
                              LanguageService.instance.toggleLanguage();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _LanguageOptionButton(
                          label: t('arabic'),
                          isSelected: languageCode == 'ar',
                          onTap: () {
                            if (languageCode != 'ar') {
                              LanguageService.instance.toggleLanguage();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1),

              // --- حول التطبيق ---
              ListTile(
                leading: const Icon(Icons.info_outline_rounded),
                title: Text(t('about')),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const AboutScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

/// زر بسيط لاختيار لغة واحدة (يُستخدم بدل SegmentedButton لضمان توافق
/// أوسع مع نسخ Flutter الأقدم).
class _LanguageOptionButton extends StatelessWidget {
  const _LanguageOptionButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return FilledButton(
        onPressed: onTap,
        child: Text(label),
      );
    }
    return OutlinedButton(
      onPressed: onTap,
      child: Text(label),
    );
  }
}
