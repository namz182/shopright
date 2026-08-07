import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/ui_components.dart';

const _grocerySuggestions = <String>[
  'Breakfast Meal 25kg',
  'Roller Meal 10kg',
  'Cooking Oil 2.5L',
  'Vegetable Oil 1L',
  'White Sugar 2kg',
  'Brown Sugar 1kg',
  'Brown Bread',
  'White Bread Loaf',
  'Fresh Milk 1L',
  'Powdered Milk 500g',
  'Salt 1kg',
  'Chicken Stock Cubes',
  'Tomatoes 1kg',
  'Onions 1kg',
  'Potatoes 5kg',
  'Carrots 1kg',
  'Rice 5kg',
  'Spaghetti Pasta',
  'Mango Juice 2L',
  'Toilet Paper 12 Pack',
];

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
    required this.onOpenResults,
    super.key,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;
  final VoidCallback onOpenResults;

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
                _BudgetCard(budget: _budget, onEdit: _editBudget),
                const SizedBox(height: 20),
                _SearchBar(
                  onAdd: _quickAdd,
                  remove: _removeItem,
                  contains: (name) => _items.any((item) => item.name == name),
                ),
                const SizedBox(height: 23),
                SectionLabel(
                  'Your Shopping List (${_items.length} Items)',
                  trailing: TextButton(
                    onPressed: _items.isEmpty
                        ? null
                        : () => setState(_items.clear),
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
                if (_items.isEmpty)
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
                  onPressed: widget.onOpenResults,
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
  }

  void _removeItem(String name) {
    setState(() => _items.removeWhere((item) => item.name == name));
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
    required this.onAdd,
    required this.remove,
    required this.contains,
  });

  final ValueChanged<String> onAdd;
  final ValueChanged<String> remove;
  final bool Function(String) contains;

  void _openSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) =>
          _SearchSheet(onAdd: onAdd, remove: remove, contains: contains),
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
    required this.onAdd,
    required this.remove,
    required this.contains,
  });

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

  List<String> get _suggestions {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return _grocerySuggestions.take(12).toList();
    }
    return _grocerySuggestions
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
                    children: _suggestions.map((name) {
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
                if (_query.trim().isNotEmpty && _suggestions.isEmpty) ...[
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
