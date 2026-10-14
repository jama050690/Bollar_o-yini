/// Marshrut yo'llari.
abstract final class AppRoutes {
  static const home = '/';
  static const welcome = '/welcome';
  static const profiles = '/profiles';
  static const profileCreate = '/profiles/create';
  static const result = '/result';
  static const rewards = '/rewards';
  static const achievements = '/achievements';
  static const certificate = '/certificate';

  // Ota-ona paneli (FR-6, FR-7)
  static const parentPanel = '/parent';
  static const parentPin = '/parent/pin';
  static const parentPinChange = '/parent/pin?change=1';
  static const timeUp = '/time-up';

  static String game(String gameId) => '/game/$gameId';
}
