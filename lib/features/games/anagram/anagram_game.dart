import 'dart:math';

import '../../../core/constants/app_strings.dart';
import '../game_result.dart';
import '../word_builder/word_builder_game.dart' show splitUzbekLetters;

/// So'z turkumi — rasm o'rniga yagona maslahat.
enum AnagramCategory {
  animal(AppStrings.catAnimal),
  food(AppStrings.catFood),
  nature(AppStrings.catNature),
  school(AppStrings.catSchool),
  home(AppStrings.catHome),
  transport(AppStrings.catTransport),
  job(AppStrings.catJob);

  const AnagramCategory(this.label);

  final String label;
}

class AnagramWord {
  const AnagramWord(this.word, this.category);

  final String word;
  final AnagramCategory category;

  /// sh, ch, oʻ, gʻ — bitta harf.
  List<String> get letters => splitUzbekLetters(word);
}

// dart format off
const anagramBank = [
  // 5 harf
  AnagramWord('daryo', AnagramCategory.nature),
  AnagramWord('okean', AnagramCategory.nature),
  AnagramWord('shamol', AnagramCategory.nature),
  AnagramWord('oʻrmon', AnagramCategory.nature),
  AnagramWord('tulki', AnagramCategory.animal),
  AnagramWord('quyon', AnagramCategory.animal),
  AnagramWord('ruchka', AnagramCategory.school),
  AnagramWord('kitob', AnagramCategory.school),
  AnagramWord('metro', AnagramCategory.transport),
  AnagramWord('oshpaz', AnagramCategory.job),
  AnagramWord('divan', AnagramCategory.home),
  AnagramWord('gilam', AnagramCategory.home),
  AnagramWord('banan', AnagramCategory.food),
  AnagramWord('palov', AnagramCategory.food),
  AnagramWord('somsa', AnagramCategory.food),
  // 6–7 harf
  AnagramWord('maktab', AnagramCategory.school),
  AnagramWord('daftar', AnagramCategory.school),
  AnagramWord('poyezd', AnagramCategory.transport),
  AnagramWord('tramvay', AnagramCategory.transport),
  AnagramWord('dehqon', AnagramCategory.job),
  AnagramWord('uchuvchi', AnagramCategory.job),
  AnagramWord('shifokor', AnagramCategory.job),
  AnagramWord('jirafa', AnagramCategory.animal),
  AnagramWord('timsoh', AnagramCategory.animal),
  AnagramWord('kenguru', AnagramCategory.animal),
  AnagramWord('pingvin', AnagramCategory.animal),
  AnagramWord('shaftoli', AnagramCategory.food),
  AnagramWord('vulqon', AnagramCategory.nature),
  AnagramWord('sharshara', AnagramCategory.nature),
  AnagramWord('karavot', AnagramCategory.home),
  // 8+ harf
  AnagramWord('kompyuter', AnagramCategory.home),
  AnagramWord('televizor', AnagramCategory.home),
  AnagramWord('sovutgich', AnagramCategory.home),
  AnagramWord('velosiped', AnagramCategory.transport),
  AnagramWord('vertolyot', AnagramCategory.transport),
  AnagramWord('avtomobil', AnagramCategory.transport),
  AnagramWord('muzqaymoq', AnagramCategory.food),
  AnagramWord('kutubxona', AnagramCategory.school),
  AnagramWord('matematika', AnagramCategory.school),
  AnagramWord('qoʻngʻiroq', AnagramCategory.school),
  AnagramWord('oʻqituvchi', AnagramCategory.job),
  AnagramWord('dengizchi', AnagramCategory.job),
  AnagramWord('dinozavr', AnagramCategory.animal),
  AnagramWord('krokodil', AnagramCategory.animal),
];
// dart format on

/// Daraja so'zdagi harflar soni bilan belgilanadi.
enum AnagramLevel {
  five(label: AppStrings.anagram5, emoji: '🐣', minLetters: 5, maxLetters: 5),
  seven(label: AppStrings.anagram67, emoji: '🐥', minLetters: 6, maxLetters: 7),
  long(label: AppStrings.anagram8, emoji: '🦅', minLetters: 8, maxLetters: 99);

  const AnagramLevel({
    required this.label,
    required this.emoji,
    required this.minLetters,
    required this.maxLetters,
  });

  final String label;
  final String emoji;
  final int minLetters;
  final int maxLetters;

  bool fits(AnagramWord word) {
    final n = word.letters.length;
    return n >= minLetters && n <= maxLetters;
  }
}

enum AnagramOutcome { ignored, placed, wrong, correct, finished }

/// Anagramma: aralash harflardan so'z tuzish. Harflar istalgan tartibda qo'yiladi,
/// so'z to'lganda tekshiriladi; noto'g'ri bo'lsa — bitta xato.
class AnagramGame {
  AnagramGame(this.level, {Random? random, List<AnagramWord> bank = anagramBank})
    : _random = random ?? Random() {
    words = (bank.where(level.fits).toList()..shuffle(_random)).take(wordCount).toList();
    _prepareWord();
  }

  static const wordCount = 8;

  final AnagramLevel level;
  final Random _random;
  late final List<AnagramWord> words;

  int wordIndex = 0;
  int mistakes = 0;

  /// Joriy so'zning aralash harflari.
  List<String> tiles = [];

  /// Kataklarga qo'yilgan kartochkalar indekslari (tartib bilan).
  final List<int> placed = [];

  AnagramWord get current => words[wordIndex];
  bool get isFull => placed.length == tiles.length;
  bool get isLastWord => wordIndex == words.length - 1;
  String get guess => [for (final i in placed) tiles[i]].join();
  int get stars => starsForMistakes(mistakes);

  void _prepareWord() {
    final letters = current.letters;
    tiles = List.of(letters);
    for (var attempt = 0; attempt < 10; attempt++) {
      tiles.shuffle(_random);
      if (tiles.join() != current.word) break;
    }
    placed.clear();
  }

  AnagramOutcome place(int tile) {
    if (isFull || placed.contains(tile)) return AnagramOutcome.ignored;
    placed.add(tile);
    if (!isFull) return AnagramOutcome.placed;
    if (guess != current.word) {
      mistakes++;
      return AnagramOutcome.wrong;
    }
    return isLastWord ? AnagramOutcome.finished : AnagramOutcome.correct;
  }

  /// Katakdagi harfni qaytarib oladi.
  void removeAt(int slot) {
    if (slot < placed.length) placed.removeAt(slot);
  }

  void clear() => placed.clear();

  void nextWord() {
    if (isLastWord) return;
    wordIndex++;
    _prepareWord();
  }
}
