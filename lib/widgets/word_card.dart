import 'package:flutter/material.dart';
import '../models/word_model.dart';

/// بطاقة تعرض كلمة واحدة من كلمات الدرس.
///
/// بدلاً من صور خارجية (غير مسموح بها)، تُستخدم دائرة بسيطة (Avatar)
/// تعرض الحرف الأول من الكلمة كـ"أيقونة" بصرية بديلة — مما يفي بمتطلب
/// "simple icon placeholder (no external images required)".
class WordCard extends StatelessWidget {
  const WordCard({super.key, required this.word});

  final WordModel word;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          child: Text(
            word.text.substring(0, 1).toUpperCase(),
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          word.text,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(word.meaningAr, textDirection: TextDirection.rtl),
      ),
    );
  }
}
