import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/ui_components.dart';
import '../../data/local/models.dart';
import '../../data/repositories/repositories.dart';

class ShopsScreen extends StatefulWidget {
  const ShopsScreen({required this.repositories, super.key});

  final Repositories repositories;

  @override
  State<ShopsScreen> createState() => _ShopsScreenState();
}

class _ShopsScreenState extends State<ShopsScreen> {
  List<StoreInfo> _stores = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final stores = await widget.repositories.catalog.stores();
      if (!mounted) return;
      setState(() {
        _stores = stores;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    try {
      await widget.repositories.catalog.refreshFromApi();
    } catch (_) {
      // Offline — keep cached stores.
    }
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
                    'Compare prices from stores around Ndola.',
                    style: TextStyle(
                      color: secondaryTextColor(context),
                      fontSize: 13,
                    ),
                  ),
                  SizedBox(height: 22),
                  const _LocationCard(),
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
                  else
                    ..._stores.map(
                      (store) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ShopCard(
                          name: store.name,
                          distance: store.distanceKm != null
                              ? '${_trimDistance(store.distanceKm!)} km away'
                              : null,
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

String _trimDistance(double km) {
  final text = km.toStringAsFixed(1);
  return text.endsWith('.0') ? text.substring(0, text.length - 2) : text;
}

class _LocationCard extends StatelessWidget {
  const _LocationCard();

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
                  'Ndola, Copperbelt',
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
    this.distance,
  });

  final String name;
  final String? distance;
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
                if (distance != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    distance!,
                    style: TextStyle(
                      color: secondaryTextColor(context),
                      fontSize: 10,
                    ),
                  ),
                ],
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
