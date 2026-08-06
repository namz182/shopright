import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_top_bar.dart';
import '../../core/widgets/ui_components.dart';
import '../history/history_screen.dart';
import '../results/results_screen.dart';
import '../settings/settings_screen.dart';
import '../shops/shops_screen.dart';

class GroceryItem {
  GroceryItem({
    required this.name,
    required this.category,
    required this.icon,
    required this.quantity,
  });

  final String name;
  final String category;
  final IconData icon;
  int quantity;
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.isDarkMode,
    required this.onThemeChanged,
    super.key,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _budget = 'ZMW 1,200.00';
  final _items = <GroceryItem>[
    GroceryItem(
      name: 'Breakfast Meal 25kg',
      category: 'Essential Staples',
      icon: CupertinoIcons.circle_grid_hex_fill,
      quantity: 2,
    ),
    GroceryItem(
      name: 'Cooking Oil 2.5L',
      category: 'Cooking Goods',
      icon: CupertinoIcons.drop_fill,
      quantity: 1,
    ),
    GroceryItem(
      name: 'White Sugar 2kg',
      category: 'Pantry Items',
      icon: CupertinoIcons.cube_box_fill,
      quantity: 1,
    ),
  ];

  void _showResults() {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => ResultsScreen(
          showLoading: true,
          isDarkMode: widget.isDarkMode,
          onThemeChanged: widget.onThemeChanged,
        ),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _selectTab(AppTab tab) {
    final Widget? screen = switch (tab) {
      AppTab.home => null,
      AppTab.history => HistoryScreen(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
      AppTab.shops => ShopsScreen(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
      AppTab.settings => SettingsScreen(
        isDarkMode: widget.isDarkMode,
        onThemeChanged: widget.onThemeChanged,
      ),
    };
    if (screen != null) {
      Navigator.of(context).push(_fadeRoute(screen));
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
                      children: [
                        _BudgetCard(budget: _budget, onEdit: _editBudget),
                        const SizedBox(height: 20),
                        const _SearchBar(),
                        const SizedBox(height: 20),
                        _QuickAdd(onAdd: _quickAdd),
                        const SizedBox(height: 23),
                        SectionLabel(
                          'Your Shopping List (${_items.length} Items)',
                          trailing: TextButton(
                            onPressed: _items.isEmpty
                                ? null
                                : () => setState(_items.clear),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.slate,
                              visualDensity: VisualDensity.compact,
                            ),
                            child: const Text(
                              'Clear All',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (_items.isEmpty)
                          const SoftCard(
                            child: Text(
                              'Your list is empty. Add an essential above to get started.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.slate,
                                fontSize: 13,
                              ),
                            ),
                          )
                        else
                          ..._items.map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ShoppingItemCard(
                                item: item,
                                onMinus: () => _changeQuantity(item, -1),
                                onPlus: () => _changeQuantity(item, 1),
                              ),
                            ),
                          ),
                        const SizedBox(height: 8),
                        PrimaryButton(
                          label: 'Compare All Shops & Lowest Prices',
                          icon: CupertinoIcons.search,
                          onPressed: _showResults,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const AppStickyTopBar(),
          AppBottomNav(selected: AppTab.home, onSelected: _selectTab),
        ],
      ),
    );
  }

  void _changeQuantity(GroceryItem item, int amount) {
    setState(() {
      item.quantity += amount;
      if (item.quantity <= 0) _items.remove(item);
    });
  }

  Future<void> _refresh() async {
    await Future<void>.delayed(const Duration(milliseconds: 850));
    if (mounted) setState(() {});
  }

  Future<void> _editBudget() async {
    final controller = TextEditingController(
      text: _budget.replaceAll('ZMW ', '').replaceAll(',', ''),
    );
    final value = await showCupertinoDialog<String>(
      context: context,
      builder: (dialogContext) => CupertinoAlertDialog(
        title: const Text('Edit target budget'),
        content: Padding(
          padding: const EdgeInsets.only(top: 10),
          child: CupertinoTextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            prefix: const Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text('ZMW '),
            ),
          ),
        ),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () => Navigator.pop(dialogContext, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (value != null && value.trim().isNotEmpty) {
      setState(() => _budget = 'ZMW ${value.trim()}');
    }
  }

  void _quickAdd(String name) {
    final existing = _items.where((item) => item.name == name).firstOrNull;
    if (existing != null) {
      setState(() => existing.quantity++);
      return;
    }
    setState(() {
      _items.add(
        GroceryItem(
          name: name,
          category: 'Essential Staples',
          icon: CupertinoIcons.bag_fill,
          quantity: 1,
        ),
      );
    });
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.budget, required this.onEdit});

  final String budget;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.ink,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2B030712),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Budget',
                      style: TextStyle(color: AppColors.muted, fontSize: 11),
                    ),
                    SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            budget,
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 24,
                              letterSpacing: -.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              FilledButton(
                onPressed: onEdit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.white,
                  foregroundColor: AppColors.ink,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 9,
                  ),
                  minimumSize: Size.zero,
                  shape: const StadiumBorder(),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

PageRoute<void> _fadeRoute(Widget screen) => PageRouteBuilder<void>(
  pageBuilder: (_, _, _) => screen,
  transitionsBuilder: (_, animation, _, child) =>
      FadeTransition(opacity: animation, child: child),
);

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(CupertinoIcons.search, size: 19),
              hintText: 'Search mealie meal, sugar...',
            ),
          ),
        ),
        const SizedBox(width: 9),
        IconButton.filled(
          onPressed: () {},
          icon: const Icon(CupertinoIcons.slider_horizontal_3, size: 19),
          style: IconButton.styleFrom(
            backgroundColor: AppColors.ink,
            foregroundColor: AppColors.white,
            fixedSize: const Size(50, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuickAdd extends StatelessWidget {
  const _QuickAdd({required this.onAdd});

  final ValueChanged<String> onAdd;

  @override
  Widget build(BuildContext context) {
    const names = [
      'Breakfast Meal 25kg',
      'Cooking Oil 2.5L',
      'White Sugar 2kg',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUICK ADD ESSENTIALS',
          style: TextStyle(
            color: AppColors.muted,
            fontSize: 10,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 9),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: names.map((name) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ActionChip(
                  onPressed: () => onAdd(name),
                  avatar: const Icon(CupertinoIcons.add, size: 13),
                  label: Text(name),
                  backgroundColor: AppColors.soft,
                  side: const BorderSide(color: AppColors.border),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  labelStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 5,
                    vertical: 6,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _ShoppingItemCard extends StatelessWidget {
  const _ShoppingItemCard({
    required this.item,
    required this.onMinus,
    required this.onPlus,
  });

  final GroceryItem item;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(CupertinoIcons.bag_fill, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.category}  •  Qty: ${item.quantity}',
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _QuantityButton(icon: CupertinoIcons.minus, onTap: onMinus),
          SizedBox(
            width: 28,
            child: Text(
              '${item.quantity}',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ),
          _QuantityButton(icon: CupertinoIcons.add, onTap: onPlus, dark: true),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({
    required this.icon,
    required this.onTap,
    this.dark = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 27,
        height: 27,
        decoration: BoxDecoration(
          color: dark ? AppColors.ink : AppColors.border,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 13,
          color: dark ? AppColors.white : AppColors.ink,
        ),
      ),
    );
  }
}
