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

class TranslateQuestion {
  const TranslateQuestion(this.word, this.options);

  final TranslateWord word;

  /// 4 ta tarjima varianti (bittasi to'g'ri).
  final List<String> options;
}

enum TranslateOutcome { correct, wrong, finished }

/// 10 ta takrorlanmaydigan so'z, har birida 4 ta variant.
class TranslateGame {
  TranslateGame(this.language, {Random? random}) {
    final rnd = random ?? Random();
    final words = [...translateWords]..shuffle(rnd);
    questions = [
      for (final word in words.take(questionCount))
        TranslateQuestion(word, _options(word, rnd)),
    ];
  }

  static const questionCount = 10;

  final TargetLanguage language;
  late final List<TranslateQuestion> questions;
  int step = 0;
  int mistakes = 0;

  TranslateQuestion get current => questions[step];
  bool get isFinished => step == questionCount;
  int get stars => starsForMistakes(mistakes);

  List<String> _options(TranslateWord word, Random rnd) {
    final others = translateWords.where((w) => w != word).toList()..shuffle(rnd);
    return [
      word.translation(language),
      for (final w in others.take(3)) w.translation(language),
    ]..shuffle(rnd);
  }

  TranslateOutcome answer(String option) {
    if (option != current.word.translation(language)) {
      mistakes++;
      return TranslateOutcome.wrong;
    }
    step++;
    return isFinished ? TranslateOutcome.finished : TranslateOutcome.correct;
  }
}
