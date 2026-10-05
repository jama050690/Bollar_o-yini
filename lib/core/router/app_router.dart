import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/games/game_catalog.dart';
import '../../features/games/game_result.dart';
import '../../features/games/result/result_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/parent_panel/parent_panel_screen.dart';
import '../../features/parent_panel/pin_screen.dart';
import '../../features/parent_panel/screen_time_providers.dart';
import '../../features/parent_panel/time_up_screen.dart';
import '../../features/profile/profile_create_screen.dart';
import '../../features/profile/profile_providers.dart';
import '../../features/profile/profile_select_screen.dart';
import 'app_routes.dart';

export 'app_routes.dart';

bool _isParentArea(String location) =>
    location == AppRoutes.parentPanel || location == AppRoutes.parentPin;

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppRoutes.home,
    // Foydalanuvchi oqimi (TZ 3-bo'lim):
    // profil yo'q → yaratish (FR-1); faol profil yo'q → tanlash; aks holda → bosh menyu.
    redirect: (context, state) {
      final location = state.matchedLocation;
      final hasProfiles = ref.read(profilesProvider).isNotEmpty;
      final hasActive = ref.read(activeProfileProvider) != null;

      if (!hasProfiles && location != AppRoutes.profileCreate) {
        return AppRoutes.profileCreate;
      }
      if (hasProfiles && !hasActive && !location.startsWith(AppRoutes.profiles)) {
        return AppRoutes.profiles;
      }
      // FR-7: vaqt tugagan bo'lsa, faqat "vaqt tugadi" ekrani va ota-ona paneli ochiq.
      final timeUp = ref.read(timeUpProvider);
      if (timeUp && location != AppRoutes.timeUp && !_isParentArea(location)) {
        return AppRoutes.timeUp;
      }
      if (!timeUp && location == AppRoutes.timeUp) {
        return AppRoutes.home;
      }
      // FR-6: panelga PIN kiritmasdan kirib bo'lmaydi.
      if (location == AppRoutes.parentPanel && state.extra != AppRoutes.parentUnlocked) {
        return AppRoutes.parentPin;
      }
      if (location == AppRoutes.result && state.extra is! GameResult) {
        return AppRoutes.home;
      }
      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.profiles,
        builder: (context, state) => const ProfileSelectScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileCreate,
        builder: (context, state) => const ProfileCreateScreen(),
      ),
      GoRoute(
        path: '/game/:gameId',
        redirect: (context, state) =>
            gameById(state.pathParameters['gameId']!) == null ? AppRoutes.home : null,
        builder: (context, state) => gameById(state.pathParameters['gameId']!)!.builder(),
      ),
      GoRoute(
        path: AppRoutes.result,
        builder: (context, state) => ResultScreen(result: state.extra! as GameResult),
      ),
      GoRoute(
        path: AppRoutes.parentPanel,
        builder: (context, state) => const ParentPanelScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentPin,
        builder: (context, state) =>
            PinScreen(changePin: state.uri.queryParameters['change'] == '1'),
      ),
      GoRoute(
        path: AppRoutes.timeUp,
        builder: (context, state) => const TimeUpScreen(),
      ),
    ],
  );

  // FR-7: vaqt o'yin o'rtasida tugasa ham (yoki ota-ona chegarani o'zgartirsa)
  // yo'naltirish qayta tekshiriladi.
  ref.listen(timeUpProvider, (_, _) => router.refresh());
  return router;
});
