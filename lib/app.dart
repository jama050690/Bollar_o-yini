import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/parent_panel/screen_time_providers.dart';

class AqlliDostlarApp extends ConsumerWidget {
  const AqlliDostlarApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    // FR-7: ilova ochiq turgan paytda kunlik o'yin vaqti hisoblanadi.
    ref.watch(screenTimeTickerProvider);

    return MaterialApp.router(
      title: "Aqlli Do'stlar",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      // MVP: faqat o'zbek tili (FR-8). Rus/ingliz keyinroq qo'shiladi.
      locale: const Locale('uz'),
      supportedLocales: const [Locale('uz')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
