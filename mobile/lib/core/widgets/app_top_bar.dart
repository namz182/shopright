import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppTopBar extends StatelessWidget {
  const AppTopBar({this.trailing, super.key});

  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
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
        trailing ??
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: dark ? AppColors.nightInput : AppColors.soft,
                shape: BoxShape.circle,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    CupertinoIcons.bell,
                    size: 18,
                    color: dark ? AppColors.white : AppColors.ink,
                  ),
                  Positioned(
                    right: 10,
                    top: 9,
                    child: Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: dark ? AppColors.white : AppColors.ink,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: dark ? AppColors.nightInput : AppColors.soft,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
