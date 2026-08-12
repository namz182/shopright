import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/dates.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/ui_components.dart';
import '../../data/local/models.dart';
import '../../data/repositories/repositories.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({required this.repositories, super.key});

  final Repositories repositories;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ComparisonRecord> _comparisons = const [];
  ({double savings, int count}) _summary = (savings: 0, count: 0);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final comparisons = await widget.repositories.comparisons.comparisons();
      final summary = await widget.repositories.comparisons.monthSummary();
      if (!mounted) return;
      setState(() {
        _comparisons = comparisons;
        _summary = summary;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    await _load();
  }

  Future<void> _delete(ComparisonRecord comparison) async {
    await widget.repositories.comparisons.delete(comparison.id);
    if (!mounted) return;
    setState(() => _comparisons.removeWhere((c) => c.id == comparison.id));
    final summary = await widget.repositories.comparisons.monthSummary();
    if (mounted) setState(() => _summary = summary);
  }

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
                  _HistorySummary(summary: _summary),
                  SizedBox(height: 24),
                  SectionLabel('Recent Comparisons'),
                  SizedBox(height: 11),
                  if (_loading)
                    SoftCard(
                      child: Text(
                        'Loading your comparisons...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: secondaryTextColor(context),
                          fontSize: 13,
                        ),
                      ),
                    )
                  else if (_comparisons.isEmpty)
                    SoftCard(
                      child: Text(
                        'No comparisons yet. Run one from the home screen to see it here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: secondaryTextColor(context),
                          fontSize: 13,
                        ),
                      ),
                    )
                  else
                    ..._comparisons.map(
                      (comparison) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Dismissible(
                          key: ValueKey(comparison.id),
                          direction: DismissDirection.endToStart,
                          onDismissed: (_) => _delete(comparison),
                          background: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5484D),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            padding: const EdgeInsets.only(right: 20),
                            alignment: Alignment.centerRight,
                            child: const Icon(
                              CupertinoIcons.delete,
                              color: Colors.white,
                            ),
                          ),
                          child: _HistoryItem(comparison: comparison),
                        ),
                      ),
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

class _HistorySummary extends StatelessWidget {
  const _HistorySummary({required this.summary});

  final ({double savings, int count}) summary;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: dark ? AppColors.brandDeep : AppColors.brand,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.chart_bar_alt_fill,
            color: AppColors.white,
            size: 25,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${formatZmw(summary.savings)} saved',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'From ${summary.count} ${summary.count == 1 ? 'comparison' : 'comparisons'} this month',
                  style: const TextStyle(
                    color: AppColors.onBrandMuted,
                    fontSize: 11,
                  ),
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
  const _HistoryItem({required this.comparison});

  final ComparisonRecord comparison;

  @override
  Widget build(BuildContext context) {
    final storeCount = comparison.items.map((i) => i.storeName).toSet().length;
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
                  comparison.reference,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatRelativeDateTime(comparison.createdAt),
                  style: TextStyle(
                    color: secondaryTextColor(context),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${comparison.itemsCount} items · $storeCount stores compared',
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            formatZmw(comparison.totalLowest),
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
          ),
        ],
      ),
    );
  }
}
