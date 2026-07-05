import 'package:flutter/material.dart';
import 'lessons_screen.dart';
import 'progress_screen.dart';
import '../services/language_service.dart';
import '../services/progress_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_strings.dart';
import '../widgets/progress_stat_card.dart';

/// الشاشة الرئيسية (Home Screen).
///
/// تعرض زر "ابدأ التعلم"، زر "متابعة آخر درس" (يظهر فقط إذا كان هناك
/// تقدم سابق)، ونظرة عامة سريعة على التقدم (XP، المستوى، عدد الحروف
/// المكتملة). البيانات تُقرأ من [ProgressService] عبر SharedPreferences.
/// كل النصوص تُترجم تلقائياً حسب اللغة المختارة في [LanguageService].
///
/// عند استخدامها داخل [MainShell]، يتم تمرير [onOpenLessonsTab] و
/// [onOpenProgressTab] للتنقّل عبر شريط التبويبات السفلي مباشرة بدل
/// فتح شاشة جديدة فوق المكدّس. إذا لم يتم تمريرهما (استخدام مستقل)،
/// تُستخدم طريقة الدفع (push) التقليدية كخيار احتياطي.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    this.onOpenLessonsTab,
    this.onOpenProgressTab,
  });

  final VoidCallback? onOpenLessonsTab;
  final VoidCallback? onOpenProgressTab;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _xp = 0;
  int _level = 1;
  int _completedCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final xp = await ProgressService.instance.getXp();
    final level = await ProgressService.instance.getLevel();
    final completed = await ProgressService.instance.getCompletedLessonsCount();

    if (!mounted) return;
    setState(() {
      _xp = xp;
      _level = level;
      _completedCount = completed;
      _isLoading = false;
    });
  }

  Future<void> _openLessons() async {
    if (widget.onOpenLessonsTab != null) {
      widget.onOpenLessonsTab!();
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const LessonsScreen()),
    );
    _loadProgress();
  }

  Future<void> _openProgress() async {
    if (widget.onOpenProgressTab != null) {
      widget.onOpenProgressTab!();
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProgressScreen()),
    );
    _loadProgress();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasProgress = _completedCount > 0;

    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.instance.languageCode,
      builder: (context, languageCode, _) {
        String t(String key) => AppStrings.t(key, languageCode);

        return Scaffold(
          appBar: AppBar(title: const Text(AppConstants.appName)),
          body: SafeArea(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadProgress,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            t('welcome'),
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            t('home_subtitle'),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 24),

                          // نظرة عامة على التقدم — النقر عليها ينقل لتبويب Progress
                          InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: _openProgress,
                            child: Row(
                              children: [
                                ProgressStatCard(
                                  icon: Icons.star_rounded,
                                  label: t('xp'),
                                  value: '$_xp',
                                ),
                                const SizedBox(width: 12),
                                ProgressStatCard(
                                  icon: Icons.emoji_events_rounded,
                                  label: t('level'),
                                  value: '$_level',
                                ),
                                const SizedBox(width: 12),
                                ProgressStatCard(
                                  icon: Icons.menu_book_rounded,
                                  label: t('letters'),
                                  value: '$_completedCount/${AppConstants.totalLetters}',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),

                          // زر متابعة آخر درس — يظهر فقط إذا كان هناك تقدم سابق
                          if (hasProgress) ...[
                            OutlinedButton.icon(
                              onPressed: _openLessons,
                              icon: const Icon(Icons.play_arrow_rounded),
                              label: Text(t('continue_lesson')),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // زر بدء التعلم
                          FilledButton.icon(
                            onPressed: _openLessons,
                            icon: const Icon(Icons.school_rounded),
                            label: Text(
                              hasProgress ? t('all_lessons') : t('start_learning'),
                            ),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
}
