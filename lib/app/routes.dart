/// Central route path table. Real URL paths so web deep links and
/// browser back/forward work correctly.
abstract final class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const home = '/';
  static const friends = '/friends';
  static const shop = '/shop';
  static const profile = '/profile';
  static const lobby = '/lobby';
  static const room = '/room/:code';
  static const game = '/game';
  static const results = '/results';
  static const settings = '/settings';
  static const privacy = '/settings/privacy';
  static const leaderboard = '/leaderboard';
  static const memory = '/memory';
  static const snap = '/snap';

  static String roomPath(String code) => '/room/$code';
}
