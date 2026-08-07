import 'package:flutter/material.dart';

import '../core/route_observer.dart';
import '../core/theme/app_theme.dart';
import '../features/root/root_shell.dart';

class ShopRightApp extends StatefulWidget {
  const ShopRightApp({super.key});

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
