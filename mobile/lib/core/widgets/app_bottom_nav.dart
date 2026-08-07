import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum AppTab { home, history, shops, settings }

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final AppTab selected;
  final ValueChanged<AppTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
            child: Container(
              height: 58,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: dark ? const Color(0xF2141B24) : AppColors.navOverlay,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                  color: dark ? AppColors.nightBorder : AppColors.charcoal,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: AppTab.values.map((tab) {
                  return _NavItem(
                    tab: tab,
                    selected: tab == selected,
                    onTap: () => onSelected(tab),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.onTap,
  });

  final AppTab tab;
  final bool selected;
  final VoidCallback onTap;

  IconData get icon => switch (tab) {
    AppTab.home => CupertinoIcons.house_fill,
    AppTab.history => CupertinoIcons.clock_fill,
    AppTab.shops => CupertinoIcons.bag_fill,
    AppTab.settings => CupertinoIcons.gear_solid,
  };

  String get label => switch (tab) {
    AppTab.home => 'Home',
    AppTab.history => 'History',
    AppTab.shops => 'Shops',
    AppTab.settings => 'Settings',
  };

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: EdgeInsets.symmetric(
            horizontal: selected ? 14 : 12,
            vertical: 9,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected ? AppColors.brand : AppColors.muted,
              ),
              if (selected) ...[
                const SizedBox(width: 7),
                Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.brand,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
