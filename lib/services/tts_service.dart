import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final FlutterTts _tts = FlutterTts();
  static bool _isPlaying = false;
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await _tts.setLanguage('pt-BR');
    await _tts.setSpeechRate(0.45);  // Velocidade confortável
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _initialized = true;
  }

  static bool get isPlaying => _isPlaying;

  static Future<void> speak(String text) async {
    await init();
    await _tts.stop();
    _isPlaying = true;
    await _tts.speak(text);
  }

  static Future<void> speakVerses(List<Map<String, String>> verses) async {
    await init();
    await _tts.stop();
    _isPlaying = true;
    final fullText = verses.map((v) => '${v['verse']}. ${v['text']}').join('. ');
    await _tts.speak(fullText);
  }

  static Future<void> pause() async {
    await _tts.pause();
    _isPlaying = false;
  }

  static Future<void> stop() async {
    await _tts.stop();
    _isPlaying = false;
  }

  static void setRate(double rate) => _tts.setSpeechRate(rate);
  static void setPitch(double pitch) => _tts.setPitch(pitch);

  static void onComplete(VoidCallback cb) {
    _tts.setCompletionHandler(() {
      _isPlaying = false;
      cb();
    });
  }
}
