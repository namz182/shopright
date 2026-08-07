import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final base = ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.white,
      colorScheme: const ColorScheme.light(
        primary: AppColors.brand,
        onPrimary: AppColors.white,
        surface: AppColors.white,
        onSurface: AppColors.ink,
        outline: AppColors.border,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.ink,
        displayColor: AppColors.ink,
        fontFamily: '.SF Pro Text',
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.soft,
        hintStyle: const TextStyle(
          color: AppColors.muted,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: AppColors.muted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.brand),
        ),
      ),
      dividerColor: AppColors.border,
      splashFactory: NoSplash.splashFactory,
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: AppColors.brand,
        scaffoldBackgroundColor: AppColors.white,
        barBackgroundColor: AppColors.white,
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.ink,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.brand,
        onPrimary: AppColors.white,
        surface: AppColors.nightCard,
        onSurface: AppColors.white,
        surfaceContainerHighest: AppColors.nightInput,
        onSurfaceVariant: AppColors.muted,
        outline: AppColors.nightBorder,
      ),
    );
    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.white,
        displayColor: AppColors.white,
        fontFamily: '.SF Pro Text',
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
        },
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.nightInput,
        hintStyle: const TextStyle(
          color: AppColors.muted,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        prefixIconColor: AppColors.muted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.nightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: AppColors.brand),
        ),
      ),
      dividerColor: AppColors.nightBorder,
      splashFactory: NoSplash.splashFactory,
      cupertinoOverrideTheme: const CupertinoThemeData(
        primaryColor: AppColors.brand,
        scaffoldBackgroundColor: AppColors.ink,
        barBackgroundColor: AppColors.ink,
      ),
    );
  }
}
