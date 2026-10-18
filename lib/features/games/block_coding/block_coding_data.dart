// Robot dasturchi topshiriqlari.
//
// Belgilar: `.` bo'sh, `#` to'siq, `G` maqsad (🔋),
// robot va uning yo'nalishi: `^` yuqoriga, `v` pastga, `<` chapga, `>` o'ngga.

/// Oson: 5×5, faqat oldinga va burilishlar.
const codingMapsEasy = [
  [
    '.....',
    '.....',
    '>..G.',
    '.....',
    '.....',
  ],
  [
    '.....',
    '...G.',
    '.....',
    '>....',
    '.....',
  ],
  [
    '.....',
    '.....',
    '>.#G.',
    '.....',
    '.....',
  ],
  [
    'G....',
    '###..',
    '.....',
    '..#..',
    'v....',
  ],
];

/// O'rta: 6×6, uzunroq va murakkabroq yo'llar.
const codingMapsMedium = [
  [
    '..#...',
    '>.#.G.',
    '..#...',
    '......',
    '.###..',
    '......',
  ],
  [
    '......',
    '.#.#..',
    '.#.#G.',
    '.#.##.',
    '...#..',
    '>..#..',
  ],
  [
    '......',
    '.####.',
    '.#G...',
    '.#####',
    '>.....',
    '......',
  ],
  [
    '....#G',
    '.##.#.',
    '.#..#.',
    '.#.##.',
    '.#....',
    '^#....',
  ],
];

/// Qiyin: bloklar soni cheklangan — 🔁 takrorlashsiz yechib bo'lmaydi.
const codingMapsHard = [
  [
    '......',
    '......',
    '>....G',
    '......',
    '......',
    '......',
  ],
  [
    '>...#.',
    '###.#.',
    '###.#.',
    'G...#.',
    '......',
    '......',
  ],
  [
    '......',
    '...#G.',
    '..#..#',
    '.#..#.',
    '#..#..',
    '>.#...',
  ],
  [
    '......',
    '....G.',
    '..#...',
    '......',
    '##..#.',
    '>..#..',
  ],
];

/// Qiyin darajadagi har topshiriq uchun bloklar chegarasi (asosiy dastur + takrorlash ichi).
const codingHardLimits = [3, 5, 5, 7];
