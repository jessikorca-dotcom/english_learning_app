/// App-wide constant values.
/// Keeping these in one place avoids magic strings/numbers scattered
/// across screens and makes future changes (naming, tuning) trivial.
class AppConstants {
  AppConstants._(); // prevent instantiation

  // App identity
  static const String appName = 'English Learning App';
  static const String developerName = 'Hosam Al-Sharaei';

  // SharedPreferences keys
  static const String prefXp = 'pref_xp';
  static const String prefLevel = 'pref_level';
  static const String prefCompletedLessons = 'pref_completed_lessons';
  static const String prefLanguage = 'pref_language'; // 'en' or 'ar'
  static const String prefThemeMode = 'pref_theme_mode'; // 'light' or 'dark'

  // Gamification
  static const int xpPerLesson = 10;
  static const int xpPerLevel = 50; // XP required to advance one level

  // Content
  static const int totalLetters = 26;
  static const String alphabetJsonPath = 'assets/json/alphabet.json';

  // Timing
  static const Duration splashDuration = Duration(seconds: 3);
}
