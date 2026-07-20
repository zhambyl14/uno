import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/constants/insets.dart';

/// Redesign v2 brand seed: purple → magenta, the anchor of the
/// purple/magenta/gold "aurora" palette used across hero surfaces.
const Color _seed = Color(0xFF8B3FF0);

ThemeData buildTheme(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(seedColor: _seed, brightness: brightness);
  final base = ThemeData(colorScheme: scheme, useMaterial3: true);
  // Baloo 2 for display/headings (chunky, playful — matches the redesign's
  // rounded card-game identity); Inter for everything else (readable at
  // small sizes for stats/labels).
  final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
    displayLarge: GoogleFonts.baloo2(textStyle: base.textTheme.displayLarge),
    displayMedium: GoogleFonts.baloo2(textStyle: base.textTheme.displayMedium),
    displaySmall: GoogleFonts.baloo2(textStyle: base.textTheme.displaySmall),
    headlineLarge: GoogleFonts.baloo2(textStyle: base.textTheme.headlineLarge),
    headlineMedium: GoogleFonts.baloo2(
      textStyle: base.textTheme.headlineMedium,
    ),
    headlineSmall: GoogleFonts.baloo2(textStyle: base.textTheme.headlineSmall),
    titleLarge: GoogleFonts.baloo2(
      textStyle: base.textTheme.titleLarge,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: GoogleFonts.baloo2(
      textStyle: base.textTheme.titleMedium,
      fontWeight: FontWeight.w600,
    ),
  );
  return base.copyWith(
    textTheme: textTheme,
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(Corners.l)),
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(Corners.m)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(64, 48),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(Corners.m)),
        ),
      ),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
