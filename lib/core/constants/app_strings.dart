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

  // ---------- Modul A (qo'shimcha) ----------
  static const timesTableTitle = 'Karra jadvali';
  static String timesLevel(int max) => '×1 – ×$max';

  static const alphabetsTitle = 'Alifbolar';
  static const chooseAlphabet = 'Alifboni tanla';
  static const findLetter = 'Qaysi harf?';

  static const countingTitle = 'Sanash';
  static const chooseLanguage = 'Tilni tanla';
  static const findNumber = 'Qaysi son?';

  static const langUzbek = 'Oʻzbek';
  static const langRussian = 'Rus';
  static const langEnglish = 'Ingliz';

  static const shapeBuilderTitle = 'Shakldan buyum';
  static const dragShapes = 'Shakllarni joyiga sudra';
  static const objHouse = 'Uy';
  static const objCar = 'Mashina';
  static const objTree = 'Daraxt';
  static const objRocket = 'Raketa';
  static const objCat = 'Mushuk';

  static const coloringTitle = "Rasm bo'yash";
  static const choosePicture = 'Rasmni tanla';
  static const coloringHint = "Rangni tanla va rasmni bos";
  static const coloringDone = 'Tayyor! ✅';
  static const clearAll = 'Tozalash';
  static const picBalloons = 'Sharlar';
  static const picApple = 'Olma';
  static const picPear = 'Nok';
  static const picStrawberry = 'Qulupnay';
  static const picCat = 'Mushuk';
  static const picFish = 'Baliq';
  static const picButterfly = 'Kapalak';
  static const picHouse = 'Uy';
  static const picStar = 'Yulduz';
  static const picFlower = 'Gul';

  static const matchPairsTitle = 'Juftini top';
  static const findPair = 'Juftini top:';
  static const pairsFood = 'Ovqati';
  static const pairsTools = 'Asbobi';
  static const pairsMixed = 'Aralash';

  static const patternsTitle = 'Naqsh';
  static const continuePattern = 'Nima keladi?';

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

  static const crosswordTitle = 'Mini-krossvord';
  static String wordsCount(int n) => "$n ta so'z";
  static const crosswordHint = "Rasmni bos, so'ng harflarni tanla";

  static const arithmeticTitle = 'Arifmetika';
  static const levelAddSub = '+  −';
  static const levelMulDiv = '×  ÷';
  static const levelMixed = '+ − × ÷';

  static const translateTitle = 'Tarjimon';
  static const translateHint = 'Tarjimasini top:';
  static const translateReverseHint = "O'zbekchasini top:";
  static const levelReverse = 'Teskari';
  static String optionsCount(int n) => '$n ta variant';

  static const wordLevelShort = '3–4 harf';
  static const wordLevelMedium = '5 harf';
  static const wordLevelLong = '6+ harf';

  static String mazeSize(int n) => '$n×$n';

  static const clockTitle = 'Soat';
  static const whatTime = 'Soat necha?';
  static const clockHours = 'Butun soat';
  static const clockHalves = 'Yarim soat';
  static const clockFives = '5 daqiqa';

  static const shopTitle = "Do'kon";
  static const shopTotal = 'Hammasi necha pul?';
  static const shopChange = 'Qaytim qancha?';
  static const shopLevelTwo = '2 ta narsa';
  static const shopLevelThree = '3 ta narsa';
  static const shopLevelChange = 'Qaytim';
  static String som(int thousands) => "$thousands 000 so'm";
  static String shopPaid(int thousands) => "💵 Berildi: $thousands 000 so'm";

  static const fractionsTitle = 'Kasrlar';
  static const whichFraction = 'Qancha qismi rangli?';
  static const whichBigger = 'Qaysi biri katta?';
  static const fracBasic = '½  ⅓  ¼';
  static const fracMore = '⅕ … ⅛';
  static const fracCompare = 'Solishtir';

  // ---------- Modul C ----------
  static const equationsTitle = 'Tenglamalar';
  static const findX = 'x nechaga teng?';
  static const levelEqAdd = 'x + a = b';
  static const levelEqMul = 'a · x = b';
  static const levelEqTwo = 'a · x + b = c';

  static const sequenceTitle = 'Ketma-ketlik';
  static const nextNumber = 'Keyingi son qaysi?';
  static const levelSeqPlus = '+  −';
  static const levelSeqTimes = '×2  ×3';
  static const levelSeqTricky = 'Qiyin naqsh';

  static const geometryTitle = 'Geometriya';
  static const perimeterQuestion = 'Perimetri nechaga teng?';
  static const areaQuestion = 'Yuzi nechaga teng?';
  static String missingSideQuestion(int area) => 'Yuzi $area sm². "?" nechaga teng?';
  static const levelPerimeter = 'Perimetr';
  static const levelArea = 'Yuz';
  static const levelGeoMix = 'Uchburchak';
  static String cm(int n) => '$n sm';
  static String cm2(int n) => '$n sm²';

  static const percentTitle = 'Foizlar';
  static String percentOf(int n, int p) => '$n ning $p% i';
  static String discount(int p) => '🏷️ −$p% chegirma';
  static const newPrice = 'Yangi narx qancha?';
  static const levelPercentEasy = '50%  25%  10%';
  static const levelPercentMore = '5% … 75%';
  static const levelDiscount = 'Chegirma';

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
