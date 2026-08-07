import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/ui_components.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
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
                children: [
                  Text(
                    'Comparison History',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Your previous price checks, all in one place.',
                    style: TextStyle(
                      color: secondaryTextColor(context),
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
    );
  }
}

Future<void> _refresh() =>
    Future<void>.delayed(const Duration(milliseconds: 850));

class _HistorySummary extends StatelessWidget {
  const _HistorySummary();

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dark ? AppColors.brandDeep : AppColors.brand,
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
                  style: TextStyle(color: AppColors.onBrandMuted, fontSize: 11),
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
          const BrandIconTile(icon: CupertinoIcons.clock_fill, size: 43),
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
                  style: TextStyle(
                    color: secondaryTextColor(context),
                    fontSize: 10,
                  ),
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
