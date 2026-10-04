import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../../../shared/services/tts_service.dart';
import '../game_result.dart';

/// Tarjima tili: rus yoki ingliz.
enum TargetLanguage {
  russian(label: AppStrings.langRussian, flag: '🇷🇺', ttsLanguage: TtsService.russian),
  english(label: AppStrings.langEnglish, flag: '🇬🇧', ttsLanguage: TtsService.english);

  const TargetLanguage({required this.label, required this.flag, required this.ttsLanguage});

  final String label;
  final String flag;
  final String ttsLanguage;
}

class TranslateWord {
  const TranslateWord(this.uzbek, this.emoji, this.russian, this.english);

  final String uzbek;
  final String emoji;
  final String russian;
  final String english;

  String translation(TargetLanguage language) =>
      language == TargetLanguage.russian ? russian : english;
}

const translateWords = [
  TranslateWord('olma', '🍎', 'яблоко', 'apple'),
  TranslateWord('nok', '🍐', 'груша', 'pear'),
  TranslateWord('banan', '🍌', 'банан', 'banana'),
  TranslateWord('uzum', '🍇', 'виноград', 'grapes'),
  TranslateWord('qulupnay', '🍓', 'клубника', 'strawberry'),
  TranslateWord('tarvuz', '🍉', 'арбуз', 'watermelon'),
  TranslateWord('non', '🍞', 'хлеб', 'bread'),
  TranslateWord('sut', '🥛', 'молоко', 'milk'),
  TranslateWord('tuxum', '🥚', 'яйцо', 'egg'),
  TranslateWord('mushuk', '🐱', 'кошка', 'cat'),
  TranslateWord('it', '🐶', 'собака', 'dog'),
  TranslateWord('ot', '🐴', 'лошадь', 'horse'),
  TranslateWord('sigir', '🐮', 'корова', 'cow'),
  TranslateWord('baliq', '🐟', 'рыба', 'fish'),
  TranslateWord('qush', '🐦', 'птица', 'bird'),
  TranslateWord('quyon', '🐰', 'заяц', 'rabbit'),
  TranslateWord('ayiq', '🐻', 'медведь', 'bear'),
  TranslateWord('sher', '🦁', 'лев', 'lion'),
  TranslateWord('uy', '🏠', 'дом', 'house'),
  TranslateWord('mashina', '🚗', 'машина', 'car'),
  TranslateWord('kitob', '📖', 'книга', 'book'),
  TranslateWord('quyosh', '☀️', 'солнце', 'sun'),
  TranslateWord('oy', '🌙', 'луна', 'moon'),
  TranslateWord('yulduz', '⭐', 'звезда', 'star'),
  TranslateWord('gul', '🌸', 'цветок', 'flower'),
  TranslateWord('daraxt', '🌳', 'дерево', 'tree'),
  TranslateWord('suv', '💧', 'вода', 'water'),
  TranslateWord('koptok', '⚽', 'мяч', 'ball'),
  TranslateWord('soat', '⏰', 'часы', 'clock'),
  TranslateWord('qalam', '✏️', 'карандаш', 'pencil'),
];

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
