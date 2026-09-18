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
  late bool _isDarkMode = widget.isDarkMode;
  UserLocation _location = const UserLocation();
  bool _locationLoading = false;

  @override
  void initState() {
    super.initState();
    widget.repositories.settings.location().then((value) { if (mounted) setState(() => _location = value); });
  }

  void _showMessage(BuildContext context, String title) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: Text(title),
        content: const Text('This action is part of the static app prototype.'),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator.adaptive(
      onRefresh: _refreshSettings,
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
                  const Text(
                    'Settings',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 7),
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
                      _SettingsAction(
                        icon: CupertinoIcons.bell_fill,
                        label: 'Price alerts',
                        value: 'On',
                        onTap: () => _showMessage(context, 'Price alerts'),
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
                        onTap: () => _showMessage(context, 'Help & feedback'),
                      ),
                      _SettingsAction(
                        icon: CupertinoIcons.doc_text_fill,
                        label: 'Privacy policy',
                        onTap: () => _showMessage(context, 'Privacy policy'),
                      ),
                      _SettingsAction(
                        icon: CupertinoIcons.info_circle_fill,
                        label: 'About Shop Right',
                        value: 'Version 1.0.0',
                        onTap: () => _showMessage(context, 'About Shop Right'),
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
      if (mounted) _showMessage(context, 'Location unavailable');
    } finally {
      if (mounted) setState(() => _locationLoading = false);
    }
  }

  Future<void> _refreshSettings() async {
    final location = await widget.repositories.settings.location();
    if (mounted) setState(() => _location = location);
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
