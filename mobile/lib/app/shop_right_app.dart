import 'package:flutter/material.dart';

import '../core/route_observer.dart';
import '../core/theme/app_theme.dart';
import '../data/repositories/repositories.dart';
import '../features/root/root_shell.dart';

class ShopRightApp extends StatefulWidget {
  const ShopRightApp({required this.repositories, super.key});

  final Repositories repositories;

  @override
  State<ShopRightApp> createState() => _ShopRightAppState();
}

class _ShopRightAppState extends State<ShopRightApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shop Right',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _themeMode,
      navigatorObservers: [appRouteObserver],
      home: RootShell(
        repositories: widget.repositories,
        isDarkMode: _themeMode == ThemeMode.dark,
        onThemeChanged: (isDark) {
          setState(
            () => _themeMode = isDark ? ThemeMode.dark : ThemeMode.light,
          );
        },
      ),
    );
  }
}
