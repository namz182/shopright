import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_top_bar.dart';
import '../../core/widgets/ui_components.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onTabSelected,
    this.showLoading = false,
    super.key,
  });

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
                              : _ResultsBody(onSelectItem: _showStorePrices),
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

  void _showStorePrices(String item) {
    final prices = switch (item) {
      'Breakfast Meal 25kg (x2)' => const [
        ('Shoprite Ndola', 'ZMW 670.00'),
        ('Local Market (Chifubu)', 'ZMW 690.00'),
        ('Pick n Pay Copperbelt', 'ZMW 720.00'),
        ('Melissa Supermarket', 'ZMW 710.00'),
      ],
      'Cooking Oil 2.5L' => const [
        ('Local Market (Chifubu)', 'ZMW 135.00'),
        ('Shoprite Ndola', 'ZMW 142.00'),
        ('Pick n Pay Copperbelt', 'ZMW 149.00'),
        ('Melissa Supermarket', 'ZMW 145.00'),
      ],
      _ => const [
        ('Pick n Pay Copperbelt', 'ZMW 55.00'),
        ('Shoprite Ndola', 'ZMW 59.00'),
        ('Local Market (Chifubu)', 'ZMW 60.00'),
        ('Melissa Supermarket', 'ZMW 63.00'),
      ],
    };
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _StorePricesSheet(item: item, prices: prices),
    );
  }

  Future<void> _refresh() async {
    setState(() => _loading = true);
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (mounted) setState(() => _loading = false);
  }
}

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
          const Expanded(child: AppTopBar(trailing: SizedBox.shrink())),
        ],
      ),
    );
  }
}

class _ResultsBody extends StatelessWidget {
  const _ResultsBody({required this.onSelectItem});

  final ValueChanged<String> onSelectItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('results'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ComparisonIdentity(),
        const SizedBox(height: 18),
        const _LowestTotalCard(),
        const SizedBox(height: 24),
        SectionLabel(
          'Lowest Price Per Item',
          trailing: const Text(
            'Tap an item for store prices',
            style: TextStyle(color: AppColors.muted, fontSize: 10),
          ),
        ),
        const SizedBox(height: 11),
        _LowestPriceCard(
          item: 'Breakfast Meal 25kg (x2)',
          store: 'Shoprite Ndola',
          price: 'ZMW 670.00',
          onTap: onSelectItem,
        ),
        const SizedBox(height: 9),
        _LowestPriceCard(
          item: 'Cooking Oil 2.5L',
          store: 'Local Market (Chifubu)',
          price: 'ZMW 135.00',
          onTap: onSelectItem,
        ),
        const SizedBox(height: 9),
        _LowestPriceCard(
          item: 'White Sugar 2kg',
          store: 'Pick n Pay',
          price: 'ZMW 55.00',
          onTap: onSelectItem,
        ),
        const SizedBox(height: 24),
        const SectionLabel('Total Basket By Shop'),
        const SizedBox(height: 11),
        const _ShopTotals(),
      ],
    );
  }
}

class _ComparisonIdentity extends StatelessWidget {
  const _ComparisonIdentity();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'COMPARISON COMPLETE',
                style: TextStyle(
                  color: AppColors.muted,
                  fontSize: 10,
                  letterSpacing: 1.1,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'CMP-904-ZM21',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
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

class _LowestTotalCard extends StatelessWidget {
  const _LowestTotalCard();

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
            CupertinoIcons.check_mark_circled_solid,
            color: AppColors.white,
            size: 26,
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total at lowest prices',
                  style: TextStyle(
                    color: AppColors.onBrandMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'ZMW 860.00',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
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
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(item),
      child: SoftCard(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
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
                const Icon(
                  CupertinoIcons.chevron_up_chevron_down,
                  size: 13,
                  color: AppColors.muted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopTotals extends StatelessWidget {
  const _ShopTotals();

  @override
  Widget build(BuildContext context) {
    return const SoftCard(
      child: Column(
        children: [
          _ShopRow(
            name: 'Shoprite Ndola',
            distance: '2.1 km away',
            total: 'ZMW 865.00',
            difference: 'Recommended',
          ),
          Divider(height: 25),
          _ShopRow(
            name: 'Local Market (Chifubu)',
            distance: '1.4 km away',
            total: 'ZMW 880.00',
            difference: '+ZMW 15.00',
          ),
          Divider(height: 25),
          _ShopRow(
            name: 'Pick n Pay Copperbelt',
            distance: '3.8 km away',
            total: 'ZMW 920.00',
            difference: '+ZMW 55.00',
          ),
        ],
      ),
    );
  }
}

class _ShopRow extends StatelessWidget {
  const _ShopRow({
    required this.name,
    required this.distance,
    required this.total,
    required this.difference,
  });

  final String name;
  final String distance;
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
              const SizedBox(height: 3),
              Text(
                distance,
                style: const TextStyle(color: AppColors.muted, fontSize: 10),
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
                color: secondaryTextColor(context),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StorePricesSheet extends StatelessWidget {
  const _StorePricesSheet({required this.item, required this.prices});

  final String item;
  final List<(String, String)> prices;

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
              final (store, price) = entry.value;
              final lowest = entry.key == 0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: SoftCard(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          store,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Text(
                        price,
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
