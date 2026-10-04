import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';

/// So'z va unga mos rasm (emoji). Harflarga ajratish [splitUzbekLetters] orqali.
class WordEntry {
  const WordEntry(this.word, this.emoji);

  final String word;
  final String emoji;

  List<String> get letters => splitUzbekLetters(word);
}

/// O'zbek so'zini harflarga ajratadi: sh, ch, oʻ, gʻ — bitta harf (bitta kartochka).
List<String> splitUzbekLetters(String word) {
  const digraphs = ['sh', 'ch', 'oʻ', 'gʻ'];
  final result = <String>[];
  var i = 0;
  while (i < word.length) {
    if (i + 1 < word.length && digraphs.contains(word.substring(i, i + 2))) {
      result.add(word.substring(i, i + 2));
      i += 2;
    } else {
      result.add(word[i]);
      i += 1;
    }
  }
  return result;
}

/// 3–8 harfli so'zlar ro'yxati (har darajaga kamida 8 tadan).
const wordBank = [
  WordEntry('olma', '🍎'),
  WordEntry('mushuk', '🐱'),
  WordEntry('quyosh', '☀️'),
  WordEntry('baliq', '🐟'),
  WordEntry('kitob', '📚'),
  WordEntry('non', '🍞'),
  WordEntry('gul', '🌸'),
  WordEntry('qush', '🐦'),
  WordEntry('tuxum', '🥚'),
  WordEntry('sut', '🥛'),
  WordEntry('choy', '🍵'),
  WordEntry('daraxt', '🌳'),
  WordEntry('mashina', '🚗'),
  WordEntry('sigir', '🐄'),
  WordEntry('tovuq', '🐔'),
  WordEntry('ayiq', '🐻'),
  WordEntry('tulki', '🦊'),
  WordEntry('sher', '🦁'),
  WordEntry('fil', '🐘'),
  WordEntry('qor', '❄️'),
  WordEntry('yulduz', '⭐'),
  WordEntry('bulut', '☁️'),
  WordEntry('uzum', '🍇'),
  WordEntry('qovun', '🍈'),
  WordEntry('tarvuz', '🍉'),
  WordEntry('oʻrdak', '🦆'),
  WordEntry('qoʻy', '🐑'),
  WordEntry('qoʻl', '✋'),
  WordEntry('toʻp', '⚽'),
  WordEntry('chumoli', '🐜'),
  WordEntry('soat', '⌚'),
  WordEntry('kalit', '🔑'),
  WordEntry('qalam', '✏️'),
  WordEntry('tish', '🦷'),
  WordEntry('koʻz', '👁️'),
  WordEntry('limon', '🍋'),
  WordEntry('sabzi', '🥕'),
  WordEntry('qayiq', '⛵'),
  WordEntry('kapalak', '🦋'),
  WordEntry('samolyot', '✈️'),
  WordEntry('qurbaqa', '🐸'),
  WordEntry('toshbaqa', '🐢'),
  WordEntry('pomidor', '🍅'),
  WordEntry('kartoshka', '🥔'),
  WordEntry('kamalak', '🌈'),
];

/// Daraja so'zdagi harflar soni bilan belgilanadi.
enum WordLevel {
  short(label: AppStrings.wordLevelShort, emoji: '🐣', minLetters: 3, maxLetters: 4),
  medium(label: AppStrings.wordLevelMedium, emoji: '🐥', minLetters: 5, maxLetters: 5),
  long(label: AppStrings.wordLevelLong, emoji: '🦅', minLetters: 6, maxLetters: 99);

  const WordLevel({
    required this.label,
    required this.emoji,
    required this.minLetters,
    required this.maxLetters,
  });

  final String label;
  final String emoji;
  final int minLetters;
  final int maxLetters;

  bool fits(WordEntry entry) {
    final n = entry.letters.length;
    return n >= minLetters && n <= maxLetters;
  }
}

enum LetterOutcome { correct, wrong, wordFinished, gameFinished }

/// So'z quramchisi mantiqi: aralash harflardan so'zni tartib bilan yig'ish.
class WordBuilderGame {
  WordBuilderGame(this.level, {Random? random, List<WordEntry> bank = wordBank})
    : _random = random ?? Random() {
    words = (bank.where(level.fits).toList()..shuffle(_random)).take(wordCount).toList();
    _prepareWord();
  }

  static const wordCount = 8;

  final WordLevel level;
  final Random _random;
  late final List<WordEntry> words;

  int wordIndex = 0;
  int mistakes = 0;

  /// Joriy so'z uchun aralashtirilgan kartochkalar.
  List<String> tiles = [];

  /// Ishlatilgan kartochkalar indekslari.
  final Set<int> usedTiles = {};

  /// Nechta harf joyiga qo'yildi.
  int placed = 0;

  WordEntry get current => words[wordIndex];
  List<String> get currentLetters => current.letters;
  bool get isWordComplete => placed == currentLetters.length;
  bool get isLastWord => wordIndex == words.length - 1;
  int get stars => starsForMistakes(mistakes);

  void _prepareWord() {
    final letters = currentLetters;
    tiles = List.of(letters);
    // Aralashgan tartib asl so'z bilan bir xil bo'lmasin (agar iloji bo'lsa).
    for (var attempt = 0; attempt < 10; attempt++) {
      tiles.shuffle(_random);
      if (tiles.join() != letters.join()) break;
    }
    usedTiles.clear();
    placed = 0;
  }

  LetterOutcome tapTile(int index) {
    if (usedTiles.contains(index) || isWordComplete) return LetterOutcome.wrong;
    if (tiles[index] != currentLetters[placed]) {
      mistakes++;
      return LetterOutcome.wrong;
    }
    usedTiles.add(index);
    placed++;
    if (!isWordComplete) return LetterOutcome.correct;
    return isLastWord ? LetterOutcome.gameFinished : LetterOutcome.wordFinished;
  }

  void nextWord() {
    if (isLastWord) return;
    wordIndex++;
    _prepareWord();
  }
}
