import 'package:flutter/material.dart';
import '../models/letter_model.dart';
import '../services/content_service.dart';
import '../services/language_service.dart';
import '../services/progress_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_strings.dart';
import '../widgets/letter_badge.dart';

/// شاشة التقدم (Progress Screen).
///
/// تعرض نقاط الخبرة (XP)، المستوى الحالي مع شريط تقدم نحو المستوى
/// التالي، وشبكة تلخّص كل الحروف A-Z موضّحةً أيها اكتمل.
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  bool _isLoading = true;

  int _xp = 0;
  int _level = 1;
  double _levelRatio = 0;
  int _xpToNext = AppConstants.xpPerLevel;

  List<LetterModel> _letters = [];
  Set<String> _completed = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final xp = await ProgressService.instance.getXp();
    final level = await ProgressService.instance.getLevel();
    final ratio = await ProgressService.instance.getLevelProgressRatio();
    final xpToNext = await ProgressService.instance.getXpToNextLevel();
    final letters = await ContentService.instance.loadLetters();
    final completed = await ProgressService.instance.getCompletedLetters();

    if (!mounted) return;
    setState(() {
      _xp = xp;
      _level = level;
      _levelRatio = ratio;
      _xpToNext = xpToNext;
      _letters = letters;
      _completed = completed.toSet();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.instance.languageCode,
      builder: (context, languageCode, _) {
        String t(String key) => AppStrings.t(key, languageCode);

        return Scaffold(
          appBar: AppBar(title: Text(t('progress_title'))),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      _buildLevelCard(theme, t),
                      const SizedBox(height: 24),
                      Text(
                        '${t('completed_letters')} (${_completed.length}/${AppConstants.totalLetters})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildLettersGrid(),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildLevelCard(ThemeData theme, String Function(String) t) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.emoji_events_rounded,
                    color: theme.colorScheme.onPrimaryContainer, size: 32),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t('level')} $_level',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                    Text(
                      '$_xp ${t('xp_total')}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: _levelRatio,
                minHeight: 10,
                backgroundColor: theme.colorScheme.onPrimaryContainer.withOpacity(0.15),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '$_xpToNext ${t('xp_to_next_level')} ${_level + 1}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLettersGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _letters.length,
      itemBuilder: (context, index) {
        final letter = _letters[index].letter;
        return LetterBadge(
          letter: letter,
          isCompleted: _completed.contains(letter),
        );
      },
    );
  }
}
