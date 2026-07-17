import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:globaledu_ai/core/utils/logger.dart';

class SttService {
  SttService._();
  static final instance = SttService._();

  final _stt = SpeechToText();
  bool _available = false;
  bool _initialized = false;

  Future<bool> initialize() async {
    if (kIsWeb) return false; // STT not supported on web
    if (_initialized) return _available;
    try {
      _available = await _stt.initialize(
        onError: (e) => AppLogger.error('STT error', e),
        onStatus: (s) => AppLogger.info('STT status: $s'),
      );
      _initialized = true;
      AppLogger.info('STT initialized: $_available');
    } catch (e) {
      AppLogger.error('STT init error', e);
      _available = false;
    }
    return _available;
  }

  Future<void> startListening({
    required void Function(String text) onResult,
    required void Function() onDone,
    String localeId = 'en_US',
  }) async {
    if (!_available) return;
    await _stt.listen(
      onResult: (result) {
        if (result.hasConfidenceRating && result.confidence > 0.3) {
          onResult(result.recognizedWords);
          if (result.finalResult) onDone();
        } else if (!result.hasConfidenceRating) {
          onResult(result.recognizedWords);
          if (result.finalResult) onDone();
        }
      },
      localeId: localeId,
      listenOptions: SpeechListenOptions(
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.dictation,
      ),
    );
  }

  Future<void> stopListening() async {
    await _stt.stop();
  }

  bool get isListening => _stt.isListening;
  bool get isAvailable => _available;
}
