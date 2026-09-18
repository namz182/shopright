import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/ui_components.dart';
import '../../data/local/models.dart';
import '../../data/remote/shop_right_api.dart';
import '../../data/repositories/repositories.dart';
import '../../data/repositories/data_sources.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    required this.repositories,
    required this.isDarkMode,
    required this.onThemeChanged,
    this.onLocationChanged,
    super.key,
  });

  final bool isDarkMode;
  final Repositories repositories;
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<UserLocation>? onLocationChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const _appVersion = '1.0.0';

  late bool _isDarkMode = widget.isDarkMode;
  UserLocation _location = const UserLocation();
  bool _locationLoading = false;

  @override
  void initState() {
    super.initState();
    widget.repositories.settings.location().then((value) { if (mounted) setState(() => _location = value); });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: _refreshSettings,
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
                  Text(
                    'Personalize your Shop Right experience.',
                    style: TextStyle(
                      color: secondaryTextColor(context),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SectionLabel('Appearance'),
                  const SizedBox(height: 11),
                  SoftCard(
                    padding: EdgeInsets.zero,
                    child: SwitchListTile.adaptive(
                      value: _isDarkMode,
                      onChanged: (value) {
                        setState(() => _isDarkMode = value);
                        widget.onThemeChanged(value);
                      },
                      activeTrackColor: AppColors.brand,
                      secondary: const Icon(CupertinoIcons.moon_fill),
                      title: const Text(
                        'Dark mode',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      subtitle: Text(
                        _isDarkMode
                            ? 'Using the darker appearance'
                            : 'Using the light appearance',
                        style: TextStyle(
                          color: secondaryTextColor(context),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const SectionLabel('Preferences'),
                  const SizedBox(height: 11),
                  _SettingsGroup(
                    children: [
                      _SettingsAction(
                        icon: CupertinoIcons.location_solid,
                        label: 'Location',
                        value: _location.label,
                        onTap: _locationLoading ? null : _chooseLocation,
                        loading: _locationLoading,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const SectionLabel('Support'),
                  const SizedBox(height: 11),
                  _SettingsGroup(
                    children: [
                      _SettingsAction(
                        icon: CupertinoIcons.question_circle_fill,
                        label: 'Help & feedback',
                        onTap: () => _showInfoSheet(context, _SettingsInfoType.help),
                      ),
                      _SettingsAction(
                        icon: CupertinoIcons.doc_text_fill,
                        label: 'Privacy policy',
                        onTap: () => _showInfoSheet(context, _SettingsInfoType.privacy),
                      ),
                      _SettingsAction(
                        icon: CupertinoIcons.info_circle_fill,
                        label: 'About Shop Right',
                        value: 'Version $_appVersion',
                        onTap: () => _showInfoSheet(context, _SettingsInfoType.about),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoSheet(BuildContext context, _SettingsInfoType type) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SettingsInfoSheet(type: type, version: _appVersion),
    );
  }

  Future<void> _chooseLocation() async {
    if (_locationLoading) return;
    setState(() => _locationLoading = true);
    final api = ShopRightApi();
    try {
      final provinces = await api.fetchProvinces();
      if (!mounted) return;
      ProvinceInfo? province = provinces.where((item) => item.id == _location.provinceId).firstOrNull;
      DistrictInfo? district;
      List<DistrictInfo> districts = province == null ? const [] : await api.fetchDistricts(province.id);
      district = districts.where((item) => item.id == _location.districtId).firstOrNull;
      final selected = await showDialog<UserLocation>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
          title: const Text('Comparison location'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<ProvinceInfo>(value: province, isExpanded: true, decoration: const InputDecoration(labelText: 'Province'), items: provinces.map((item) => DropdownMenuItem(value: item, child: Text(item.name))).toList(), onChanged: (value) async { if (value == null) return; final next = await api.fetchDistricts(value.id); setDialogState(() { province = value; districts = next; district = null; }); }),
            const SizedBox(height: 12),
            DropdownButtonFormField<DistrictInfo>(value: district, isExpanded: true, decoration: const InputDecoration(labelText: 'District'), items: districts.map((item) => DropdownMenuItem(value: item, child: Text(item.name))).toList(), onChanged: (value) => setDialogState(() => district = value)),
          ]),
          actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')), FilledButton(onPressed: province == null || district == null ? null : () => Navigator.pop(dialogContext, UserLocation(provinceId: province!.id, provinceName: province!.name, districtId: district!.id, districtName: district!.name)), child: const Text('Save'))],
        )),
      );
      if (selected != null) {
        await widget.repositories.settings.setLocation(selected);
        if (mounted) {
          setState(() => _location = selected);
          widget.onLocationChanged?.call(selected);
        }
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to connect')),
        );
      }
    } finally {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  Future<void> _refreshSettings() async {
    final location = await widget.repositories.settings.location();
    if (mounted) setState(() => _location = location);
  }
}

enum _SettingsInfoType { help, privacy, about }

class _SettingsInfoSheet extends StatelessWidget {
  const _SettingsInfoSheet({required this.type, required this.version});

  final _SettingsInfoType type;
  final String version;

  @override
  Widget build(BuildContext context) {
    final title = switch (type) {
      _SettingsInfoType.help => 'Help & feedback',
      _SettingsInfoType.privacy => 'Privacy policy',
      _SettingsInfoType.about => 'About Shop Right',
    };
    final icon = switch (type) {
      _SettingsInfoType.help => CupertinoIcons.question_circle_fill,
      _SettingsInfoType.privacy => CupertinoIcons.lock_shield_fill,
      _SettingsInfoType.about => CupertinoIcons.info_circle_fill,
    };

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 28),
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(icon, color: AppColors.brand, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(CupertinoIcons.xmark, size: 16),
                  style: IconButton.styleFrom(backgroundColor: AppColors.soft),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (type == _SettingsInfoType.help) ...[
              const Text(
                'Compare everyday prices in a few simple steps.',
                style: TextStyle(fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 16),
              const _InfoPoint(
                icon: CupertinoIcons.cart_fill,
                title: 'Build your list',
                message: 'Search for products and add what you plan to buy.',
              ),
              const _InfoPoint(
                icon: CupertinoIcons.location_solid,
                title: 'Choose your area',
                message: 'Set a province and district so stores match your location.',
              ),
              const _InfoPoint(
                icon: CupertinoIcons.chart_bar_fill,
                title: 'Compare prices',
                message: 'Tap Compare to see the lowest item prices and store totals.',
              ),
              const SizedBox(height: 10),
              SoftCard(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.nightCard
                    : AppColors.soft,
                child: const Text(
                  'Tip: pull down on any page to refresh the latest products, stores, or saved history.',
                  style: TextStyle(fontSize: 11, height: 1.45),
                ),
              ),
            ] else if (type == _SettingsInfoType.privacy) ...[
              const Text(
                'Shop Right uses your selected province and district to show stores and prices for that area.',
                style: TextStyle(fontSize: 13, height: 1.45),
              ),
              const SizedBox(height: 14),
              const _InfoPoint(
                icon: CupertinoIcons.location,
                title: 'No precise GPS',
                message: 'The app uses the area you choose in Settings rather than tracking your device location.',
              ),
              const _InfoPoint(
                icon: CupertinoIcons.lock_fill,
                title: 'Your saved data',
                message: 'Shopping lists, settings, and comparison history stay on this device.',
              ),
              const _InfoPoint(
                icon: CupertinoIcons.cloud_fill,
                title: 'Catalog requests',
                message: 'Products, stores, and prices are requested from the Shop Right backend when needed.',
              ),
            ] else ...[
              Center(
                child: Column(
                  children: [
                    const BrandIconTile(icon: CupertinoIcons.cart_fill, size: 58),
                    const SizedBox(height: 12),
                    const Text(
                      'Shop Right',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version $version',
                      style: const TextStyle(color: AppColors.muted, fontSize: 11, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              const SoftCard(
                child: Text(
                  'Shop Right helps you plan a smarter grocery trip by comparing product prices across stores in your selected district.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, height: 1.5),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoPoint extends StatelessWidget {
  const _InfoPoint({required this.icon, required this.title, required this.message});

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.brand, size: 19),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(message, style: TextStyle(color: secondaryTextColor(context), fontSize: 11, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: children),
    );
  }
}

class _SettingsAction extends StatelessWidget {
  const _SettingsAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
    this.loading = false,
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (loading)
              const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            else if (value != null)
              Text(
                value!,
                style: TextStyle(
                  color: secondaryTextColor(context),
                  fontSize: 11,
                ),
              ),
            const SizedBox(width: 7),
            const Icon(
              CupertinoIcons.chevron_right,
              color: AppColors.muted,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}
