import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_top_bar.dart';
import '../../core/widgets/ui_components.dart';
import '../../data/local/models.dart';
import 'comparison_result.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({
    required this.result,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onTabSelected,
    this.showLoading = false,
    super.key,
  });

  final ComparisonResult result;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<AppTab> onTabSelected;
  final bool showLoading;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late bool _loading = widget.showLoading;

  @override
  void initState() {
    super.initState();
    if (_loading) {
      Timer(const Duration(milliseconds: 1350), () {
        if (mounted) setState(() => _loading = false);
      });
    }
  }

  void _selectTab(AppTab tab) {
    widget.onTabSelected(tab);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          RefreshIndicator.adaptive(
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
                  sliver: SliverList.list(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 86, 22, 112),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          child: _loading
                              ? const _ResultsSkeleton()
                              : _ResultsBody(
                                  result: widget.result,
                                  onSelectItem: _showStorePrices,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: _ResultsHeader(onBack: () => Navigator.of(context).pop()),
            ),
          ),
          AppBottomNav(selected: AppTab.home, onSelected: _selectTab),
        ],
      ),
    );
  }

  void _showStorePrices(ComparisonItem item) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _StorePricesSheet(
        item: itemLabel(item.productName, item.quantity),
        prices: item.prices,
      ),
    );
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (mounted) setState(() => _loading = false);
  }
}

String itemLabel(String name, int quantity) =>
    quantity > 1 ? '$name (x$quantity)' : name;

class _ResultsHeader extends StatelessWidget {
  const _ResultsHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 7, 18, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: const Border(bottom: BorderSide(color: AppColors.soft)),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(CupertinoIcons.back, size: 19),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.soft,
              fixedSize: const Size(38, 38),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(child: AppTopBar(title: 'Comparison Results', trailing: SizedBox.shrink())),
        ],
      ),
    );
  }
}

class _ResultsBody extends StatelessWidget {
  const _ResultsBody({required this.result, required this.onSelectItem});

  final ComparisonResult result;
  final ValueChanged<ComparisonItem> onSelectItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('results'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ComparisonIdentity(reference: result.reference),
        const SizedBox(height: 16),
        _ComparisonChecks(result: result),
        if (result.unavailableProducts.isNotEmpty) ...[
          const SizedBox(height: 12),
          _UnavailableProductsCard(products: result.unavailableProducts),
        ],
        const SizedBox(height: 24),
        SectionLabel(
          'Best price for each item',
          trailing: const Text(
            'Tap to compare',
            style: TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ),
        const SizedBox(height: 11),
        if (result.items.isEmpty)
          const IllustratedEmptyState(
            icon: CupertinoIcons.cart_badge_minus,
            title: 'No item prices found',
            message: 'There are no available prices to display for this comparison.',
            compact: true,
            accent: AppColors.muted,
          )
        else
          for (final item in result.items) ...[
            _LowestPriceCard(
              item: itemLabel(item.productName, item.quantity),
              store: item.storeName,
              price: formatZmw(item.unitPrice),
              onTap: () => onSelectItem(item),
            ),
            const SizedBox(height: 9),
          ],
        if (result.items.isNotEmpty) const SizedBox(height: 15),
        const SectionLabel('One-store basket totals'),
        const SizedBox(height: 11),
        _ShopTotals(
          storeTotals: result.storeTotals,
          totalLowest: result.totalLowest,
        ),
      ],
    );
  }
}

class _UnavailableProductsCard extends StatelessWidget {
  const _UnavailableProductsCard({required this.products});

  final List<String> products;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF3A2B20)
            : const Color(0xFFFFF4E8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF765338)
              : const Color(0xFFF1C38F),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            CupertinoIcons.info_circle_fill,
            size: 18,
            color: Color(0xFFC87524),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${products.join(', ')} ${products.length == 1 ? 'was' : 'were'} not found in any store in your selected location.',
              style: const TextStyle(
                fontSize: 11,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ComparisonChecks extends StatelessWidget {
  const _ComparisonChecks({required this.result});

  final ComparisonResult result;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: Row(
        children: [
          Expanded(child: _LowestCheck(total: result.totalLowest, items: result.itemsCount)),
          const SizedBox(width: 10),
          Expanded(
            child: result.budget == null
                ? const _NoBudgetCheck()
                : _BudgetCheck(total: result.totalLowest, budget: result.budget!),
          ),
        ],
      ),
    );
  }
}

class _LowestCheck extends StatelessWidget {
  const _LowestCheck({required this.total, required this.items});

  final double total;
  final int items;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? AppColors.brandDeep : AppColors.brand,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Lowest price', style: TextStyle(color: AppColors.onBrandMuted, fontSize: 10, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(formatZmw(total), style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text('$items ${items == 1 ? 'item' : 'items'} priced', style: const TextStyle(color: AppColors.onBrandMuted, fontSize: 9)),
        ],
      ),
    );
  }
}

class _NoBudgetCheck extends StatelessWidget {
  const _NoBudgetCheck();

  @override
  Widget build(BuildContext context) => const IllustratedEmptyState(
        icon: CupertinoIcons.money_dollar_circle,
        title: 'No budget set',
        message: 'Add one when you want a budget check.',
        compact: true,
        accent: AppColors.muted,
      );
}

class _ComparisonIdentity extends StatelessWidget {
  const _ComparisonIdentity({required this.reference});

  final String reference;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'COMPARISON COMPLETE',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                reference,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'Lowest Price Found',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800),
          ),
        ),
      ],
    );
  }
}

class _LowestPriceCard extends StatelessWidget {
  const _LowestPriceCard({
    required this.item,
    required this.store,
    required this.price,
    required this.onTap,
  });

  final String item;
  final String store;
  final String price;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SoftCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const BrandIconTile(icon: CupertinoIcons.cart_fill, size: 36),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    store,
                    style: TextStyle(
                      color: secondaryTextColor(context),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(CupertinoIcons.chevron_right, size: 13, color: AppColors.muted),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopTotals extends StatelessWidget {
  const _ShopTotals({required this.storeTotals, required this.totalLowest});

  final List<StoreTotal> storeTotals;
  final double totalLowest;

  @override
  Widget build(BuildContext context) {
    if (storeTotals.isEmpty) {
      return const IllustratedEmptyState(
        icon: CupertinoIcons.bag_badge_minus,
        title: 'No complete basket found',
        message: 'No store has every item in this comparison available right now.',
        compact: true,
        accent: AppColors.muted,
      );
    }
    return SoftCard(
      child: Column(
        children: [
          for (final (index, store) in storeTotals.indexed) ...[
            if (index > 0) const Divider(height: 25),
            _ShopRow(
              name: store.storeName,
              total: formatZmw(store.total),
              difference: index == 0
                  ? 'Recommended'
                  : formatZmwSigned(store.total - totalLowest),
            ),
          ],
        ],
      ),
    );
  }
}

class _ShopRow extends StatelessWidget {
  const _ShopRow({
    required this.name,
    required this.total,
    required this.difference,
  });

  final String name;
  final String total;
  final String difference;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              total,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 3),
            Text(
              difference,
              style: TextStyle(
                color: difference == 'Recommended'
                    ? AppColors.brand
                    : secondaryTextColor(context),
                fontSize: 10,
                fontWeight: difference == 'Recommended'
                    ? FontWeight.w800
                    : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _BudgetCheck extends StatelessWidget {
  const _BudgetCheck({required this.total, required this.budget});

  final double total;
  final double budget;

  @override
  Widget build(BuildContext context) {
    final under = total <= budget;
    final remaining = budget - total;
    final accent = under ? AppColors.brand : const Color(0xFFE5484D);
    return SoftCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(children: [
            Icon(under ? CupertinoIcons.check_mark_circled : CupertinoIcons.exclamationmark_triangle, size: 17, color: accent),
            const SizedBox(width: 6),
            Expanded(child: Text(under ? 'Within budget' : 'Over budget', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800))),
          ]),
          const SizedBox(height: 8),
          Text(under ? '${formatZmw(remaining)} left' : '${formatZmw(remaining.abs())} over', style: TextStyle(color: accent, fontSize: 16, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text('Budget ${formatZmw(budget)}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: AppColors.muted, fontSize: 9)),
        ],
      ),
    );
  }
}

class _StorePricesSheet extends StatelessWidget {
  const _StorePricesSheet({required this.item, required this.prices});

  final String item;
  final List<StorePrice> prices;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 30),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.nightCard
            : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              item,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'Prices compared across nearby shops',
              style: TextStyle(
                color: secondaryTextColor(context),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 18),
            ...prices.asMap().entries.map((entry) {
              final price = entry.value;
              final lowest = entry.key == 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: SoftCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          price.storeName,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        formatZmw(price.amount),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      if (lowest)
                        const Padding(
                          padding: EdgeInsets.only(left: 7),
                          child: Icon(
                            CupertinoIcons.check_mark_circled_solid,
                            size: 15,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ResultsSkeleton extends StatelessWidget {
  const _ResultsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('skeleton'),
      children: const [
        _ShimmerBlock(height: 36, width: 160),
        SizedBox(height: 18),
        _ShimmerBlock(height: 100),
        SizedBox(height: 24),
        _ShimmerBlock(height: 15, width: 190),
        SizedBox(height: 11),
        _ShimmerBlock(height: 78),
        SizedBox(height: 9),
        _ShimmerBlock(height: 78),
        SizedBox(height: 9),
        _ShimmerBlock(height: 78),
      ],
    );
  }
}

class _ShimmerBlock extends StatelessWidget {
  const _ShimmerBlock({required this.height, this.width});

  final double height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: width ?? double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.soft,
          borderRadius: BorderRadius.circular(18),
        ),
      ),
    );
  }
}
