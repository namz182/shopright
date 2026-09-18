import 'package:flutter/material.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({this.trailing, super.key});

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const AppLogo(),
        const SizedBox(width: 10),
        const Text(
          'Shop Right',
          style: TextStyle(
            fontSize: 19,
            letterSpacing: -.35,
            fontWeight: FontWeight.w900,
          ),
        ),
        const Spacer(),
        trailing ?? const SizedBox(width: 40),
      ],
    );
  }
}

class AppStickyTopBar extends StatelessWidget {
  const AppStickyTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: const SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(22, 12, 22, 8),
            child: AppTopBar(),
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
