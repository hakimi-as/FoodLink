import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFFF05A28);
  static const Color primary2 = Color(0xFFFF8547);
  static const Color primaryLight = Color(0xFFFFF1EC);

  static const Color green = Color(0xFF22C55E);
  static const Color greenDark = Color(0xFF16A34A);
  static const Color greenLight = Color(0xFFDCFCE7);

  static const Color dark = Color(0xFF0F172A);
  static const Color bodyText = Color(0xFF1E293B);
  static const Color muted = Color(0xFF64748B);
  static const Color border = Color(0xFFE2E8F0);
  static const Color background = Color(0xFFF7F6F3);
  static const Color card = Color(0xFFFFFFFF);

  static const Color red = Color(0xFFDC2626);
  static const Color redLight = Color(0xFFFEF2F2);
  static const Color redBorder = Color(0xFFFECACA);

  static const Color blue = Color(0xFF3B82F6);
  static const Color purple = Color(0xFFA855F7);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primary2],
  );

  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    stops: [0.0, 0.5, 1.0],
    colors: [Color(0xFF0C1220), Color(0xFF1A2540), Color(0xFF0C1220)],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [dark, Color(0xFF1E2D4A)],
  );
}
