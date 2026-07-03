import 'word_model.dart';

/// يمثّل درس حرف واحد من الأبجدية (مثال: حرف "A" مع 3 كلمات).
class LetterModel {
  const LetterModel({
    required this.letter,
    required this.words,
  });

  /// الحرف بصيغته الكبيرة، مثل "A".
  final String letter;

  final List<WordModel> words;

  /// الحرف بصيغته الصغيرة، محسوب تلقائياً — مثل "a".
  String get lowercase => letter.toLowerCase();

  factory LetterModel.fromJson(String letter, Map<String, dynamic> json) {
    final words = List<String>.from(json['words'] as List);
    final meanings = List<String>.from(json['meaning_ar'] as List);

    return LetterModel(
      letter: letter,
      words: List.generate(
        words.length,
        (i) => WordModel(text: words[i], meaningAr: meanings[i]),
      ),
    );
  }
}
