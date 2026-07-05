import 'package:flutter_tts/flutter_tts.dart';

/// خدمة نطق الكلمات (Text-to-Speech).
///
/// تستخدم محرك النطق المدمج في نظام الهاتف (Android/iOS Native TTS)
/// لنطق الكلمات الإنجليزية بصوت حقيقي — لا حاجة لأي اتصال إنترنت أو
/// ملفات صوتية مسبقة التسجيل.
class TtsService {
  TtsService._internal() {
    _tts.setLanguage('en-US');
    _tts.setSpeechRate(0.45); // أبطأ من المعتاد ليناسب المتعلمين المبتدئين
    _tts.setPitch(1.0);
  }
  static final TtsService instance = TtsService._internal();

  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text) async {
    await _tts.stop(); // إيقاف أي نطق سابق قبل بدء نطق جديد
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
