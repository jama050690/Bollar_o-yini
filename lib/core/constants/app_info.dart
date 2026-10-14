/// Ilova haqidagi o'zgarmas ma'lumotlar ("Ilova haqida" va maxfiylik siyosati uchun).
///
/// [version] pubspec.yaml dagi `version:` bilan bir xil bo'lishi shart —
/// test/about_test.dart buni tekshiradi (versiya ko'tarilganda shu yerni ham yangilang).
abstract final class AppInfo {
  static const version = '1.0.0+1';
  static const author = 'Jamshiddin Babajonov';
  static const email = 'jbm050690@gmail.com';

  /// docs/privacy-policy.html dagi "Kuchga kirgan sana" bilan bir xil.
  static const privacyEffectiveDate = '2026-10-06';

  /// Foydalanuvchiga ko'rinadigan ko'rinish: "1.0.0 (1)".
  static String get displayVersion {
    final parts = version.split('+');
    return parts.length == 2 ? '${parts[0]} (${parts[1]})' : version;
  }
}
