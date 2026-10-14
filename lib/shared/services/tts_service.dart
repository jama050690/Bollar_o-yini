import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../../features/parent_panel/parent_settings.dart';

/// Telefonning o'z ovoz dvigateli orqali matnni aytadi (internetsiz).
///
/// Til telefonda o'rnatilmagan bo'lsa (masalan, o'zbek), jim qoladi —
/// o'yin ovozsiz davom etadi. Xato hech qachon o'yinni to'xtatmaydi.
class TtsService {
  TtsService({bool Function()? isEnabled}) : _isEnabled = isEnabled ?? (() => true);

  /// Ota-ona panelida "Ovozli o'qish" yoqilganmi.
  final bool Function() _isEnabled;
  FlutterTts? _tts;
  final Map<String, bool> _available = {};

  static const uzbek = 'uz-UZ';
  static const russian = 'ru-RU';
  static const english = 'en-US';

  /// Aytildi bo'lsa true; o'chirilgan, til yo'q yoki xato bo'lsa false.
  Future<bool> speak(String text, {required String language}) async {
    if (!_isEnabled()) return false;
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

  void dispose() => _tts?.stop();
}

final ttsServiceProvider = Provider<TtsService>((ref) {
  final service = TtsService(
    isEnabled: () => ref.read(parentSettingsProvider).ttsEnabled,
  );
  ref.onDispose(service.dispose);
  return service;
});
