/// Marshrut yo'llari.
abstract final class AppRoutes {
  static const home = '/';
  static const profiles = '/profiles';
  static const profileCreate = '/profiles/create';
  static const result = '/result';

  // Ota-ona paneli (FR-6, FR-7)
  static const parentPanel = '/parent';
  static const parentPin = '/parent/pin';
  static const parentPinChange = '/parent/pin?change=1';
  static const timeUp = '/time-up';

  /// PIN to'g'ri kiritilgandan keyin panelga `extra` sifatida beriladi.
  static const parentUnlocked = 'parentUnlocked';

  static String game(String gameId) => '/game/$gameId';
}
