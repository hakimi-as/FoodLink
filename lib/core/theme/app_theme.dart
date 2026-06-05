import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static TextTheme _buildTextTheme() {
    final base = GoogleFonts.dmSansTextTheme();
    return base.copyWith(
      displayLarge: GoogleFonts.sora(
          fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.dark),
      displayMedium: GoogleFonts.sora(
          fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.dark),
      headlineLarge: GoogleFonts.sora(
          fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.dark),
      headlineMedium: GoogleFonts.sora(
          fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.dark),
      headlineSmall: GoogleFonts.sora(
          fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.dark),
      titleLarge: GoogleFonts.sora(
          fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.dark),
      titleMedium: GoogleFonts.sora(
          fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.dark),
      titleSmall: GoogleFonts.sora(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted),
      bodyLarge: GoogleFonts.dmSans(
          fontSize: 15, fontWeight: FontWeight.w400, color: AppColors.bodyText),
      bodyMedium: GoogleFonts.dmSans(
          fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.bodyText),
      bodySmall: GoogleFonts.dmSans(
          fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.muted),
      labelLarge: GoogleFonts.dmSans(
          fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
      labelMedium: GoogleFonts.dmSans(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.bodyText),
      labelSmall: GoogleFonts.dmSans(
          fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.muted),
    );
  }

  static ThemeData get light {
    final textTheme = _buildTextTheme();
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        secondary: AppColors.primary2,
        surface: AppColors.card,
        onPrimary: Colors.white,
        onSurface: AppColors.dark,
      ),
      scaffoldBackgroundColor: AppColors.background,
      cardColor: AppColors.card,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.dark,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.sora(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.dark,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        hintStyle: GoogleFonts.dmSans(
            color: const Color(0xFFCBD5E1), fontSize: 15),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 44, vertical: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 54),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle:
              GoogleFonts.dmSans(fontSize: 16, fontWeight: FontWeight.w600),
          elevation: 0,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.primary2,
        surface: Color(0xFF1E293B),
        onPrimary: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: AppColors.dark,
      cardColor: const Color(0xFF1E293B),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.dark,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
    );
  }
}
