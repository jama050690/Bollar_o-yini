import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/router/app_routes.dart';
import '../../core/theme/app_theme.dart';

/// Barcha mini-o'yinlar uchun umumiy ekran: katta "uy" tugmasi va sarlavha.
class GameScaffold extends StatelessWidget {
  const GameScaffold({
    super.key,
    required this.title,
    required this.color,
    required this.child,
    this.trailing,
  });

  final String title;
  final Color color;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.alphaBlend(color.withValues(alpha: 0.18), AppColors.background),
      appBar: AppBar(
        backgroundColor: color,
        toolbarHeight: 72,
        centerTitle: true,
        leading: IconButton(
          iconSize: 40,
          icon: const Icon(Icons.home_rounded),
          onPressed: () =>
              context.canPop() ? context.pop() : context.go(AppRoutes.home),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (trailing != null)
            Padding(padding: const EdgeInsets.only(right: 16), child: trailing),
        ],
      ),
      body: SafeArea(child: child),
    );
  }
}
