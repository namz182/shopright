import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/ui_components.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({
    required this.isDarkMode,
    required this.onThemeChanged,
    super.key,
  });

  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _isDarkMode = widget.isDarkMode;

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
                        value: 'Ndola, Copperbelt',
                        onTap: () => _showMessage(context, 'Location'),
                      ),
                      _SettingsAction(
                        icon: CupertinoIcons.bell_fill,
                        label: 'Price alerts',
                        value: 'On',
                        onTap: () => _showMessage(context, 'Price alerts'),
                      ),
                      _SettingsAction(
                        icon: CupertinoIcons.money_dollar_circle_fill,
                        label: 'Currency',
                        value: 'ZMW',
                        onTap: () => _showMessage(context, 'Currency'),
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
}

Future<void> _refresh() =>
    Future<void>.delayed(const Duration(milliseconds: 850));

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
  });

  final IconData icon;
  final String label;
  final String? value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
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
            if (value != null)
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
