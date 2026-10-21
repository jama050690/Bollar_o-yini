import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../features/parent_panel/parent_settings.dart';
import 'voice_assets.dart';

/// Matnni ovoz chiqarib aytadi (internetsiz).
///
/// O'zbekcha so'z uchun odam ovozida yozilgan fayl bo'lsa — o'sha chalinadi
/// ([VoiceAssets]). Aks holda telefonning o'z ovoz dvigateli ishlatiladi.
/// Til telefonda o'rnatilmagan bo'lsa, jim qoladi — o'yin ovozsiz davom etadi.
/// Xato hech qachon o'yinni to'xtatmaydi.
class TtsService {
  TtsService({
    bool Function()? isEnabled,
    VoiceAssets? voices,
    Future<void> Function(String assetPath)? playRecording,
  })  : _isEnabled = isEnabled ?? (() => true),
        _voices = voices ?? VoiceAssets(),
        _playRecording = playRecording;

  /// Ota-ona panelida "Ovozli o'qish" yoqilganmi.
  final bool Function() _isEnabled;
  final VoiceAssets _voices;
  final Future<void> Function(String assetPath)? _playRecording;
  FlutterTts? _tts;
  AudioPlayer? _player;
  final Map<String, bool> _available = {};

  static const uzbek = 'uz-UZ';
  static const russian = 'ru-RU';
  static const english = 'en-US';
  static const korean = 'ko-KR';
  static const arabic = 'ar-SA';

  /// Aytildi bo'lsa true; o'chirilgan, til yo'q yoki xato bo'lsa false.
  Future<bool> speak(String text, {required String language}) async {
    if (!_isEnabled()) return false;
    if (language == uzbek && await _speakRecorded(text)) return true;
    try {
      final tts = _tts ??= FlutterTts();
      final ok = _available[language] ??= await tts.isLanguageAvailable(language) == true;
      if (!ok) return false;
      await tts.stop();
      await tts.setLanguage(language);
      // iOS'da 0.5 — oddiy tezlik, Android'da 1.0. Bolalar uchun sekinroq.
      await tts.setSpeechRate(defaultTargetPlatform == TargetPlatform.iOS ? 0.4 : 0.8);
      await tts.speak(text);
      return true;
    } catch (e) {
      debugPrint('TTS ishlamadi: $language "$text" ($e)');
      return false;
    }
  }

  /// Yozib olingan fayl bo'lsa chaladi va true qaytaradi.
  Future<bool> _speakRecorded(String text) async {
    final path = await _voices.pathFor(text);
    if (path == null) return false;
    try {
      final play = _playRecording;
      if (play != null) {
        await play(path);
      } else {
        await _tts?.stop();
        final player = _player ??= AudioPlayer();
        await player.stop();
        await player.play(AssetSource(path));
      }
      return true;
    } catch (e) {
      debugPrint('Yozilgan ovoz ijro etilmadi: $path ($e)');
      return false;
    }
  }

  void dispose() {
    _tts?.stop();
    _player?.dispose();
  }
}

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService(
    isEnabled: () => ref.read(parentSettingsProvider).ttsEnabled,
  );
  ref.onDispose(service.dispose);
  return service;
});
