/// Ilovadagi barcha UI matnlari bitta joyda (MVP: faqat o'zbek tili, FR-8).
/// Rus/ingliz tillari qo'shilganda shu fayl ARB lokalizatsiyaga ko'chiriladi.
abstract final class AppStrings {
  static const appName = "Aqlli Do'stlar";

  // ---------- Profil ----------
  static const createProfileTitle = 'Yangi profil';
  static const nameLabel = 'Isming nima?';
  static const nameHint = 'Ismingni yoz';
  static const ageLabel = 'Yoshing nechida?';
  static const avatarLabel = "Do'stingni tanla";
  static const saveProfile = 'Tayyor!';
  static const whoPlays = "Kim o'ynaydi?";
  static const addProfile = 'Yangi';

  // ---------- Bosh menyu ----------
  static String hello(String name) => 'Salom, $name!';
  static const moduleATitle = 'Kichkintoylar';
  static const moduleBTitle = "O'rta guruh";
  static const moduleCTitle = 'Kattalar';
  static String ageRange(int min, int max) => '$min-$max yosh';
  static String lockedFor(int min, int max) => '🔒 $min-$max yoshlilar uchun';
  static const comingSoon = "Tez orada yangi o'yinlar! 🚀";

  // ---------- O'yinlar ----------
  static const memoryTitle = 'Xotira';
  static const letterNumberTitle = 'Harf-Raqam';
  static const shapeSorterTitle = 'Rang-Shakl';

  static const chooseLevel = 'Darajani tanla';
  static const levelEasy = 'Oson';
  static const levelMedium = "O'rta";
  static const levelHard = 'Qiyin';

  static const chooseMode = 'Nimani o\'ynaymiz?';
  static const modeNumbers = 'Raqamlar';
  static const modeLetters = 'Harflar';
  static const findThis = 'Buni top:';

  static const sortByColor = 'Ranglariga qarab sarala';
  static const sortByShape = 'Shakliga qarab sarala';

  // ---------- Modul B ----------
  static const mathTitle = 'Matematik sarguzasht';
  static String upTo(int max) => '$max gacha';

  static const wordBuilderTitle = "So'z quramchisi";
  static const buildWord = "Harflardan so'z yig'";

  static const mazeQuizTitle = 'Labirint-kviz';
  static const mazeHint = '🚪 Eshikdagi savolga javob ber!';

  static const sudokuTitle = 'Mini-Sudoku';
  static const sudokuRule = 'Har qator, ustun va diagonal = 15';
  static const sudokuPickCell = 'Bo\'sh katakni tanla';

  static String round(int current, int total) => '$current / $total';
  static const tryAgain = "Yana urinib ko'r! 💪";
  static const wellDone = 'Barakalla! 🎉';

  // ---------- Natija ----------
  static const result3 = 'Ajoyib! 🎉';
  static const result2 = "Zo'r! 👏";
  static const result1 = "Yaxshi! Yana o'ynaymizmi? 💪";
  static const playAgain = "Yana o'ynash";
  static const toHome = 'Bosh menyu';

  static String duration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    if (minutes == 0) return '⏱ $seconds soniya';
    return '⏱ $minutes daqiqa $seconds soniya';
  }
}
