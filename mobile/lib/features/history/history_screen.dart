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
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final comparisons = await widget.repositories.comparisons.comparisons();
      if (!mounted) return;
      setState(() {
        _comparisons = comparisons;
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
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: _refresh,
      edgeOffset: 86,
      displacement: 110,
      color: AppColors.brand,
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
                    const IllustratedEmptyState(
                      icon: CupertinoIcons.clock,
                      title: 'Your history is waiting',
                      message: 'Run a comparison from Home and your price checks will appear here.',
                      accent: AppColors.brand,
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
                          child: _HistoryItem(
                            comparison: comparison,
                            onTap: () => _showDetails(comparison),
                          ),
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

  void _showDetails(ComparisonRecord comparison) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ComparisonDetailsSheet(comparison: comparison),
    );
  }
}

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({required this.comparison, required this.onTap});

  final ComparisonRecord comparison;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final storeCount = comparison.items.map((i) => i.storeName).toSet().length;
    return SoftCard(
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
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
        ),
      ),
    );
  }
}

class _ComparisonDetailsSheet extends StatelessWidget {
  const _ComparisonDetailsSheet({required this.comparison});

  final ComparisonRecord comparison;

  @override
  Widget build(BuildContext context) {
    final stores = comparison.items.map((item) => item.storeName).whereType<String>().toSet().toList();
    return DraggableScrollableSheet(
      initialChildSize: .72,
      minChildSize: .45,
      maxChildSize: .94,
      expand: false,
      builder: (context, controller) => Material(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: ListView(
          controller: controller,
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          children: [
            Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(10)))),
            const SizedBox(height: 20),
            Row(children: [
              const Expanded(child: Text('Comparison details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900))),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(CupertinoIcons.xmark, size: 16), style: IconButton.styleFrom(backgroundColor: AppColors.soft)),
            ]),
            Text(comparison.reference, style: const TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(formatRelativeDateTime(comparison.createdAt), style: TextStyle(color: secondaryTextColor(context), fontSize: 11)),
            const SizedBox(height: 20),
            _SummaryPanel(comparison: comparison),
            const SizedBox(height: 22),
            const SectionLabel('Items compared'),
            const SizedBox(height: 10),
            if (comparison.items.isEmpty)
              const IllustratedEmptyState(
                icon: CupertinoIcons.doc_text_search,
                title: 'No priced items',
                message: 'This comparison did not find prices for the selected products.',
                compact: true,
                accent: AppColors.muted,
              )
            else
              ...comparison.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: SoftCard(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(children: [
                        const BrandIconTile(icon: CupertinoIcons.cart_fill, size: 36),
                        const SizedBox(width: 10),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(item.productName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                          const SizedBox(height: 3),
                          Text('${item.storeName ?? 'Store unavailable'} · Qty ${item.quantity}', style: const TextStyle(color: AppColors.muted, fontSize: 10)),
                        ])),
                        Text(formatZmw(item.lineTotal), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                      ]),
                    ),
                  )),
            const SizedBox(height: 14),
            Text(stores.isEmpty ? 'Stores: —' : 'Stores: ${stores.join(', ')}', style: const TextStyle(color: AppColors.muted, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _SummaryPanel extends StatelessWidget {
  const _SummaryPanel({required this.comparison});

  final ComparisonRecord comparison;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      color: Theme.of(context).brightness == Brightness.dark ? AppColors.brandDeep : AppColors.brand,
      child: Column(children: [
        Row(children: [const Expanded(child: Text('Lowest basket total', style: TextStyle(color: AppColors.white, fontSize: 11))), Text(formatZmw(comparison.totalLowest), style: const TextStyle(color: AppColors.white, fontSize: 20, fontWeight: FontWeight.w900))]),
        const SizedBox(height: 12),
        _SummaryLine(label: 'Cheapest single store', value: formatZmw(comparison.totalCheapestStore)),
        _SummaryLine(label: 'Savings', value: formatZmw(comparison.totalSavings)),
        if (comparison.budget != null) _SummaryLine(label: 'Budget', value: formatZmw(comparison.budget!)),
      ]),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Row(children: [Expanded(child: Text(label, style: const TextStyle(color: AppColors.onBrandMuted, fontSize: 10))), Text(value, style: const TextStyle(color: AppColors.white, fontSize: 12, fontWeight: FontWeight.w800))]),
      );
}
