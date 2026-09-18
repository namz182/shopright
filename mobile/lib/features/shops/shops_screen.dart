import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/ui_components.dart';
import '../../data/local/models.dart';
import '../../data/repositories/repositories.dart';
import '../../data/repositories/data_sources.dart';

class ShopsScreen extends StatefulWidget {
  const ShopsScreen({required this.repositories, super.key});

  final Repositories repositories;

  @override
  State<ShopsScreen> createState() => _ShopsScreenState();
}

class _ShopsScreenState extends State<ShopsScreen> {
  List<StoreInfo> _stores = const [];
  bool _loading = true;
  String? _error;
  UserLocation _location = const UserLocation();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final location = await widget.repositories.settings.location();
      final stores = await widget.repositories.catalog.storesForLocation(
        provinceId: location.provinceId,
        districtId: location.districtId,
      );
      if (!mounted) return;
      setState(() {
        _stores = stores;
        _location = location;
        _error = null;
        _loading = false;
      });
    } catch (error) {
      debugPrint('[ShopRight Shops] store load failed: $error');
      if (mounted) setState(() { _loading = false; _error = 'Unable to load stores. Check that the backend is running and reachable.'; });
    }
  }

  Future<void> _refresh() async {
    await _load();
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
                    'Nearby Shops',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 7),
                  Text(
                    'Compare prices from stores in your selected location.',
                    style: TextStyle(
                      color: secondaryTextColor(context),
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 22),
                  _LocationCard(location: _location),
                  SizedBox(height: 24),
                  SectionLabel('Available Stores'),
                  SizedBox(height: 11),
                  if (_loading)
                    SoftCard(
                      child: Text(
                        'Loading stores...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: secondaryTextColor(context),
                          fontSize: 13,
                        ),
                      ),
                    )
                  else if (_error != null)
                    SoftCard(child: Text(_error!, textAlign: TextAlign.center, style: TextStyle(color: secondaryTextColor(context), fontSize: 12)))
                  else if (_stores.isEmpty)
                    SoftCard(
                      child: Text(
                        _location.isSelected
                            ? 'No stores are available in this district yet.'
                            : 'Choose a province and district in Settings to see local stores.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: secondaryTextColor(context), fontSize: 13),
                      ),
                    )
                  else
                    ..._stores.map(
                      (store) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ShopCard(
                          name: store.name,
                          detail: store.location,
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

class _LocationCard extends StatelessWidget {
  const _LocationCard({required this.location});

  final UserLocation location;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        children: [
          Icon(CupertinoIcons.location_solid, size: 20),
          SizedBox(width: 11),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  location.label,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 3),
                Text(
                  'Your current comparison area',
                  style: TextStyle(color: AppColors.muted, fontSize: 10),
                ),
              ],
            ),
          ),
          Icon(
            CupertinoIcons.chevron_down,
            size: 15,
            color: secondaryTextColor(context),
          ),
        ],
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.name,
    required this.detail,
  });

  final String name;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      child: Row(
        children: [
          const BrandIconTile(icon: CupertinoIcons.bag_fill),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (detail != null && detail!.trim().isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    detail!,
                    style: const TextStyle(color: AppColors.muted, fontSize: 10),
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
