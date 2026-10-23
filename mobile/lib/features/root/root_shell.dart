import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/app_bottom_nav.dart';
import '../../core/widgets/app_top_bar.dart';
import '../../core/widgets/ui_components.dart';
import '../../data/local/models.dart';
import '../../data/remote/shop_right_api.dart';
import '../../data/repositories/repositories.dart';
import '../../data/repositories/data_sources.dart';
import '../history/history_screen.dart';
import '../home/home_screen.dart';
import '../settings/settings_screen.dart';
import '../shops/shops_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({
    required this.repositories,
    required this.isDarkMode,
    required this.onThemeChanged,
    super.key,
  });

  final Repositories repositories;
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  AppTab _tab = AppTab.home;
  int _locationRevision = 0;
  UserLocation _location = const UserLocation();
  bool _locationLoaded = false;

  @override
  void initState() {
    super.initState();
    widget.repositories.settings.location().then((location) {
      if (mounted) {
        setState(() {
          _location = location;
          _locationLoaded = true;
        });
      }
    }).catchError((error, stack) {
      debugPrint('[ShopRight Location] load failed: $error');
      if (mounted) setState(() => _locationLoaded = true);
    });
  }

  void _switchTab(AppTab tab) {
    Navigator.of(context).popUntil((route) => route.isFirst);
    setState(() => _tab = tab);
  }

  String get _pageTitle => switch (_tab) {
        AppTab.home => 'Shop Right',
        AppTab.history => 'Comparison History',
        AppTab.shops => 'Nearby Shops',
        AppTab.settings => 'Settings',
      };

  String? get _pageSubtitle => _tab == AppTab.shops ? _location.label : null;

  @override
  Widget build(BuildContext context) {
    if (!_locationLoaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.brand)),
      );
    }

    if (!_location.isSelected) {
      return LocationRequiredScreen(
        repositories: widget.repositories,
        onLocationSelected: (location) => setState(() {
          _location = location;
          _locationRevision++;
        }),
      );
    }

    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _tab.index,
            children: [
              HomeScreen(
                key: ValueKey('home-$_locationRevision'),
                repositories: widget.repositories,
                isDarkMode: widget.isDarkMode,
                onThemeChanged: widget.onThemeChanged,
                onTabSelected: _switchTab,
              ),
              HistoryScreen(repositories: widget.repositories),
              ShopsScreen(
                key: ValueKey('shops-$_locationRevision'),
                repositories: widget.repositories,
              ),
              SettingsScreen(
                repositories: widget.repositories,
                isDarkMode: widget.isDarkMode,
                onThemeChanged: widget.onThemeChanged,
                onLocationChanged: (location) => setState(() {
                  _location = location;
                  _locationRevision++;
                }),
              ),
            ],
          ),
          AppStickyTopBar(title: _pageTitle, subtitle: _pageSubtitle),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AppBottomNav(selected: _tab, onSelected: _switchTab),
          ),
        ],
      ),
    );
  }
}

class LocationRequiredScreen extends StatefulWidget {
  const LocationRequiredScreen({required this.repositories, required this.onLocationSelected, super.key});

  final Repositories repositories;
  final ValueChanged<UserLocation> onLocationSelected;

  @override
  State<LocationRequiredScreen> createState() => _LocationRequiredScreenState();
}

class _LocationRequiredScreenState extends State<LocationRequiredScreen> {
  bool _loading = false;
  String? _error;

  Future<void> _chooseLocation() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final api = ShopRightApi();
      final provinces = await api.fetchProvinces();
      if (!mounted) return;
      ProvinceInfo? province;
      DistrictInfo? district;
      List<DistrictInfo> districts = const [];
      final selected = await showDialog<UserLocation>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: const Text('Select your location'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<ProvinceInfo>(
                  value: province,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'Province'),
                  items: provinces
                      .map((item) => DropdownMenuItem(value: item, child: Text(item.name)))
                      .toList(),
                  onChanged: (value) async {
                    if (value == null) return;
                    final next = await api.fetchDistricts(value.id);
                    setDialogState(() {
                      province = value;
                      districts = next;
                      district = null;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<DistrictInfo>(
                  value: district,
                  isExpanded: true,
                  decoration: const InputDecoration(labelText: 'District'),
                  items: districts
                      .map((item) => DropdownMenuItem(value: item, child: Text(item.name)))
                      .toList(),
                  onChanged: (value) => setDialogState(() => district = value),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: province == null || district == null
                    ? null
                    : () => Navigator.pop(
                          dialogContext,
                          UserLocation(
                            provinceId: province!.id,
                            provinceName: province!.name,
                            districtId: district!.id,
                            districtName: district!.name,
                          ),
                        ),
                child: const Text('Continue'),
              ),
            ],
          ),
        ),
      );

      if (selected != null) {
        await widget.repositories.settings.setLocation(selected);
        if (!mounted) return;
        widget.onLocationSelected(selected);
      }
    } catch (error, stack) {
      debugPrint('[ShopRight Location] selection failed: $error');
      debugPrintStack(stackTrace: stack);
      if (mounted) setState(() => _error = 'Unable to connect');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                children: [
                  const AppLogo(),
                  const SizedBox(height: 22),
                  const Text(
                    'Choose your location',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 9),
                  Text(
                    'Select a province and district to compare prices from nearby stores.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: secondaryTextColor(context), fontSize: 13, height: 1.45),
                  ),
                  const SizedBox(height: 28),
                  IllustratedEmptyState(
                    icon: CupertinoIcons.location_solid,
                    title: 'Your area powers every comparison',
                    message: 'We use your selected district to load the right products, stores, and prices.',
                    accent: AppColors.brand,
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: _loading ? 'Loading locations...' : 'Select province and district',
                      icon: CupertinoIcons.location,
                      onPressed: _loading ? null : _chooseLocation,
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(_error!, style: const TextStyle(color: Color(0xFFE5484D), fontSize: 12, fontWeight: FontWeight.w700)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
