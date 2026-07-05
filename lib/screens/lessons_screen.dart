import 'package:flutter/material.dart';
import 'lesson_detail_screen.dart';
import '../models/letter_model.dart';
import '../services/content_service.dart';
import '../services/language_service.dart';
import '../services/progress_service.dart';
import '../utils/app_strings.dart';
import '../widgets/letter_tile.dart';

/// شاشة الدروس (Lessons Screen).
///
/// تعرض جميع حروف الأبجدية A-Z في شبكة، مع نظام قفل تسلسلي على طراز
/// Duolingo: يجب إكمال درس الحرف الحالي لفتح الحرف التالي.
class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  List<LetterModel> _letters = [];
  Set<String> _completed = {};
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final letters = await ContentService.instance.loadLetters();
    final completed = await ProgressService.instance.getCompletedLetters();

    if (!mounted) return;
    setState(() {
      _letters = letters;
      _completed = completed.toSet();
      _isLoading = false;
    });
  }

  bool _isUnlocked(int index) {
    if (index == 0) return true;
    final previousLetter = _letters[index - 1].letter;
    return _completed.contains(previousLetter);
  }

  Future<void> _openLetter(LetterModel letterModel, bool isUnlocked) async {
    if (!isUnlocked) {
      final languageCode = LanguageService.instance.languageCode.value;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${AppStrings.t('letter_locked_message', languageCode)} '
            '"${letterModel.letter}"',
            textDirection: languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          ),
        ),
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => LessonDetailScreen(letter: letterModel),
      ),
    );

    // إعادة التحميل بعد العودة من الدرس لتحديث حالة القفل/الإكمال
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.instance.languageCode,
      builder: (context, languageCode, _) {
        return Scaffold(
          appBar: AppBar(title: Text(AppStrings.t('lessons_title', languageCode))),
          body: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1,
                  ),
                  itemCount: _letters.length,
                  itemBuilder: (context, index) {
                    final letterModel = _letters[index];
                    final unlocked = _isUnlocked(index);
                    final completed = _completed.contains(letterModel.letter);

                    return LetterTile(
                      letter: letterModel.letter,
                      isUnlocked: unlocked,
                      isCompleted: completed,
                      onTap: () => _openLetter(letterModel, unlocked),
                    );
                  },
                ),
        );
      },
    );
  }
}
