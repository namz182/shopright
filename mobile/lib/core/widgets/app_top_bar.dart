import 'package:flutter/material.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({required this.title, this.subtitle, this.trailing, super.key});

  final String title;
  final String? subtitle;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppLogo(),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 19,
                  letterSpacing: -.35,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 1),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF7B8494),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 10),
        trailing ?? const SizedBox(width: 40),
      ],
    );
  }
}

class AppStickyTopBar extends StatelessWidget {
  const AppStickyTopBar({required this.title, this.subtitle, super.key});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(22, 12, 22, 8),
            child: AppTopBar(title: title, subtitle: subtitle),
          ),
        ),
      ),
    );
  }
}

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(11),
      child: Image.asset(
        'android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png',
        width: 38,
        height: 38,
        fit: BoxFit.cover,
      ),
    );
  }
}
