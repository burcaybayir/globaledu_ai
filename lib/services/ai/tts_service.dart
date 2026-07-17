import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:globaledu_ai/core/utils/logger.dart';

class TtsService {
  TtsService._();
  static final instance = TtsService._();

  final _tts = FlutterTts();
  bool _initialized = false;
  bool _speaking = false;

  Future<void> _init() async {
    if (_initialized || kIsWeb) return;
    await _tts.setLanguage('en-US');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() => _speaking = false);
    _tts.setErrorHandler((_) => _speaking = false);
    _initialized = true;
  }

  Future<void> speak(String text) async {
    if (kIsWeb) return; // TTS not supported on web
    await _init();
    if (_speaking) await stop();
    // Strip markdown for cleaner TTS output
    final clean = _stripMarkdown(text);
    _speaking = true;
    await _tts.speak(clean);
  }

  Future<void> stop() async {
    if (kIsWeb) return;
    _speaking = false;
    await _tts.stop();
  }

  bool get isSpeaking => _speaking;

  Future<List<String>> getVoices() async {
    if (kIsWeb) return [];
    await _init();
    final voices = await _tts.getVoices as List?;
    return voices?.cast<String>() ?? [];
  }

  /// Remove markdown syntax for cleaner speech
  String _stripMarkdown(String text) {
    return text
        .replaceAll(RegExp(r'\*\*(.+?)\*\*'), r'\1') // bold
        .replaceAll(RegExp(r'\*(.+?)\*'), r'\1') // italic
        .replaceAll(RegExp(r'^#{1,6}\s', multiLine: true), '') // headers
        .replaceAll(RegExp(r'`(.+?)`'), r'\1') // code
        .replaceAll(RegExp(r'\[(.+?)\]\(.+?\)'), r'\1') // links
        .replaceAll(RegExp(r'^[-*]\s', multiLine: true), '') // bullets
        .replaceAll(RegExp(r'^\d+\.\s', multiLine: true), '') // numbered
        .trim();
  }
}
