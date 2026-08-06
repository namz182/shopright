import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_top_bar.dart';
import '../../core/widgets/ui_components.dart';
import '../settings/settings_screen.dart';
import '../shops/shops_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    required this.isDarkMode,
    required this.onThemeChanged,
    super.key,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  void _selectTab(BuildContext context, AppTab tab) {
    final Widget? screen = switch (tab) {
      AppTab.home => null,
      AppTab.history => null,
      AppTab.shops => ShopsScreen(
        isDarkMode: isDarkMode,
        onThemeChanged: onThemeChanged,
      ),
      AppTab.settings => SettingsScreen(
        isDarkMode: isDarkMode,
        onThemeChanged: onThemeChanged,
      ),
    };
    if (tab == AppTab.home) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else if (screen != null) {
      Navigator.of(context).pushReplacement(_fadeRoute(screen));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator.adaptive(
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                SliverSafeArea(
                  bottom: false,
                  sliver: SliverPadding(
                    padding: const EdgeInsets.fromLTRB(22, 86, 22, 112),
                    sliver: SliverList.list(
                      children: const [
                        Text(
                          'Comparison History',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 7),
                        Text(
                          'Your previous price checks, all in one place.',
                          style: TextStyle(
                            color: AppColors.slate,
                            fontSize: 13,
                          ),
                        ),
                        SizedBox(height: 24),
                        _HistorySummary(),
                        SizedBox(height: 24),
                        SectionLabel('Recent Comparisons'),
                        SizedBox(height: 11),
                        _HistoryItem(
                          id: 'CMP-904-ZM21',
                          date: 'Today, 09:41',
                          items: '3 items · 4 stores compared',
                          total: 'ZMW 860.00',
                        ),
                        SizedBox(height: 10),
                        _HistoryItem(
                          id: 'CMP-882-ZM09',
                          date: 'Yesterday, 16:18',
                          items: '5 items · 3 stores compared',
                          total: 'ZMW 1,245.50',
                        ),
                        SizedBox(height: 10),
                        _HistoryItem(
                          id: 'CMP-856-ZM72',
                          date: '28 July 2026',
                          items: '2 items · 4 stores compared',
                          total: 'ZMW 395.00',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const AppStickyTopBar(),
          AppBottomNav(
            selected: AppTab.history,
            onSelected: (tab) => _selectTab(context, tab),
          ),
        ],
      ),
    );
  }
}

Future<void> _refresh() =>
    Future<void>.delayed(const Duration(milliseconds: 850));

PageRoute<void> _fadeRoute(Widget screen) => PageRouteBuilder<void>(
  pageBuilder: (_, _, _) => screen,
  transitionsBuilder: (_, animation, _, child) =>
      FadeTransition(opacity: animation, child: child),
);

class _HistorySummary extends StatelessWidget {
  const _HistorySummary();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Row(
        children: [
          Icon(
            CupertinoIcons.chart_bar_alt_fill,
            color: AppColors.white,
            size: 25,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ZMW 215.00 saved',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'From 3 comparisons this month',
                  style: TextStyle(color: AppColors.muted, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({
    required this.id,
    required this.date,
    required this.items,
    required this.total,
  });

  final String id;
  final String date;
  final String items;
  final String total;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(CupertinoIcons.clock_fill, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  id,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(color: AppColors.slate, fontSize: 10),
                ),
                const SizedBox(height: 2),
                Text(
                  items,
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            total,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
