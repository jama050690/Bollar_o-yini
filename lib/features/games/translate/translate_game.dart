import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../../../shared/services/tts_service.dart';
import '../game_result.dart';

/// Tarjima tili: rus, ingliz, koreys yoki arab.
enum TargetLanguage {
  russian(flag: '🇷🇺', ttsLanguage: TtsService.russian),
  english(flag: '🇬🇧', ttsLanguage: TtsService.english),
  korean(flag: '🇰🇷', ttsLanguage: TtsService.korean),
  arabic(flag: '🇸🇦', ttsLanguage: TtsService.arabic, isRtl: true);

  const TargetLanguage({required this.flag, required this.ttsLanguage, this.isRtl = false});

  String get label => switch (this) {
        TargetLanguage.russian => AppStrings.langRussian,
        TargetLanguage.english => AppStrings.langEnglish,
        TargetLanguage.korean => AppStrings.langKorean,
        TargetLanguage.arabic => AppStrings.langArabic,
      };

  final String flag;
  final String ttsLanguage;

  /// O'ngdan chapga yoziladimi (arab).
  final bool isRtl;
}

class TranslateWord {
  const TranslateWord(
    this.uzbek,
    this.emoji,
    this.russian,
    this.english,
    this.korean,
    this.arabic,
  );

  final String uzbek;
  final String emoji;
  final String russian;
  final String english;
  final String korean;
  final String arabic;

  String translation(TargetLanguage language) => switch (language) {
        TargetLanguage.russian => russian,
        TargetLanguage.english => english,
        TargetLanguage.korean => korean,
        TargetLanguage.arabic => arabic,
      };
}

// dart format off
const translateWords = [
  TranslateWord('olma', '🍎', 'яблоко', 'apple', '사과', 'تفاحة'),
  TranslateWord('nok', '🍐', 'груша', 'pear', '배', 'كمثرى'),
  TranslateWord('banan', '🍌', 'банан', 'banana', '바나나', 'موز'),
  TranslateWord('uzum', '🍇', 'виноград', 'grapes', '포도', 'عنب'),
  TranslateWord('qulupnay', '🍓', 'клубника', 'strawberry', '딸기', 'فراولة'),
  TranslateWord('tarvuz', '🍉', 'арбуз', 'watermelon', '수박', 'بطيخ'),
  TranslateWord('non', '🍞', 'хлеб', 'bread', '빵', 'خبز'),
  TranslateWord('sut', '🥛', 'молоко', 'milk', '우유', 'حليب'),
  TranslateWord('tuxum', '🥚', 'яйцо', 'egg', '달걀', 'بيضة'),
  TranslateWord('mushuk', '🐱', 'кошка', 'cat', '고양이', 'قطة'),
  TranslateWord('it', '🐶', 'собака', 'dog', '개', 'كلب'),
  TranslateWord('ot', '🐴', 'лошадь', 'horse', '말', 'حصان'),
  TranslateWord('sigir', '🐮', 'корова', 'cow', '소', 'بقرة'),
  TranslateWord('baliq', '🐟', 'рыба', 'fish', '물고기', 'سمكة'),
  TranslateWord('qush', '🐦', 'птица', 'bird', '새', 'طائر'),
  TranslateWord('quyon', '🐰', 'заяц', 'rabbit', '토끼', 'أرنب'),
  TranslateWord('ayiq', '🐻', 'медведь', 'bear', '곰', 'دب'),
  TranslateWord('sher', '🦁', 'лев', 'lion', '사자', 'أسد'),
  TranslateWord('uy', '🏠', 'дом', 'house', '집', 'بيت'),
  TranslateWord('mashina', '🚗', 'машина', 'car', '자동차', 'سيارة'),
  TranslateWord('kitob', '📖', 'книга', 'book', '책', 'كتاب'),
  TranslateWord('quyosh', '☀️', 'солнце', 'sun', '해', 'شمس'),
  TranslateWord('oy', '🌙', 'луна', 'moon', '달', 'قمر'),
  TranslateWord('yulduz', '⭐', 'звезда', 'star', '별', 'نجمة'),
  TranslateWord('gul', '🌸', 'цветок', 'flower', '꽃', 'زهرة'),
  TranslateWord('daraxt', '🌳', 'дерево', 'tree', '나무', 'شجرة'),
  TranslateWord('suv', '💧', 'вода', 'water', '물', 'ماء'),
  TranslateWord('koptok', '⚽', 'мяч', 'ball', '공', 'كرة'),
  TranslateWord('soat', '⏰', 'часы', 'clock', '시계', 'ساعة'),
  TranslateWord('qalam', '✏️', 'карандаш', 'pencil', '연필', 'قلم'),
];
// dart format on

/// Daraja: variantlar soni yoki teskari yo'nalish (chet tilidagi so'z → o'zbekchasi).
enum TranslateLevel {
  three(emoji: '🐣', options: 3, isReverse: false),
  four(emoji: '🐥', options: 4, isReverse: false),
  reverse(emoji: '🦅', options: 4, isReverse: true);

  const TranslateLevel({required this.emoji, required this.options, required this.isReverse});

  final String emoji;
  final int options;
  final bool isReverse;

  String get label => isReverse ? AppStrings.levelReverse : AppStrings.optionsCount(options);
}

class TranslateQuestion {
  const TranslateQuestion(this.word, this.prompt, this.answer, this.options);

  final TranslateWord word;

  /// Ekranda ko'rsatiladigan so'z (oddiy rejimda o'zbekcha, teskarida chet tilida).
  final String prompt;

  /// To'g'ri variant.
  final String answer;

  /// Variantlar (bittasi to'g'ri).
  final List<String> options;
}

enum TranslateOutcome { correct, wrong, finished }

/// 10 ta takrorlanmaydigan so'z, darajaga qarab 3–4 ta variant.
class TranslateGame {
  TranslateGame(this.language, {this.level = TranslateLevel.four, Random? random}) {
    final rnd = random ?? Random();
    final words = [...translateWords]..shuffle(rnd);
    questions = [for (final word in words.take(questionCount)) _question(word, rnd)];
  }

  static const questionCount = 10;

  final TargetLanguage language;
  final TranslateLevel level;
  late final List<TranslateQuestion> questions;
  int step = 0;
  int mistakes = 0;

  TranslateQuestion get current => questions[step];
  bool get isFinished => step == questionCount;
  int get stars => starsForMistakes(mistakes);

  String _side(TranslateWord w, {required bool shown}) =>
      shown != level.isReverse ? w.uzbek : w.translation(language);

  TranslateQuestion _question(TranslateWord word, Random rnd) {
    final others = translateWords.where((w) => w != word).toList()..shuffle(rnd);
    final answer = _side(word, shown: false);
    return TranslateQuestion(
      word,
      _side(word, shown: true),
      answer,
      [answer, for (final w in others.take(level.options - 1)) _side(w, shown: false)]
        ..shuffle(rnd),
    );
  }

  TranslateOutcome answer(String option) {
    if (option != current.answer) {
      mistakes++;
      return TranslateOutcome.wrong;
    }
    step++;
    return isFinished ? TranslateOutcome.finished : TranslateOutcome.correct;
  }
}
