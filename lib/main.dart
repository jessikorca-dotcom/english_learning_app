import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'services/language_service.dart';
import 'services/theme_service.dart';
import 'utils/app_constants.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  // Ensure bindings are ready before touching SharedPreferences/assets.
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted theme and language before first frame so there's no
  // flash of the wrong theme/language on launch.
  await ThemeService.instance.loadTheme();
  await LanguageService.instance.loadLanguage();

  runApp(const EnglishLearningApp());
}

/// Root widget of the English Learning App.
///
/// Fully offline: no backend, no Firebase, no network calls anywhere
/// in this app. All persistence is via SharedPreferences and all
/// content is loaded from local JSON assets.
class EnglishLearningApp extends StatelessWidget {
  const EnglishLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.instance.themeMode,
      builder: (context, mode, _) {
        return ValueListenableBuilder<String>(
          valueListenable: LanguageService.instance.languageCode,
          builder: (context, languageCode, __) {
            final isArabic = languageCode == 'ar';

            return MaterialApp(
              title: AppConstants.appName,
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: mode,
              // لا نعتمد على flutter_localizations؛ نضبط اتجاه النص يدوياً
              // عبر Directionality بحسب اللغة المختارة فقط.
              builder: (context, child) {
                return Directionality(
                  textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
                  child: child!,
                );
              },
              home: const SplashScreen(),
            );
          },
        );
      },
    );
  }
}
