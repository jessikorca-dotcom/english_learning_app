import 'package:flutter/material.dart';

/// شارة صغيرة تعرض حرفاً واحداً ضمن ملخص الحروف في شاشة Progress.
/// على عكس [LetterTile] في شاشة الدروس، هذه للعرض فقط (غير قابلة للنقر)
/// ولا تفرّق بين "مقفل" و"غير مكتمل" — فقط "مكتمل" أو "لم يُكتمل بعد".
class LetterBadge extends StatelessWidget {
  const LetterBadge({
    super.key,
    required this.letter,
    required this.isCompleted,
  });

  final String letter;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final background = isCompleted
        ? theme.colorScheme.primary
        : theme.colorScheme.surfaceVariant;
    final foreground = isCompleted
        ? theme.colorScheme.onPrimary
        : theme.colorScheme.onSurfaceVariant.withOpacity(0.5);

    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        letter,
        style: theme.textTheme.titleSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
