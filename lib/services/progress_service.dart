import 'package:shared_preferences/shared_preferences.dart';
import '../utils/app_constants.dart';

/// خدمة التقدم (Progress Service).
///
/// مسؤولة عن كل ما يخص XP، المستوى، والدروس المكتملة، بالاعتماد فقط
/// على SharedPreferences (بدون قواعد بيانات أو Firebase). تُستخدم من
/// شاشة Home، نظام الدروس (القفل/الفتح)، وشاشة Progress لاحقاً.
class ProgressService {
  ProgressService._internal();
  static final ProgressService instance = ProgressService._internal();

  /// نسبة التقدم داخل المستوى الحالي (من 0.0 إلى 1.0)، تُستخدم في شريط
  /// التقدم بشاشة Progress. مثال: إذا كان xpPerLevel = 50 و XP = 120،
  /// فالمستوى الحالي هو 3 والتقدم داخل هذا المستوى هو 20/50 = 0.4.
  Future<double> getLevelProgressRatio() async {
    final xp = await getXp();
    final xpInCurrentLevel = xp % AppConstants.xpPerLevel;
    return xpInCurrentLevel / AppConstants.xpPerLevel;
  }

  /// عدد نقاط الخبرة المتبقية للوصول إلى المستوى التالي.
  Future<int> getXpToNextLevel() async {
    final xp = await getXp();
    final xpInCurrentLevel = xp % AppConstants.xpPerLevel;
    return AppConstants.xpPerLevel - xpInCurrentLevel;
  }

  Future<int> getXp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.prefXp) ?? 0;
  }

  /// المستوى الحالي محسوب من XP (كل [AppConstants.xpPerLevel] نقطة = مستوى واحد).
  Future<int> getLevel() async {
    final xp = await getXp();
    return (xp ~/ AppConstants.xpPerLevel) + 1;
  }

  /// قائمة رموز الحروف المكتملة، مثال: ["A", "B", "C"].
  Future<List<String>> getCompletedLetters() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(AppConstants.prefCompletedLessons) ?? [];
  }

  Future<int> getCompletedLessonsCount() async {
    final completed = await getCompletedLetters();
    return completed.length;
  }

  Future<bool> isLetterCompleted(String letter) async {
    final completed = await getCompletedLetters();
    return completed.contains(letter);
  }

  /// حرف مفتوح إذا كان أول حرف في الترتيب، أو إذا كان الحرف الذي
  /// يسبقه مباشرة (حسب [allLetters]) قد اكتمل بالفعل.
  Future<bool> isLetterUnlocked(String letter, List<String> allLetters) async {
    final index = allLetters.indexOf(letter);
    if (index <= 0) return true; // أول حرف دائماً مفتوح

    final previousLetter = allLetters[index - 1];
    return isLetterCompleted(previousLetter);
  }

  /// يسجّل اكتمال درس حرف معيّن ويضيف نقاط الخبرة (مرة واحدة فقط لكل حرف).
  Future<void> completeLesson(String letter) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = await getCompletedLetters();

    if (completed.contains(letter)) return; // تم إكماله مسبقاً — لا تكرار للخبرة

    completed.add(letter);
    await prefs.setStringList(AppConstants.prefCompletedLessons, completed);

    final currentXp = await getXp();
    await prefs.setInt(AppConstants.prefXp, currentXp + AppConstants.xpPerLesson);
  }
}
