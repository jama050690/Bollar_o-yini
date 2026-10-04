import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';
import '../translate/translate_game.dart' show TargetLanguage;

/// O'zbekcha so'z/birikma/gap va uning ruscha, inglizcha tarjimasi.
class PhraseItem {
  const PhraseItem(this.emoji, this.uzbek, this.russian, this.english);

  final String emoji;
  final String uzbek;
  final String russian;
  final String english;

  String translation(TargetLanguage language) =>
      language == TargetLanguage.russian ? russian : english;
}

// dart format off
const _wordItems = [
  PhraseItem('🏫', 'maktab', 'школа', 'school'),
  PhraseItem('👩‍🏫', 'oʻqituvchi', 'учитель', 'teacher'),
  PhraseItem('🤝', 'doʻst', 'друг', 'friend'),
  PhraseItem('👨‍👩‍👧', 'oila', 'семья', 'family'),
  PhraseItem('🏙️', 'shahar', 'город', 'city'),
  PhraseItem('🌞', 'kun', 'день', 'day'),
  PhraseItem('🌃', 'tun', 'ночь', 'night'),
  PhraseItem('🌷', 'bahor', 'весна', 'spring'),
  PhraseItem('⛄', 'qish', 'зима', 'winter'),
  PhraseItem('🌧️', 'yomgʻir', 'дождь', 'rain'),
  PhraseItem('🎒', 'sumka', 'сумка', 'bag'),
  PhraseItem('🚌', 'avtobus', 'автобус', 'bus'),
  PhraseItem('📅', 'hafta', 'неделя', 'week'),
  PhraseItem('🍳', 'nonushta', 'завтрак', 'breakfast'),
  PhraseItem('🏥', 'kasalxona', 'больница', 'hospital'),
  PhraseItem('🗺️', 'xarita', 'карта', 'map'),
];

const _phraseItems = [
  PhraseItem('🍎', 'qizil olma', 'красное яблоко', 'red apple'),
  PhraseItem('🐱', 'kichkina mushuk', 'маленькая кошка', 'small cat'),
  PhraseItem('🏠', 'katta uy', 'большой дом', 'big house'),
  PhraseItem('🏎️', 'tez mashina', 'быстрая машина', 'fast car'),
  PhraseItem('☀️', 'issiq kun', 'жаркий день', 'hot day'),
  PhraseItem('❄️', 'sovuq qish', 'холодная зима', 'cold winter'),
  PhraseItem('📗', 'yangi kitob', 'новая книга', 'new book'),
  PhraseItem('🌳', 'baland daraxt', 'высокое дерево', 'tall tree'),
  PhraseItem('💧', 'toza suv', 'чистая вода', 'clean water'),
  PhraseItem('🐶', 'yaxshi it', 'хорошая собака', 'good dog'),
  PhraseItem('🌸', 'chiroyli gul', 'красивый цветок', 'beautiful flower'),
  PhraseItem('🍞', 'yumshoq non', 'мягкий хлеб', 'soft bread'),
  PhraseItem('🌕', 'yorugʻ oy', 'яркая луна', 'bright moon'),
  PhraseItem('🥛', 'iliq sut', 'тёплое молоко', 'warm milk'),
  PhraseItem('🐦', 'koʻk qush', 'синяя птица', 'blue bird'),
];

const _sentenceItems = [
  PhraseItem('🏫', 'Men maktabga boraman.', 'Я иду в школу.', 'I go to school.'),
  PhraseItem('📖', 'Men kitob oʻqiyman.', 'Я читаю книгу.', 'I read a book.'),
  PhraseItem('☀️', 'Bugun havo issiq.', 'Сегодня жарко.', 'It is hot today.'),
  PhraseItem('🐱', 'Mening mushugim bor.', 'У меня есть кошка.', 'I have a cat.'),
  PhraseItem('⚽', 'Biz futbol oʻynaymiz.', 'Мы играем в футбол.', 'We play football.'),
  PhraseItem('👋', 'Salom, isming nima?', 'Привет, как тебя зовут?', 'Hi, what is your name?'),
  PhraseItem('🙏', 'Katta rahmat!', 'Большое спасибо!', 'Thank you very much!'),
  PhraseItem('🌙', 'Xayrli tun!', 'Спокойной ночи!', 'Good night!'),
  PhraseItem('🍵', 'Men choy ichaman.', 'Я пью чай.', 'I drink tea.'),
  PhraseItem('👨‍👩‍👧', 'Bu mening oilam.', 'Это моя семья.', 'This is my family.'),
  PhraseItem('🎂', 'Men oʻn yoshdaman.', 'Мне десять лет.', 'I am ten years old.'),
  PhraseItem('🌧️', 'Yomgʻir yogʻyapti.', 'Идёт дождь.', 'It is raining.'),
  PhraseItem('🏠', 'Mening uyim katta.', 'Мой дом большой.', 'My house is big.'),
];
// dart format on

/// Daraja: ① so'zlar ② so'z birikmalari ③ qisqa gaplar.
enum TranslatePlusLevel {
  words(label: AppStrings.levelWords, emoji: '🔤', items: _wordItems),
  phrases(label: AppStrings.levelPhrases, emoji: '🧩', items: _phraseItems),
  sentences(label: AppStrings.levelSentences, emoji: '💬', items: _sentenceItems);

  const TranslatePlusLevel({required this.label, required this.emoji, required this.items});

  final String label;
  final String emoji;
  final List<PhraseItem> items;
}

class PhraseQuestion {
  const PhraseQuestion(this.item, this.answer, this.options);

  final PhraseItem item;
  final String answer;
  final List<String> options;
}

enum PhraseOutcome { correct, wrong, finished }

/// Tarjimon+: o'zbekcha so'z/birikma/gapning tarjimasini topish. 10 ta takrorlanmas savol.
class TranslatePlusGame {
  TranslatePlusGame(this.language, this.level, {Random? random}) {
    final rnd = random ?? Random();
    final items = List.of(level.items)..shuffle(rnd);
    questions = [for (final item in items.take(questionCount)) _question(item, rnd)];
  }

  static const questionCount = 10;
  static const optionCount = 4;

  final TargetLanguage language;
  final TranslatePlusLevel level;
  late final List<PhraseQuestion> questions;
  int step = 0;
  int mistakes = 0;

  PhraseQuestion get current => questions[step];
  bool get isFinished => step == questionCount;
  int get stars => starsForMistakes(mistakes);

  PhraseQuestion _question(PhraseItem item, Random rnd) {
    final others = level.items.where((i) => i != item).toList()..shuffle(rnd);
    final answer = item.translation(language);
    return PhraseQuestion(item, answer, [
      answer,
      for (final o in others.take(optionCount - 1)) o.translation(language),
    ]..shuffle(rnd));
  }

  PhraseOutcome answer(String option) {
    if (option != current.answer) {
      mistakes++;
      return PhraseOutcome.wrong;
    }
    step++;
    return isFinished ? PhraseOutcome.finished : PhraseOutcome.correct;
  }
}
