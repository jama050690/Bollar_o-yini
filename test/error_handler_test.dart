import 'package:aqlli_dostlar/core/constants/app_strings.dart';
import 'package:aqlli_dostlar/core/theme/app_theme.dart' show AppSizes;
import 'package:aqlli_dostlar/shared/widgets/error_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('Ishga tushish xatosi: muloyim matn va "Qayta urinish" ishlaydi', (tester) async {
    var retries = 0;
    await tester.pumpWidget(StartupErrorApp(onRetry: () => retries++));

    expect(find.text(AppStrings.errorTitle), findsOneWidget);
    expect(find.text(AppStrings.errorHint), findsOneWidget);
    expect(find.text(AppStrings.errorHomeButton), findsNothing);

    final button = find.widgetWithText(ElevatedButton, AppStrings.errorRetryButton);
    expect(tester.getSize(button).height, greaterThanOrEqualTo(AppSizes.minTapTarget));

    await tester.tap(button);
    expect(retries, 1);
  });

  testWidgets('Ekrandagi xato: "Bosh menyuga" bosh sahifaga qaytaradi', (tester) async {
    final router = GoRouter(
      initialLocation: '/oops',
      routes: [
        GoRoute(path: '/', builder: (_, _) => const Scaffold(body: Text('HOME'))),
        GoRoute(path: '/oops', builder: (_, _) => const AppErrorView()),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));

    final button = find.widgetWithText(ElevatedButton, AppStrings.errorHomeButton);
    expect(tester.getSize(button).height, greaterThanOrEqualTo(AppSizes.minTapTarget));

    await tester.tap(button);
    await tester.pumpAndSettle();
    expect(find.text('HOME'), findsOneWidget);
  });

  testWidgets('Kichik joyda faqat 🙈 belgisi chiqadi', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(child: SizedBox(width: 120, height: 120, child: AppErrorView())),
      ),
    );

    expect(find.text('🙈'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
  });
}
