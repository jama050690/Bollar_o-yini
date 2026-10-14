import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Ovozli fayllarni ijro etadi (assets/sounds/ ichidan).
///
/// Fayl hali qo'shilmagan bo'lsa, xato bermaydi — o'yin ovozsiz davom etadi.
/// Kerakli fayllar ro'yxati: assets/sounds/README.md
class SoundService {
  AudioPlayer? _player;

  static const correct = 'sounds/effects/correct.wav';
  static const tryAgain = 'sounds/effects/try_again.wav';
  static const win = 'sounds/effects/win.wav';

  static String letter(String key) => 'sounds/uz/letters/$key.mp3';
  static String number(String key) => 'sounds/uz/numbers/$key.mp3';

  Future<void> play(String assetPath) async {
    try {
      final player = _player ??= AudioPlayer();
      await player.stop();
      await player.play(AssetSource(assetPath));
    } catch (e) {
      debugPrint('Ovoz ijro etilmadi: $assetPath ($e)');
    }
  }

  void dispose() => _player?.dispose();
}

final soundServiceProvider = Provider<SoundService>((ref) {
  final service = SoundService();
  ref.onDispose(service.dispose);
  return service;
});
