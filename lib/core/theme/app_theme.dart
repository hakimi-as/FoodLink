import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme(Color primary, Color secondary) {
    final base = GoogleFonts.dmSansTextTheme();
    return base.copyWith(
      displayLarge:  GoogleFonts.sora(fontSize: 28, fontWeight: FontWeight.w800, color: primary),
      displayMedium: GoogleFonts.sora(fontSize: 24, fontWeight: FontWeight.w800, color: primary),
      headlineLarge: GoogleFonts.sora(fontSize: 22, fontWeight: FontWeight.w700, color: primary),
      headlineMedium:GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: primary),
      headlineSmall: GoogleFonts.sora(fontSize: 17, fontWeight: FontWeight.w700, color: primary),
      titleLarge:    GoogleFonts.sora(fontSize: 16, fontWeight: FontWeight.w700, color: primary),
      titleMedium:   GoogleFonts.sora(fontSize: 15, fontWeight: FontWeight.w600, color: primary),
      titleSmall:    GoogleFonts.sora(fontSize: 13, fontWeight: FontWeight.w600, color: secondary),
      bodyLarge:     GoogleFonts.dmSans(fontSize: 15, fontWeight: FontWeight.w400, color: secondary),
      bodyMedium:    GoogleFonts.dmSans(fontSize: 14, fontWeight: FontWeight.w400, color: secondary),
      bodySmall:     GoogleFonts.dmSans(fontSize: 12, fontWeight: FontWeight.w400, color: secondary),
      labelLarge:    GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      labelMedium:   GoogleFonts.dmSans(fontSize: 13, fontWeight: FontWeight.w600, color: secondary),
      labelSmall:    GoogleFonts.dmSans(fontSize: 10.5, fontWeight: FontWeight.w700, color: secondary),
    );
  }

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.primary2,
      surface: AppColors.card,
      onPrimary: Colors.white,
      onSurface: AppColors.dark,
    ),
    scaffoldBackgroundColor: FLColors.light.background,
    cardColor: FLColors.light.card,
    textTheme: _buildTextTheme(AppColors.dark, AppColors.bodyText),
    extensions: const [FLColors.light],
    appBarTheme: AppBarTheme(
      backgroundColor: FLColors.light.background,
      foregroundColor: AppColors.dark,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      titleTextStyle: GoogleFonts.sora(
        fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.dark),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: FLColors.light.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.border, width: 1.5)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      hintStyle: GoogleFonts.dmSans(color: AppColors.border, fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 44, vertical: 14),
    ),
    dividerTheme: const DividerThemeData(color: AppColors.border, thickness: 1, space: 1),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.primary2,
      surface: Color(0xFF1E293B),
      onPrimary: Colors.white,
      onSurface: Color(0xFFF1F5F9),
    ),
    scaffoldBackgroundColor: FLColors.dark.background,
    cardColor: FLColors.dark.card,
    textTheme: _buildTextTheme(FLColors.dark.text, FLColors.dark.bodyText),
    extensions: const [FLColors.dark],
    appBarTheme: AppBarTheme(
      backgroundColor: FLColors.dark.background,
      foregroundColor: FLColors.dark.text,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      titleTextStyle: GoogleFonts.sora(
        fontSize: 17, fontWeight: FontWeight.w700, color: FLColors.dark.text),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: FLColors.dark.elevated,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: FLColors.dark.border, width: 1.5)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: FLColors.dark.border, width: 1.5)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
      hintStyle: GoogleFonts.dmSans(color: FLColors.dark.hint, fontSize: 15),
      contentPadding: const EdgeInsets.symmetric(horizontal: 44, vertical: 14),
    ),
    dividerTheme: DividerThemeData(color: FLColors.dark.border, thickness: 1, space: 1),
  );
}
