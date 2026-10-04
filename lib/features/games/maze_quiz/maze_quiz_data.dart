// Labirint-kviz uchun kontent: qo'lda chizilgan 5x5, 7x7, 9x9 labirintlar va savollar.
//
// Labirint belgilari:
//   `#` devor, `.` yo'l, `S` boshlanish, `E` chiqish, `D` savolli eshik.

// dart format off
/// Oson daraja: 5x5, 2 tadan eshik.
const mazeMaps5 = [
  [
    'S.#..',
    '#.#E#',
    '..#D#',
    'D##.#',
    '.....',
  ],
  [
    'S...#',
    '###D#',
    'E.#..',
    '#D#.#',
    '#...#',
  ],
];

/// Qiyin daraja: 9x9, 3–4 ta eshik.
const mazeMaps9 = [
  [
    'S.......#',
    '#######D#',
    '#.......#',
    '#D#######',
    '#...#...#',
    '###.#.#.#',
    '#...#.#D#',
    '#.###.#.#',
    '#.....#.E',
  ],
  [
    'S.....#..',
    '#####.#..',
    '...#..D.#',
    '.#.####.#',
    '.#...D..#',
    '.###.####',
    '...#.D...',
    '##.#####.',
    'E.D......',
  ],
];

/// O'rta daraja: 7x7.
const mazeMaps = [
  // 1-daraja: 2 ta eshik
  [
    'S...#..',
    '###.#.#',
    '....D..',
    '.#####.',
    '...#E#.',
    '##.#D#.',
    '...#...',
  ],
  // 2-daraja: 3 ta eshik
  [
    'S.#....',
    '#.#.##.',
    '..D.#..',
    '.####D#',
    '...#...',
    '##.#.#D',
    '...#.#E',
  ],
  // 3-daraja: 4 ta eshik (ikki xil yo'l bor)
  [
    'S..#...',
    '##D#.#.',
    '...#D#.',
    '.#...#.',
    '.#####D',
    '...D...',
    '######E',
  ],
];
// dart format on

class QuizQuestion {
  const QuizQuestion(this.text, this.options, this.answerIndex);

  final String text;
  final List<String> options;
  final int answerIndex;

  String get answer => options[answerIndex];
}

/// Tabiat, hayvonlar va matematika bo'yicha oddiy savollar.
const quizQuestions = [
  QuizQuestion('🐄 Sigir nima beradi?', ['Sut 🥛', 'Tuxum 🥚', 'Asal 🍯'], 0),
  QuizQuestion('Bir haftada necha kun bor?', ['5', '7', '10'], 1),
  QuizQuestion('7 + 8 = ?', ['14', '15', '16'], 1),
  QuizQuestion('Qaysi biri uchadi?', ['Fil 🐘', 'Burgut 🦅', 'Toshbaqa 🐢'], 1),
  QuizQuestion('❄️ Qor qaysi faslda yogʻadi?', ['Yoz ☀️', 'Qish ⛄', 'Kuz 🍂'], 1),
  QuizQuestion('20 − 6 = ?', ['12', '14', '16'], 1),
  QuizQuestion('🍯 Asalni kim yigʻadi?', ['Kapalak 🦋', 'Ari 🐝', 'Chumoli 🐜'], 1),
  QuizQuestion('☀️ Quyosh qayerdan chiqadi?', ['Sharq', 'Gʻarb', 'Shimol'], 0),
  QuizQuestion('3 × 4 = ?', ['10', '12', '14'], 1),
  QuizQuestion('Yilda nechta fasl bor?', ['3', '4', '5'], 1),
  QuizQuestion('🐟 Baliq qayerda yashaydi?', ['Suvda 🌊', 'Daraxtda 🌳', 'Qumda 🏜️'], 0),
  QuizQuestion('Qaysi hayvon eng katta?', ['Mushuk 🐱', 'Fil 🐘', 'Quyon 🐰'], 1),
  QuizQuestion('9 + 5 = ?', ['13', '14', '15'], 1),
  QuizQuestion('🌈 Kamalakda nechta rang bor?', ['5', '7', '9'], 1),
  QuizQuestion('Qaysi biri meva?', ['Sabzi 🥕', 'Olma 🍎', 'Kartoshka 🥔'], 1),
  QuizQuestion('50 − 25 = ?', ['20', '25', '30'], 1),
  QuizQuestion('🌱 Oʻsimlikka nima kerak?', ['Suv 💧', 'Muz 🧊', 'Qum 🏜️'], 0),
  QuizQuestion('🐔 Tovuq nima beradi?', ['Tuxum 🥚', 'Sut 🥛', 'Jun 🧶'], 0),
  QuizQuestion('Bir soatda necha daqiqa bor?', ['30', '60', '100'], 1),
  QuizQuestion('2 × 8 = ?', ['14', '16', '18'], 1),
  QuizQuestion('Qaysi qush tunda uygʻoq?', ['Tovuq 🐔', 'Boyoʻgʻli 🦉', 'Kaptar 🕊️'], 1),
  QuizQuestion('🧊 Muz erisa nima boʻladi?', ['Suv 💧', 'Qum 🏜️', 'Tosh'], 0),
];
