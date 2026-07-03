import 'package:flutter/material.dart';

/// بلاطة حرف واحدة ضمن شبكة شاشة Lessons.
///
/// تعرض الحرف الكبير، وتغيّر شكلها حسب الحالة:
/// - مكتمل: خلفية ملوّنة + علامة صح
/// - مفتوح (غير مكتمل بعد): خلفية بارزة قابلة للنقر
/// - مقفل: باهتة مع أيقونة قفل، وغير قابلة للنقر فعلياً
class LetterTile extends StatelessWidget {
  const LetterTile({
    super.key,
    required this.letter,
    required this.isUnlocked,
    required this.isCompleted,
    required this.onTap,
  });

  final String letter;
  final bool isUnlocked;
  final bool isCompleted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color background;
    final Color foreground;

    if (isCompleted) {
      background = theme.colorScheme.primary;
      foreground = theme.colorScheme.onPrimary;
    } else if (isUnlocked) {
      background = theme.colorScheme.primaryContainer;
      foreground = theme.colorScheme.onPrimaryContainer;
    } else {
      background = theme.colorScheme.surfaceVariant;
      foreground = theme.colorScheme.onSurfaceVariant.withOpacity(0.5);
    }

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap, // نستدعي onTap دائماً؛ الشاشة الأم (LessonsScreen) تقرر عرض رسالة القفل من عدمه
        child: Stack(
          alignment: Alignment.center,
          children: [
            Text(
              letter,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: foreground,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (!isUnlocked)
              Positioned(
                bottom: 6,
                right: 6,
                child: Icon(Icons.lock_rounded, size: 14, color: foreground),
              ),
            if (isCompleted)
              Positioned(
                bottom: 6,
                right: 6,
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 14,
                  color: foreground,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
