import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_strings.dart';
import '../../core/router/app_routes.dart';
import '../../core/storage/hive_storage.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/mascot.dart';

/// Birinchi ochilishdagi ko'rsatma ko'rilganmi. Qurilmada saqlanadi.
class OnboardingDoneNotifier extends Notifier<bool> {
  static const _key = 'onboardingDone';

  @override
  bool build() => HiveStorage.settings.get(_key) as bool? ?? false;

  void finish() {
    HiveStorage.settings.put(_key, true);
    state = true;
  }
}

final onboardingDoneProvider =
    NotifierProvider<OnboardingDoneNotifier, bool>(OnboardingDoneNotifier.new);

class _OnboardingPage {
  const _OnboardingPage(this.emoji, this.message);

  final String emoji;
  final String message;
}

// Getter: matnlar har safar joriy tilda olinadi.
List<_OnboardingPage> get _pages => [
  _OnboardingPage('🎮', AppStrings.onboarding1),
  _OnboardingPage('⭐🪙🎁', AppStrings.onboarding2),
  _OnboardingPage('🔒', AppStrings.onboarding3),
];

/// Birinchi ochilishda 3 sahifalik qisqa ko'rsatma (Donish 🦉 tushuntiradi).
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  bool get _isLast => _page == _pages.length - 1;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() {
    ref.read(onboardingDoneProvider.notifier).finish();
    context.go(AppRoutes.profileCreate);
  }

  void _next() {
    if (_isLast) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: TextButton(
                  style: TextButton.styleFrom(
                    minimumSize: const Size(AppSizes.minTapTarget, AppSizes.minTapTarget),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: _finish,
                  child: Text(AppStrings.onboardingSkip),
                ),
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (page) => setState(() => _page = page),
                children: [for (final page in _pages) _PageBody(page: page)],
              ),
            ),
            _Dots(count: _pages.length, current: _page),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(260, 72),
                ),
                child: Text(_isLast ? AppStrings.onboardingStart : AppStrings.onboardingNext),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PageBody extends StatelessWidget {
  const _PageBody({required this.page});

  final _OnboardingPage page;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(page.emoji, style: const TextStyle(fontSize: 96)),
            ),
            const SizedBox(height: 32),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Mascot(messages: [page.message], size: 72),
            ),
          ],
        ),
      ),
    );
  }
}

/// Qaysi sahifadaligini ko'rsatuvchi nuqtalar.
class _Dots extends StatelessWidget {
  const _Dots({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            margin: const EdgeInsets.symmetric(horizontal: 6),
            width: i == current ? 28 : 12,
            height: 12,
            decoration: BoxDecoration(
              color: i == current ? AppColors.primary : Colors.black26,
              borderRadius: BorderRadius.circular(6),
            ),
          ),
      ],
    );
  }
}
