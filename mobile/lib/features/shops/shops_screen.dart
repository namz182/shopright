import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/ui_components.dart';

class ShopsScreen extends StatelessWidget {
  const ShopsScreen({super.key});

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
                  _LocationCard(),
                  SizedBox(height: 24),
                  SectionLabel('Available Stores'),
                  SizedBox(height: 11),
                  _ShopCard(
                    name: 'Shoprite Ndola',
                    distance: '2.1 km away',
                    detail: 'Fresh prices checked today',
                  ),
                  SizedBox(height: 10),
                  _ShopCard(
                    name: 'Local Market (Chifubu)',
                    distance: '1.4 km away',
                    detail: 'Fresh prices checked today',
                  ),
                  SizedBox(height: 10),
                  _ShopCard(
                    name: 'Pick n Pay Copperbelt',
                    distance: '3.8 km away',
                    detail: 'Fresh prices checked yesterday',
                  ),
                  SizedBox(height: 10),
                  _ShopCard(
                    name: 'Melissa Supermarket',
                    distance: '4.5 km away',
                    detail: 'Prices coming soon',
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
    required this.distance,
    required this.detail,
  });

  final String name;
  final String distance;
  final String detail;

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
                const SizedBox(height: 3),
                Text(
                  distance,
                  style: TextStyle(
                    color: secondaryTextColor(context),
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  detail,
                  style: const TextStyle(color: AppColors.muted, fontSize: 10),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
