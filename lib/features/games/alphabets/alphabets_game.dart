import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../../../shared/services/tts_service.dart';
import '../game_result.dart';

class AlphabetLetter {
  const AlphabetLetter(this.upper, this.lower, this.spoken);

  /// Katta-kichik harfi yo'q yozuvlar uchun (koreys, arab).
  const AlphabetLetter.single(String letter, this.spoken)
      : upper = letter,
        lower = letter;

  final String upper;
  final String lower;

  /// Ovoz dvigateli aytadigan matn (harfning nomi, masalan "en", "эн").
  final String spoken;

  @override
  bool operator ==(Object other) => other is AlphabetLetter && other.upper == upper;

  @override
  int get hashCode => upper.hashCode;
}

enum Alphabet {
  uzbek('🇺🇿', TtsService.uzbek),
  russian('🇷🇺', TtsService.russian),
  english('🇬🇧', TtsService.english),
  korean('🇰🇷', TtsService.korean),
  arabic('🇸🇦', TtsService.arabic);

  const Alphabet(this.flag, this.language);

  String get label => switch (this) {
        Alphabet.uzbek => AppStrings.langUzbek,
        Alphabet.russian => AppStrings.langRussian,
        Alphabet.english => AppStrings.langEnglish,
        Alphabet.korean => AppStrings.langKorean,
        Alphabet.arabic => AppStrings.langArabic,
      };

  final String flag;
  final String language;

  /// Katta va kichik harfi bormi. Yo'q bo'lsa, ekranda kichik harf ko'rsatilmaydi —
  /// bola harfni faqat eshitib topadi.
  bool get hasCase => switch (this) {
        Alphabet.uzbek || Alphabet.russian || Alphabet.english => true,
        Alphabet.korean || Alphabet.arabic => false,
      };

  List<AlphabetLetter> get letters => switch (this) {
        Alphabet.uzbek => _uzbek,
        Alphabet.russian => _russian,
        Alphabet.english => _english,
        Alphabet.korean => _korean,
        Alphabet.arabic => _arabic,
      };
}

// O'zbek lotin alifbosi (29 harf).
const _uzbek = [
  AlphabetLetter('A', 'a', 'a'),
  AlphabetLetter('B', 'b', 'be'),
  AlphabetLetter('D', 'd', 'de'),
  AlphabetLetter('E', 'e', 'e'),
  AlphabetLetter('F', 'f', 'ef'),
  AlphabetLetter('G', 'g', 'ge'),
  AlphabetLetter('H', 'h', 'he'),
  AlphabetLetter('I', 'i', 'i'),
  AlphabetLetter('J', 'j', 'je'),
  AlphabetLetter('K', 'k', 'ke'),
  AlphabetLetter('L', 'l', 'el'),
  AlphabetLetter('M', 'm', 'em'),
  AlphabetLetter('N', 'n', 'en'),
  AlphabetLetter('O', 'o', 'o'),
  AlphabetLetter('P', 'p', 'pe'),
  AlphabetLetter('Q', 'q', 'qe'),
  AlphabetLetter('R', 'r', 'er'),
  AlphabetLetter('S', 's', 'es'),
  AlphabetLetter('T', 't', 'te'),
  AlphabetLetter('U', 'u', 'u'),
  AlphabetLetter('V', 'v', 've'),
  AlphabetLetter('X', 'x', 'xe'),
  AlphabetLetter('Y', 'y', 'ye'),
  AlphabetLetter('Z', 'z', 'ze'),
  AlphabetLetter('Oʻ', 'oʻ', 'oʻ'),
  AlphabetLetter('Gʻ', 'gʻ', 'gʻe'),
  AlphabetLetter('Sh', 'sh', 'sha'),
  AlphabetLetter('Ch', 'ch', 'che'),
  AlphabetLetter('Ng', 'ng', 'nge'),
];

// Rus alifbosi (33 harf).
const _russian = [
  AlphabetLetter('А', 'а', 'а'),
  AlphabetLetter('Б', 'б', 'бэ'),
  AlphabetLetter('В', 'в', 'вэ'),
  AlphabetLetter('Г', 'г', 'гэ'),
  AlphabetLetter('Д', 'д', 'дэ'),
  AlphabetLetter('Е', 'е', 'е'),
  AlphabetLetter('Ё', 'ё', 'ё'),
  AlphabetLetter('Ж', 'ж', 'жэ'),
  AlphabetLetter('З', 'з', 'зэ'),
  AlphabetLetter('И', 'и', 'и'),
  AlphabetLetter('Й', 'й', 'и краткое'),
  AlphabetLetter('К', 'к', 'ка'),
  AlphabetLetter('Л', 'л', 'эль'),
  AlphabetLetter('М', 'м', 'эм'),
  AlphabetLetter('Н', 'н', 'эн'),
  AlphabetLetter('О', 'о', 'о'),
  AlphabetLetter('П', 'п', 'пэ'),
  AlphabetLetter('Р', 'р', 'эр'),
  AlphabetLetter('С', 'с', 'эс'),
  AlphabetLetter('Т', 'т', 'тэ'),
  AlphabetLetter('У', 'у', 'у'),
  AlphabetLetter('Ф', 'ф', 'эф'),
  AlphabetLetter('Х', 'х', 'ха'),
  AlphabetLetter('Ц', 'ц', 'цэ'),
  AlphabetLetter('Ч', 'ч', 'че'),
  AlphabetLetter('Ш', 'ш', 'ша'),
  AlphabetLetter('Щ', 'щ', 'ща'),
  AlphabetLetter('Ъ', 'ъ', 'твёрдый знак'),
  AlphabetLetter('Ы', 'ы', 'ы'),
  AlphabetLetter('Ь', 'ь', 'мягкий знак'),
  AlphabetLetter('Э', 'э', 'э'),
  AlphabetLetter('Ю', 'ю', 'ю'),
  AlphabetLetter('Я', 'я', 'я'),
];

// Ingliz alifbosi (26 harf).
const _english = [
  AlphabetLetter('A', 'a', 'ay'),
  AlphabetLetter('B', 'b', 'bee'),
  AlphabetLetter('C', 'c', 'see'),
  AlphabetLetter('D', 'd', 'dee'),
  AlphabetLetter('E', 'e', 'ee'),
  AlphabetLetter('F', 'f', 'ef'),
  AlphabetLetter('G', 'g', 'gee'),
  AlphabetLetter('H', 'h', 'aitch'),
  AlphabetLetter('I', 'i', 'eye'),
  AlphabetLetter('J', 'j', 'jay'),
  AlphabetLetter('K', 'k', 'kay'),
  AlphabetLetter('L', 'l', 'el'),
  AlphabetLetter('M', 'm', 'em'),
  AlphabetLetter('N', 'n', 'en'),
  AlphabetLetter('O', 'o', 'oh'),
  AlphabetLetter('P', 'p', 'pee'),
  AlphabetLetter('Q', 'q', 'cue'),
  AlphabetLetter('R', 'r', 'ar'),
  AlphabetLetter('S', 's', 'ess'),
  AlphabetLetter('T', 't', 'tee'),
  AlphabetLetter('U', 'u', 'you'),
  AlphabetLetter('V', 'v', 'vee'),
  AlphabetLetter('W', 'w', 'double you'),
  AlphabetLetter('X', 'x', 'ex'),
  AlphabetLetter('Y', 'y', 'why'),
  AlphabetLetter('Z', 'z', 'zee'),
];

// Koreys alifbosi — Hangul (14 undosh + 10 unli = 24 harf).
const _korean = [
  AlphabetLetter.single('ㄱ', '기역'),
  AlphabetLetter.single('ㄴ', '니은'),
  AlphabetLetter.single('ㄷ', '디귿'),
  AlphabetLetter.single('ㄹ', '리을'),
  AlphabetLetter.single('ㅁ', '미음'),
  AlphabetLetter.single('ㅂ', '비읍'),
  AlphabetLetter.single('ㅅ', '시옷'),
  AlphabetLetter.single('ㅇ', '이응'),
  AlphabetLetter.single('ㅈ', '지읒'),
  AlphabetLetter.single('ㅊ', '치읓'),
  AlphabetLetter.single('ㅋ', '키읔'),
  AlphabetLetter.single('ㅌ', '티읕'),
  AlphabetLetter.single('ㅍ', '피읖'),
  AlphabetLetter.single('ㅎ', '히읗'),
  AlphabetLetter.single('ㅏ', '아'),
  AlphabetLetter.single('ㅑ', '야'),
  AlphabetLetter.single('ㅓ', '어'),
  AlphabetLetter.single('ㅕ', '여'),
  AlphabetLetter.single('ㅗ', '오'),
  AlphabetLetter.single('ㅛ', '요'),
  AlphabetLetter.single('ㅜ', '우'),
  AlphabetLetter.single('ㅠ', '유'),
  AlphabetLetter.single('ㅡ', '으'),
  AlphabetLetter.single('ㅣ', '이'),
];

// Arab alifbosi (28 harf), alohida yozilish shaklida.
const _arabic = [
  AlphabetLetter.single('ا', 'ألف'),
  AlphabetLetter.single('ب', 'باء'),
  AlphabetLetter.single('ت', 'تاء'),
  AlphabetLetter.single('ث', 'ثاء'),
  AlphabetLetter.single('ج', 'جيم'),
  AlphabetLetter.single('ح', 'حاء'),
  AlphabetLetter.single('خ', 'خاء'),
  AlphabetLetter.single('د', 'دال'),
  AlphabetLetter.single('ذ', 'ذال'),
  AlphabetLetter.single('ر', 'راء'),
  AlphabetLetter.single('ز', 'زاي'),
  AlphabetLetter.single('س', 'سين'),
  AlphabetLetter.single('ش', 'شين'),
  AlphabetLetter.single('ص', 'صاد'),
  AlphabetLetter.single('ض', 'ضاد'),
  AlphabetLetter.single('ط', 'طاء'),
  AlphabetLetter.single('ظ', 'ظاء'),
  AlphabetLetter.single('ع', 'عين'),
  AlphabetLetter.single('غ', 'غين'),
  AlphabetLetter.single('ف', 'فاء'),
  AlphabetLetter.single('ق', 'قاف'),
  AlphabetLetter.single('ك', 'كاف'),
  AlphabetLetter.single('ل', 'لام'),
  AlphabetLetter.single('م', 'ميم'),
  AlphabetLetter.single('ن', 'نون'),
  AlphabetLetter.single('ه', 'هاء'),
  AlphabetLetter.single('و', 'واو'),
  AlphabetLetter.single('ي', 'ياء'),
];

class LetterQuestion {
  const LetterQuestion(this.target, this.options);

  final AlphabetLetter target;
  final List<AlphabetLetter> options;
}

enum LetterAnswer { correct, wrong, finished }

/// Alifbo o'yini: harf aytiladi (va kichik harfi ko'rinadi), bola 4 ta katta harfdan topadi.
class AlphabetsGame {
  AlphabetsGame(this.alphabet, {Random? random}) {
    final rnd = random ?? Random();
    final letters = alphabet.letters;
    final targets = (List.of(letters)..shuffle(rnd)).take(questionCount);
    questions = [
      for (final target in targets)
        LetterQuestion(
          target,
          ([target, ...(List.of(letters)..remove(target)..shuffle(rnd)).take(optionCount - 1)])
            ..shuffle(rnd),
        ),
    ];
  }

  static const questionCount = 10;
  static const optionCount = 4;

  final Alphabet alphabet;
  late final List<LetterQuestion> questions;

  int index = 0;
  int mistakes = 0;

  LetterQuestion get current => questions[index];
  bool get isFinished => index == questions.length;
  int get stars => starsForMistakes(mistakes);

  LetterAnswer answer(AlphabetLetter letter) {
    if (letter != current.target) {
      mistakes++;
      return LetterAnswer.wrong;
    }
    index++;
    return isFinished ? LetterAnswer.finished : LetterAnswer.correct;
  }
}
