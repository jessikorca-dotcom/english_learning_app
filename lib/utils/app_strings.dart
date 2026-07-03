/// نظام محلي بسيط لإدارة نصوص الواجهة بلغتين (عربي/إنجليزي) دون أي
/// حزمة خارجية. كل نص في التطبيق له "مفتاح"، وهذا الملف يحتوي على
/// ترجمته بكل لغة مدعومة.
///
/// الاستخدام: `AppStrings.t('start_learning', languageCode)`
class AppStrings {
  AppStrings._();

  static const String defaultLanguage = 'en';

  static const Map<String, Map<String, String>> _values = {
    'en': {
      // Home
      'home_nav': 'Home',
      'welcome': 'Welcome 👋',
      'home_subtitle': "Let's learn the English alphabet, one letter at a time.",
      'xp': 'XP',
      'level': 'Level',
      'letters': 'Letters',
      'continue_lesson': 'Continue Last Lesson',
      'all_lessons': 'All Lessons',
      'start_learning': 'Start Learning',
      'progress_tooltip': 'Progress',
      'settings_tooltip': 'Settings',

      // Lessons
      'lessons_title': 'Lessons',
      'letter_locked_message': 'Complete the previous letter first to unlock',

      // Lesson detail
      'uppercase_lowercase': 'Uppercase & Lowercase',
      'start_quiz': 'Start Quiz',
      'quiz_question': 'What does this word mean?',
      'lesson_complete': 'Lesson Complete!',
      'score': 'Score',
      'xp_earned': 'XP earned',
      'back_to_lessons': 'Back to Lessons',

      // Progress
      'progress_title': 'Progress',
      'xp_total': 'XP total',
      'xp_to_next_level': 'XP to Level',
      'completed_letters': 'Completed Letters',

      // Settings
      'settings_title': 'Settings',
      'dark_mode': 'Dark Mode',
      'language': 'Language',
      'english': 'English',
      'arabic': 'العربية',
      'about': 'About',

      // About
      'about_title': 'About',
      'developer': 'Developer',
      'app_description':
          'English Learning App helps beginners learn the English alphabet '
              'and basic vocabulary through short, gamified lessons — fully '
              'offline, with no internet connection required.',
    },
    'ar': {
      // Home
      'home_nav': 'الرئيسية',
      'welcome': 'مرحباً 👋',
      'home_subtitle': 'لنتعلّم الأبجدية الإنجليزية، حرفاً حرفاً.',
      'xp': 'الخبرة',
      'level': 'المستوى',
      'letters': 'الحروف',
      'continue_lesson': 'متابعة آخر درس',
      'all_lessons': 'كل الدروس',
      'start_learning': 'ابدأ التعلم',
      'progress_tooltip': 'التقدم',
      'settings_tooltip': 'الإعدادات',

      // Lessons
      'lessons_title': 'الدروس',
      'letter_locked_message': 'أكمل الحرف السابق أولاً لفتح هذا الحرف',

      // Lesson detail
      'uppercase_lowercase': 'الحرف الكبير والصغير',
      'start_quiz': 'ابدأ الاختبار',
      'quiz_question': 'ما معنى هذه الكلمة؟',
      'lesson_complete': 'تم إكمال الدرس!',
      'score': 'النتيجة',
      'xp_earned': 'نقطة خبرة',
      'back_to_lessons': 'العودة إلى الدروس',

      // Progress
      'progress_title': 'التقدم',
      'xp_total': 'إجمالي الخبرة',
      'xp_to_next_level': 'نقطة خبرة للمستوى',
      'completed_letters': 'الحروف المكتملة',

      // Settings
      'settings_title': 'الإعدادات',
      'dark_mode': 'الوضع الليلي',
      'language': 'اللغة',
      'english': 'English',
      'arabic': 'العربية',
      'about': 'حول التطبيق',

      // About
      'about_title': 'حول التطبيق',
      'developer': 'المطوّر',
      'app_description':
          'يساعد تطبيق English Learning App المبتدئين على تعلّم الأبجدية '
              'الإنجليزية والمفردات الأساسية من خلال دروس قصيرة وممتعة — '
              'يعمل بالكامل بدون اتصال بالإنترنت.',
    },
  };

  /// يُرجع النص المطابق للمفتاح [key] باللغة [languageCode].
  /// إن لم يوجد، يعود تلقائياً للإنجليزية، ثم للمفتاح نفسه كحل أخير.
  static String t(String key, String languageCode) {
    return _values[languageCode]?[key] ??
        _values[defaultLanguage]?[key] ??
        key;
  }
}
