import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'lessons_screen.dart';
import 'progress_screen.dart';
import 'settings_screen.dart';
import '../services/language_service.dart';
import '../utils/app_strings.dart';

/// الحاوية الرئيسية (Main Shell).
///
/// تجمع الشاشات الأربع الرئيسية (Home، Lessons، Progress، Settings)
/// خلف شريط تنقّل سفلي واحد، باستخدام IndexedStack للحفاظ على حالة
/// كل تبويب عند التنقّل بينها. شاشة About تبقى شاشة فرعية يُنتقل
/// إليها بالدفع (push) من داخل Settings، وكذلك تفاصيل الدرس من
/// داخل Lessons — وهو نمط تنقّل طبيعي ومتّسق مع بقية التطبيق.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  void _goToTab(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    // الشاشات تُبنى مرة واحدة فقط بفضل IndexedStack (لا تُعاد تهيئتها
    // في كل مرة يتنقّل فيها المستخدم بين التبويبات).
    final screens = [
      HomeScreen(
        onOpenLessonsTab: () => _goToTab(1),
        onOpenProgressTab: () => _goToTab(2),
      ),
      const LessonsScreen(),
      const ProgressScreen(),
      const SettingsScreen(),
    ];

    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.instance.languageCode,
      builder: (context, languageCode, _) {
        String t(String key) => AppStrings.t(key, languageCode);

        return Scaffold(
          body: IndexedStack(index: _selectedIndex, children: screens),
          // نستخدم BottomNavigationBar الكلاسيكي بدلاً من NavigationBar
          // الأحدث (Material 3) لضمان التوافق مع نسخ Flutter الأقدم التي
          // قد تُستخدم في بيئة FlutLab.
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _goToTab,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home_outlined),
                activeIcon: const Icon(Icons.home_rounded),
                label: t('home_nav'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.menu_book_outlined),
                activeIcon: const Icon(Icons.menu_book_rounded),
                label: t('lessons_title'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.bar_chart_outlined),
                activeIcon: const Icon(Icons.bar_chart_rounded),
                label: t('progress_title'),
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings_outlined),
                activeIcon: const Icon(Icons.settings_rounded),
                label: t('settings_title'),
              ),
            ],
          ),
        );
      },
    );
  }
}
