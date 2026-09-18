import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/money.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/ui_components.dart';
import '../../data/local/models.dart';
import '../../data/repositories/repositories.dart';
import '../../data/repositories/data_sources.dart';
import '../results/comparison_result.dart';
import '../results/results_screen.dart';

IconData iconForCategory(String category) {
  return switch (category) {
    'Essential Staples' => CupertinoIcons.circle_grid_hex_fill,
    'Cooking Goods' => CupertinoIcons.drop_fill,
    'Pantry Items' => CupertinoIcons.cube_box_fill,
    'Fresh Produce' => CupertinoIcons.sun_max_fill,
    'Dairy' => CupertinoIcons.drop_fill,
    'Bakery' => CupertinoIcons.cube_box_fill,
    _ => CupertinoIcons.bag_fill,
  };
}

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
    required this.repositories,
    required this.isDarkMode,
    required this.onThemeChanged,
    required this.onTabSelected,
    super.key,
  });

  final Repositories repositories;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<AppTab> onTabSelected;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Repositories get _repos => widget.repositories;

  double? _budget;
  UserLocation _location = const UserLocation();
  bool _loading = true;
  List<String> _catalogNames = const [];
  Map<String, GroceryProduct> _catalogByName = const {};
  String? _catalogError;
  final _items = <GroceryItem>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final budget = await _repos.settings.budget();
      final savedItems = await _repos.settings.shoppingItems();
      final location = await _repos.settings.location();
      final products = await _repos.catalog.productsForLocation(
        provinceId: location.provinceId,
        districtId: location.districtId,
      );
      if (!mounted) return;
      setState(() {
        _budget = budget;
        _location = location;
        _items
          ..clear()
          ..addAll(
            savedItems.map(
              (item) => GroceryItem(
                name: item.name,
                category: item.category,
                icon: iconForCategory(item.category),
                quantity: item.quantity,
              ),
            ),
          );
        _catalogNames = products.map((p) => p.name).toList();
        _catalogByName = {for (final p in products) p.name: p};
        _catalogError = null;
        _loading = false;
      });
    } catch (error) {
      debugPrint('[ShopRight Home] product load failed: $error');
      if (mounted) setState(() { _loading = false; _catalogError = 'Unable to load products. Check that the backend is running and reachable.'; });
    }
  }

  void _persistItems() {
    unawaited(
      _repos.settings.saveShoppingItems(
        _items
            .map(
              (item) => ShoppingItem(
                name: item.name,
                category: item.category,
                quantity: item.quantity,
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 86, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _BudgetCard(
                  budget: formatZmw(_budget ?? 0),
                  onEdit: _editBudget,
                ),
                const SizedBox(height: 20),
                _SearchBar(
                  suggestions: _catalogNames,
                  onAdd: _quickAdd,
                  remove: _removeItem,
                  contains: (name) => _items.any((item) => item.name == name),
                ),
                if (_catalogError != null) ...[
                  const SizedBox(height: 10),
                  SoftCard(
                    child: Text(
                      _catalogError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: secondaryTextColor(context), fontSize: 12),
                    ),
                  ),
                ],
                const SizedBox(height: 23),
                SectionLabel(
                  'Your Shopping List (${_items.length} Items)',
                  trailing: TextButton(
                    onPressed: _items.isEmpty
                        ? null
                        : () {
                            setState(_items.clear);
                            _persistItems();
                          },
                    style: TextButton.styleFrom(
                      foregroundColor: secondaryTextColor(context),
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
              ],
            ),
          ),
        ),
        Expanded(
          child: RefreshIndicator.adaptive(
            onRefresh: _refresh,
            child: ListView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(22, 10, 22, 112),
              children: [
                if (_loading)
                  SoftCard(
                    child: Text(
                      'Loading your list...',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: secondaryTextColor(context),
                        fontSize: 13,
                      ),
                    ),
                  )
                else if (_items.isEmpty)
                  SoftCard(
                    child: Text(
                      'Your list is empty. Add an essential above to get started.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: secondaryTextColor(context),
                        fontSize: 13,
                      ),
                    ),
                  )
                else
                  ..._items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Dismissible(
                        key: ValueKey(item.name),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) => _removeItem(item.name),
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
                        child: _ShoppingItemCard(
                          item: item,
                          onMinus: () => _changeQuantity(item, -1),
                          onPlus: () => _changeQuantity(item, 1),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 8),
                PrimaryButton(
                  label: 'Compare',
                  icon: CupertinoIcons.search,
                  onPressed: _loading ? () {} : () => _compare(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _changeQuantity(GroceryItem item, int amount) {
    setState(() {
      item.quantity += amount;
      if (item.quantity <= 0) _items.remove(item);
    });
    _persistItems();
  }

  void _removeItem(String name) {
    setState(() => _items.removeWhere((item) => item.name == name));
    _persistItems();
  }

  Future<void> _refresh() async {
    await _load();
  }

  Future<void> _editBudget() async {
    final controller = TextEditingController(
      text: formatZmw(_budget ?? 0).replaceAll('ZMW ', '').replaceAll(',', ''),
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
      final parsed = parseMoney(value);
      if (parsed != null) {
        setState(() => _budget = parsed);
        unawaited(_repos.settings.setBudget(parsed));
      }
    }
  }

  void _quickAdd(String name) {
    final existing = _items.where((item) => item.name == name).firstOrNull;
    if (existing != null) {
      setState(() => existing.quantity++);
      _persistItems();
      return;
    }
    final category = _catalogByName[name]?.category ?? 'Essential Staples';
    setState(() {
      _items.add(
        GroceryItem(
          name: name,
          category: category,
          icon: iconForCategory(category),
          quantity: 1,
        ),
      );
    });
    _persistItems();
  }

  Future<void> _compare() async {
    final result = ComparisonResult.compute(
      basket: _items
          .map(
            (item) => ShoppingItem(
              name: item.name,
              category: item.category,
              quantity: item.quantity,
            ),
          )
          .toList(),
      catalog: await _repos.catalog.productsForLocation(
        provinceId: _location.provinceId,
        districtId: _location.districtId,
      ),
      stores: await _repos.catalog.storesForLocation(
        provinceId: _location.provinceId,
        districtId: _location.districtId,
      ),
      budget: _budget ?? 0,
    );
    await _repos.comparisons.insert(result.toRecord());
    if (!mounted) return;

    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, _, _) => ResultsScreen(
          result: result,
          showLoading: true,
          isDarkMode: widget.isDarkMode,
          onThemeChanged: widget.onThemeChanged,
          onTabSelected: widget.onTabSelected,
        ),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({required this.budget, required this.onEdit});

  final String budget;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: dark
              ? const [Color(0xFF527B4A), Color(0xFF3F6239)]
              : const [AppColors.brand, Color(0xFF7AA86E)],
        ),
        borderRadius: BorderRadius.circular(26),
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
                      style: TextStyle(
                        color: AppColors.onBrandMuted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
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

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.suggestions,
    required this.onAdd,
    required this.remove,
    required this.contains,
  });

  final List<String> suggestions;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> remove;
  final bool Function(String) contains;

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _SearchSheet(
        suggestions: suggestions,
        onAdd: onAdd,
        remove: remove,
        contains: contains,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      readOnly: true,
      onTap: () => _openSheet(context),
      decoration: const InputDecoration(
        prefixIcon: Icon(CupertinoIcons.search, size: 19),
        hintText: 'Search mealie meal, sugar...',
      ),
    );
  }
}

class _SearchSheet extends StatefulWidget {
  const _SearchSheet({
    required this.suggestions,
    required this.onAdd,
    required this.remove,
    required this.contains,
  });

  final List<String> suggestions;
  final ValueChanged<String> onAdd;
  final ValueChanged<String> remove;
  final bool Function(String) contains;

  @override
  State<_SearchSheet> createState() => _SearchSheetState();
}

class _SearchSheetState extends State<_SearchSheet> {
  final _controller = TextEditingController();
  final _added = <String>{};
  String _query = '';

  List<String> get _results {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return widget.suggestions.take(12).toList();
    }
    return widget.suggestions
        .where((s) => s.toLowerCase().contains(q))
        .take(12)
        .toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle(String name) {
    final selected = _added.contains(name) || widget.contains(name);
    if (selected) {
      widget.remove(name);
    } else {
      widget.onAdd(name);
    }
    setState(() {
      if (selected) {
        _added.remove(name);
      } else {
        _added.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 12, 6),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Add Items',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(CupertinoIcons.search, size: 19),
                hintText: 'Search mealie meal, sugar...',
              ),
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(22, 0, 22, 20),
              children: [
                SoftCard(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Column(
                    children: _results.map((name) {
                      final selected =
                          _added.contains(name) || widget.contains(name);
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 0,
                        ),
                        leading: Icon(
                          selected
                              ? CupertinoIcons.check_mark_circled_solid
                              : CupertinoIcons.add_circled,
                          size: 18,
                          color: selected
                              ? AppColors.brand
                              : secondaryTextColor(context),
                        ),
                        title: Text(
                          name,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onTap: () => _toggle(name),
                      );
                    }).toList(),
                  ),
                ),
                if (_query.trim().isNotEmpty && _results.isEmpty) ...[
                  const SizedBox(height: 10),
                  SoftCard(
                    child: Text(
                      'No matches for "${_query.trim()}".',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: secondaryTextColor(context),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
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
          BrandIconTile(icon: item.icon),
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
    final themeDark = Theme.of(context).brightness == Brightness.dark;
    final background = dark
        ? (themeDark ? AppColors.brand : AppColors.nightCard)
        : (themeDark ? AppColors.nightCard : AppColors.border);
    final foreground = dark
        ? AppColors.white
        : (themeDark ? AppColors.white : AppColors.ink);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 27,
        height: 27,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(icon, size: 13, color: foreground),
      ),
    );
  }
}
