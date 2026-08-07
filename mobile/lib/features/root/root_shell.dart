import 'package:flutter/material.dart';

import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_top_bar.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../results/results_screen.dart';
import '../settings/settings_screen.dart';
import '../shops/shops_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({
    required this.isDarkMode,
    required this.onThemeChanged,
    super.key,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  AppTab _tab = AppTab.home;

  void _switchTab(AppTab tab) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _tab = tab);
  }

  void _openResults() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => ResultsScreen(
          showLoading: true,
          isDarkMode: widget.isDarkMode,
          onThemeChanged: widget.onThemeChanged,
          onTabSelected: _switchTab,
        ),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _tab.index,
            children: [
              HomeScreen(
                isDarkMode: widget.isDarkMode,
                onThemeChanged: widget.onThemeChanged,
                onOpenResults: _openResults,
              ),
              HistoryScreen(),
              ShopsScreen(),
              SettingsScreen(
                isDarkMode: widget.isDarkMode,
                onThemeChanged: widget.onThemeChanged,
              ),
            ],
          ),
          const AppStickyTopBar(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(selected: _tab, onSelected: _switchTab),
          ),
        ],
      ),
    );
  }
}
