import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';
import '../utils/app_strings.dart';

/// خدمة اللغة (Language Service).
///
/// تحفظ اللغة المختارة (English/Arabic) وتوفّرها لكل التطبيق عبر
/// ValueNotifier بسيط (بدون Provider أو أي حزمة إدارة حالة خارجية).
/// أي شاشة تستمع لهذا الـ ValueNotifier تُعاد بناؤها تلقائياً عند تغيير اللغة.
class LanguageService {
  LanguageService._internal();
  static final LanguageService instance = LanguageService._internal();

  final ValueNotifier<String> languageCode = ValueNotifier<String>(
    AppStrings.defaultLanguage,
  );

  bool get isArabic => languageCode.value == 'ar';

  /// يحمّل اللغة المحفوظة. يُستدعى مرة واحدة عند بدء التطبيق، قبل runApp.
  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(AppConstants.prefLanguage);
    languageCode.value = (saved == 'ar') ? 'ar' : 'en';
  }

  /// يبدّل بين العربية والإنجليزية ويحفظ الاختيار.
  Future<void> toggleLanguage() async {
    final newCode = isArabic ? 'en' : 'ar';
    languageCode.value = newCode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefLanguage, newCode);
  }

  /// اختصار قصير لترجمة نص حسب اللغة الحالية.
  String t(String key) => AppStrings.t(key, languageCode.value);
}
