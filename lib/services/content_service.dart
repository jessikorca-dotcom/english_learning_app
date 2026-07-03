import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/letter_model.dart';
import '../utils/app_constants.dart';

/// يحمّل محتوى دروس الأبجدية من assets/json/alphabet.json المحلي.
///
/// لا يوجد أي اتصال بالإنترنت هنا — البيانات مجمّعة داخل التطبيق نفسه
/// (offline-first) عبر rootBundle، وتُحفظ في الذاكرة (cache) بعد أول
/// تحميل لتفادي إعادة قراءة الملف وتحليله في كل مرة.
class ContentService {
  ContentService._internal();
  static final ContentService instance = ContentService._internal();

  List<LetterModel>? _cache;

  /// يرجع قائمة الحروف مرتّبة من A إلى Z.
  Future<List<LetterModel>> loadLetters() async {
    if (_cache != null) return _cache!;

    final raw = await rootBundle.loadString(AppConstants.alphabetJsonPath);
    final Map<String, dynamic> jsonMap = json.decode(raw) as Map<String, dynamic>;

    final letters = jsonMap.entries
        .map((e) => LetterModel.fromJson(e.key, e.value as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.letter.compareTo(b.letter));

    _cache = letters;
    return letters;
  }

  /// يرجع درساً واحداً بالحرف المطلوب (مثال: "C").
  Future<LetterModel?> getLetter(String letter) async {
    final letters = await loadLetters();
    for (final l in letters) {
      if (l.letter == letter) return l;
    }
    return null;
  }
}
