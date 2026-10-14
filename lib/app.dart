import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_language.dart';
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
    // FR-8: interfeys tili (o'zbek / rus / ingliz). O'yin mazmuni o'zbekcha qoladi.
    final language = ref.watch(appLanguageProvider);

    return MaterialApp.router(
      title: "Aqlli Do'stlar",
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: router,
      // Til almashganda butun ekranlar daraxti qayta quriladi — const vidjetlar ham
      // yangi tildagi matnni oladi. Joriy sahifa (router holati) saqlanadi.
      builder: (context, child) => KeyedSubtree(key: ValueKey(language), child: child!),
      locale: language.locale,
      supportedLocales: [for (final l in AppLanguage.values) l.locale],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
