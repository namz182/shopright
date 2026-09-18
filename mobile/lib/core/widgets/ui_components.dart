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

class IllustratedEmptyState extends StatelessWidget {
  const IllustratedEmptyState({
    required this.icon,
    required this.title,
    required this.message,
    this.accent = AppColors.brand,
    this.compact = false,
    this.actionLabel,
    this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final Color accent;
  final bool compact;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final content = compact
        ? Row(
            children: [
              _EmptyStateIllustration(icon: icon, accent: accent, compact: true),
              const SizedBox(width: 13),
              Expanded(child: _copy(context)),
            ],
          )
        : Column(
            children: [
              _EmptyStateIllustration(icon: icon, accent: accent),
              const SizedBox(height: 12),
              _copy(context),
            ],
          );

    return SoftCard(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 20,
        vertical: compact ? 13 : 22,
      ),
      child: content,
    );
  }

  Widget _copy(BuildContext context) {
    return Column(
      crossAxisAlignment: compact ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: compact ? TextAlign.left : TextAlign.center,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 5),
        Text(
          message,
          textAlign: compact ? TextAlign.left : TextAlign.center,
          style: TextStyle(
            color: secondaryTextColor(context),
            fontSize: 11,
            height: 1.4,
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 13),
          TextButton.icon(
            onPressed: onAction,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: Text(actionLabel!),
            style: TextButton.styleFrom(
              foregroundColor: accent,
              textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ],
      ],
    );
  }
}

class _EmptyStateIllustration extends StatelessWidget {
  const _EmptyStateIllustration({
    required this.icon,
    required this.accent,
    this.compact = false,
  });

  final IconData icon;
  final Color accent;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final size = compact ? 52.0 : 84.0;
    final iconSize = compact ? 21.0 : 31.0;
    return SizedBox(
      width: size + (compact ? 0 : 18),
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: compact ? 0 : 5,
            bottom: compact ? 2 : 0,
            child: Container(
              width: compact ? 40 : 67,
              height: compact ? 40 : 67,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: .10),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Container(
            width: compact ? 38 : 60,
            height: compact ? 38 : 60,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(compact ? 13 : 20),
              border: Border.all(color: accent.withValues(alpha: .22)),
            ),
            child: Icon(icon, color: accent, size: iconSize),
          ),
          if (!compact)
            Positioned(
              right: 1,
              top: 3,
              child: Icon(Icons.auto_awesome_rounded, color: accent.withValues(alpha: .65), size: 17),
            ),
        ],
      ),
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
