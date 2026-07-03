/// يمثّل كلمة واحدة ضمن درس حرف معيّن (مثال: "Apple" ↔ "تفاحة").
class WordModel {
  const WordModel({
    required this.text,
    required this.meaningAr,
  });

  final String text;
  final String meaningAr;

  factory WordModel.fromMap(String text, String meaningAr) {
    return WordModel(text: text, meaningAr: meaningAr);
  }
}
