import 'dart:io';

import 'package:aqlli_dostlar/features/games/alphabets/alphabets_game.dart';
import 'package:aqlli_dostlar/features/games/counting/counting_game.dart';
import 'package:aqlli_dostlar/features/games/letter_number/letter_number_game.dart';
import 'package:aqlli_dostlar/features/games/letter_number/letter_number_screen.dart';
import 'package:aqlli_dostlar/shared/services/tts_service.dart';
import 'package:aqlli_dostlar/shared/services/voice_assets.dart';
import 'package:flutter_test/flutter_test.dart';

/// O'yinlarda o'zbekcha aytiladigan barcha matnlar.
Set<String> _allSpokenUzbek() => {
      for (final letter in Alphabet.uzbek.letters) letter.spoken,
      for (var n = 1; n <= 100; n++) uzbekNumber(n),
      ...spokenUzbek.values,
    };

VoiceAssets _voicesWith(Set<String> files) =>
    VoiceAssets(loadAssets: () async => {for (final f in files) '${VoiceAssets.folder}$f'});

void main() {
  group('Fayl nomi', () {
    test("matndan fayl nomi to'g'ri yasaladi", () {
      expect(VoiceAssets.fileName('be'), 'be.mp3');
      expect(VoiceAssets.fileName('toʻrt'), 'to_rt.mp3');
      expect(VoiceAssets.fileName('oʻn bir'), 'o_n_bir.mp3');
      expect(VoiceAssets.fileName("Gʻe"), 'g_e.mp3');
      expect(VoiceAssets.fileName("o'n"), 'o_n.mp3');
    });

    test('har xil matnlar har xil faylga tushadi', () {
      final spoken = _allSpokenUzbek();
      final files = spoken.map(VoiceAssets.fileName).toSet();
      expect(files.length, spoken.length);
    });

    test("faqat yozilgan fayl bo'lsa yo'l qaytadi", () async {
      final voices = _voicesWith({'be.mp3'});
      expect(await voices.pathFor('be'), 'sounds/uz/words/be.mp3');
      expect(await voices.pathFor('de'), isNull);
    });
  });

  group('Ovozli o\'qish', () {
    test("o'zbekcha yozuv bo'lsa, o'sha chalinadi", () async {
      final played = <String>[];
      final tts = TtsService(
        voices: _voicesWith({'to_rt.mp3'}),
        playRecording: (path) async => played.add(path),
      );

      expect(await tts.speak('toʻrt', language: TtsService.uzbek), isTrue);
      expect(played, ['sounds/uz/words/to_rt.mp3']);
    });

    test("ovozli o'qish o'chirilgan bo'lsa, yozuv ham chalinmaydi", () async {
      final played = <String>[];
      final tts = TtsService(
        isEnabled: () => false,
        voices: _voicesWith({'be.mp3'}),
        playRecording: (path) async => played.add(path),
      );

      expect(await tts.speak('be', language: TtsService.uzbek), isFalse);
      expect(played, isEmpty);
    });
  });

  group("Harf-Raqam bog'chasi", () {
    test('har bir harf va raqamning aytilishi bor', () {
      for (final item in [...uzbekLetters, ...numbers]) {
        expect(spokenUzbek[item.soundKey], isNotNull, reason: item.label);
      }
    });

    test("harf nomlari Alifbolar o'yini bilan bir xil", () {
      final names = {for (final l in Alphabet.uzbek.letters) l.upper: l.spoken};
      for (final item in uzbekLetters) {
        expect(spokenUzbek[item.soundKey], names[item.label], reason: item.label);
      }
    });
  });

  test("README yozib olish ro'yxatida hamma fayl bor", () {
    final readme = File('assets/sounds/README.md').readAsStringSync();
    for (final text in _allSpokenUzbek()) {
      expect(readme, contains('`${VoiceAssets.fileName(text)}`'), reason: text);
    }
  });
}
