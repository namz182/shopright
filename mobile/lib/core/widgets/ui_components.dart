import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

Color secondaryTextColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? AppColors.muted
    : AppColors.slate;

class BrandIconTile extends StatelessWidget {
  const BrandIconTile({required this.icon, this.size = 44, super.key});

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: dark ? AppColors.brandDeep : AppColors.brand,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(icon, color: AppColors.white, size: 19),
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {this.trailing, super.key});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              height: 1.2,
              letterSpacing: 1.05,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class SoftCard extends StatelessWidget {
  const SoftCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.color,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return Material(
      color: color ?? (dark ? AppColors.nightCard : AppColors.surface),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: dark ? AppColors.nightBorder : AppColors.border,
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.light = false,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 17),
      label: Text(label),
      style: FilledButton.styleFrom(
        elevation: 0,
        backgroundColor: light
            ? (dark ? AppColors.nightBorder : AppColors.white)
            : (dark ? AppColors.brandDeep : AppColors.brand),
        foregroundColor: light ? AppColors.ink : AppColors.white,
        minimumSize: const Size(0, 50),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
        shape: const StadiumBorder(),
        textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
      ),
    );
  }
}
