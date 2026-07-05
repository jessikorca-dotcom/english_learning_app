import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback, SystemSound, SystemSoundType;
import '../models/letter_model.dart';
import '../models/word_model.dart';
import '../services/content_service.dart';
import '../services/language_service.dart';
import '../services/progress_service.dart';
import '../utils/app_constants.dart';
import '../utils/app_strings.dart';
import '../widgets/word_card.dart';

/// شاشة تفاصيل الدرس (Lesson Detail Screen).
///
/// تعرض الحرف بصيغتيه الكبيرة والصغيرة، وكلماته الثلاث، ثم اختبار
/// قصير (اختيار من متعدد) لكل كلمة. عند إنهاء الاختبار يُسجَّل الدرس
/// كمكتمل وتُضاف نقاط الخبرة عبر [ProgressService].
///
/// يتضمن مؤثرات صوتية وحركية (اهتزاز + نقرة صوتية + رجّة/نبضة بصرية)
/// عند الإجابة، باستخدام واجهات Flutter المدمجة فقط (بدون أي حزمة
/// خارجية) لتفادي أي تأثير على حجم أو استقرار البناء.
class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({super.key, required this.letter});

  final LetterModel letter;

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen>
    with SingleTickerProviderStateMixin {
  bool _quizStarted = false;
  bool _quizFinished = false;

  int _questionIndex = 0;
  int _correctCount = 0;

  // خيارات السؤال الحالي (تُبنى مرة واحدة لكل سؤال لتفادي تغيّرها عند إعادة البناء)
  List<String>? _currentOptions;
  String? _selectedOption;
  bool? _isSelectedCorrect;

  List<String> _allMeaningsPool = [];

  // متحكم "الرجّة" (Shake) عند الإجابة الخاطئة — يهتز الاختيارات أفقياً
  // بشكل متلاشٍ (decaying oscillation) دون الحاجة لأي حزمة أنيميشن خارجية.
  late final AnimationController _shakeController;

  @override
  void initState() {
    super.initState();
    _loadDistractorPool();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _loadDistractorPool() async {
    final letters = await ContentService.instance.loadLetters();
    final pool = <String>[];
    for (final l in letters) {
      if (l.letter == widget.letter.letter) continue;
      for (final w in l.words) {
        pool.add(w.meaningAr);
      }
    }
    if (!mounted) return;
    setState(() => _allMeaningsPool = pool);
  }

  List<String> _buildOptionsFor(WordModel word) {
    final rng = Random();
    final wrongPool = List<String>.from(_allMeaningsPool)
      ..remove(word.meaningAr)
      ..shuffle(rng);

    final options = <String>[word.meaningAr, ...wrongPool.take(2)];
    options.shuffle(rng);
    return options;
  }

  void _startQuiz() {
    setState(() {
      _quizStarted = true;
      _questionIndex = 0;
      _correctCount = 0;
      _currentOptions = _buildOptionsFor(widget.letter.words[0]);
      _selectedOption = null;
      _isSelectedCorrect = null;
    });
  }

  void _selectAnswer(String option) {
    if (_selectedOption != null) return; // تجاهل النقر المتكرر بعد الاختيار

    final correctAnswer = widget.letter.words[_questionIndex].meaningAr;
    final isCorrect = option == correctAnswer;

    setState(() {
      _selectedOption = option;
      _isSelectedCorrect = isCorrect;
      if (isCorrect) _correctCount++;
    });

    if (isCorrect) {
      HapticFeedback.lightImpact();
      SystemSound.play(SystemSoundType.click);
    } else {
      HapticFeedback.vibrate();
      _shakeController.forward(from: 0);
    }

    Future.delayed(const Duration(milliseconds: 700), _goToNextQuestion);
  }

  void _goToNextQuestion() {
    if (!mounted) return;

    final isLastQuestion = _questionIndex == widget.letter.words.length - 1;
    if (isLastQuestion) {
      _finishQuiz();
      return;
    }

    setState(() {
      _questionIndex++;
      _currentOptions = _buildOptionsFor(widget.letter.words[_questionIndex]);
      _selectedOption = null;
      _isSelectedCorrect = null;
    });
  }

  Future<void> _finishQuiz() async {
    await ProgressService.instance.completeLesson(widget.letter.letter);
    if (!mounted) return;
    HapticFeedback.mediumImpact(); // نبضة احتفالية خفيفة عند إنهاء الدرس
    setState(() => _quizFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ValueListenableBuilder<String>(
      valueListenable: LanguageService.instance.languageCode,
      builder: (context, languageCode, _) {
        String t(String key) => AppStrings.t(key, languageCode);

        return Scaffold(
          appBar: AppBar(title: Text('${widget.letter.letter} — ${widget.letter.lowercase}')),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: _quizFinished
                  ? _buildResult(theme, t)
                  : _quizStarted
                      ? _buildQuiz(theme, t)
                      : _buildLessonContent(theme, t),
            ),
          ),
        );
      },
    );
  }

  // ---------- محتوى الدرس (قبل الاختبار) ----------
  Widget _buildLessonContent(ThemeData theme, String Function(String) t) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Column(
            children: [
              Text(
                '${widget.letter.letter}  ${widget.letter.lowercase}',
                style: theme.textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(t('uppercase_lowercase'), style: theme.textTheme.bodySmall),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: ListView.separated(
            itemCount: widget.letter.words.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) => WordCard(word: widget.letter.words[i]),
          ),
        ),
        FilledButton.icon(
          onPressed: _allMeaningsPool.isEmpty ? null : _startQuiz,
          icon: const Icon(Icons.quiz_rounded),
          label: Text(t('start_quiz')),
          style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
        ),
      ],
    );
  }

  // ---------- الاختبار ----------
  Widget _buildQuiz(ThemeData theme, String Function(String) t) {
    final word = widget.letter.words[_questionIndex];
    final options = _currentOptions ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LinearProgressIndicator(
          value: (_questionIndex + 1) / widget.letter.words.length,
        ),
        const SizedBox(height: 24),
        Text(
          t('quiz_question'),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          word.text,
          style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 32),

        // AnimatedBuilder يطبّق "رجّة" أفقية متلاشية على كل الاختيارات
        // عند الإجابة الخاطئة فقط (القيمة تبقى صفراً في باقي الأحيان).
        AnimatedBuilder(
          animation: _shakeController,
          builder: (context, child) {
            final t = _shakeController.value;
            final offset = sin(t * pi * 6) * (1 - t) * 8;
            return Transform.translate(offset: Offset(offset, 0), child: child);
          },
          child: Column(
            children: options.map((option) {
              final isSelected = option == _selectedOption;
              final isCorrectAnswer = option == word.meaningAr;

              Color? bg;
              Color? fg;
              if (_selectedOption != null) {
                if (isCorrectAnswer) {
                  bg = Colors.green.withOpacity(0.15);
                  fg = Colors.green.shade700;
                } else if (isSelected && !_isSelectedCorrect!) {
                  bg = Colors.red.withOpacity(0.15);
                  fg = Colors.red.shade700;
                }
              }

              // نبضة تكبير بسيطة للإجابة الصحيحة بعد أن يختار المستخدم أي إجابة
              final shouldPulse = _selectedOption != null && isCorrectAnswer;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: AnimatedScale(
                  scale: shouldPulse ? 1.04 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: OutlinedButton(
                    onPressed: () => _selectAnswer(option),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: bg,
                      foregroundColor: fg,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: fg ?? theme.colorScheme.outline),
                    ),
                    child: Text(option, textDirection: TextDirection.rtl),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ---------- نتيجة الاختبار ----------
  Widget _buildResult(ThemeData theme, String Function(String) t) {
    final total = widget.letter.words.length;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.celebration_rounded, size: 72, color: theme.colorScheme.primary),
          const SizedBox(height: 16),
          Text(t('lesson_complete'), style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text('${t('score')}: $_correctCount / $total'),
          const SizedBox(height: 4),
          Text('+${AppConstants.xpPerLesson} ${t('xp_earned')}'),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(t('back_to_lessons')),
          ),
        ],
      ),
    );
  }
}
