import 'package:flutter/material.dart';

// ── Static brand colours (same in light and dark) ──────────────────────────
class AppColors {
  AppColors._();

  static const Color primary     = Color(0xFFF05A28);
  static const Color primary2    = Color(0xFFFF8547);
  static const Color primaryLight = Color(0xFFFFF1EC);

  static const Color green      = Color(0xFF22C55E);
  static const Color greenDark  = Color(0xFF16A34A);
  static const Color greenLight = Color(0xFFDCFCE7);

  static const Color red       = Color(0xFFDC2626);
  static const Color redLight  = Color(0xFFFEF2F2);
  static const Color redBorder = Color(0xFFFECACA);

  static const Color blue   = Color(0xFF3B82F6);
  static const Color purple = Color(0xFFA855F7);

  // Kept for places that don't need adaptive colours
  static const Color dark        = Color(0xFF0F172A);
  static const Color bodyText    = Color(0xFF1E293B);
  static const Color muted       = Color(0xFF64748B);
  static const Color border      = Color(0xFFE2E8F0);
  static const Color background  = Color(0xFFF7F6F3);
  static const Color card        = Color(0xFFFFFFFF);

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primary2],
  );

  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [dark, Color(0xFF1E2D4A)],
  );
}

// ── Adaptive colour palette (ThemeExtension) ──────────────────────────────
class FLColors extends ThemeExtension<FLColors> {
  final Color background;
  final Color card;
  final Color elevated;   // inputs, secondary surfaces
  final Color border;
  final Color text;       // headings / primary text
  final Color bodyText;
  final Color muted;
  final Color hint;       // placeholder text
  final bool  isDark;

  const FLColors({
    required this.background,
    required this.card,
    required this.elevated,
    required this.border,
    required this.text,
    required this.bodyText,
    required this.muted,
    required this.hint,
    required this.isDark,
  });

  // ── Light ────────────────────────────────────────────────────────────────
  static const light = FLColors(
    background : Color(0xFFF7F6F3),
    card       : Color(0xFFFFFFFF),
    elevated   : Color(0xFFF1F5F9),
    border     : Color(0xFFE2E8F0),
    text       : Color(0xFF0F172A),
    bodyText   : Color(0xFF1E293B),
    muted      : Color(0xFF64748B),
    hint       : Color(0xFFCBD5E1),
    isDark     : false,
  );

  // ── Dark (industrial Slate palette) ─────────────────────────────────────
  static const dark = FLColors(
    background : Color(0xFF0F172A),  // slate-900
    card       : Color(0xFF1E293B),  // slate-800
    elevated   : Color(0xFF273449),  // between slate-700/800
    border     : Color(0xFF334155),  // slate-700
    text       : Color(0xFFF1F5F9),  // slate-100
    bodyText   : Color(0xFFCBD5E1),  // slate-300
    muted      : Color(0xFF94A3B8),  // slate-400
    hint       : Color(0xFF475569),  // slate-600
    isDark     : true,
  );

  @override
  FLColors copyWith({
    Color? background, Color? card, Color? elevated, Color? border,
    Color? text, Color? bodyText, Color? muted, Color? hint, bool? isDark,
  }) => FLColors(
    background: background ?? this.background,
    card:       card       ?? this.card,
    elevated:   elevated   ?? this.elevated,
    border:     border     ?? this.border,
    text:       text       ?? this.text,
    bodyText:   bodyText   ?? this.bodyText,
    muted:      muted      ?? this.muted,
    hint:       hint       ?? this.hint,
    isDark:     isDark     ?? this.isDark,
  );

  @override
  FLColors lerp(FLColors? other, double t) {
    if (other == null) return this;
    return FLColors(
      background : Color.lerp(background, other.background, t)!,
      card       : Color.lerp(card,       other.card,       t)!,
      elevated   : Color.lerp(elevated,   other.elevated,   t)!,
      border     : Color.lerp(border,     other.border,     t)!,
      text       : Color.lerp(text,       other.text,       t)!,
      bodyText   : Color.lerp(bodyText,   other.bodyText,   t)!,
      muted      : Color.lerp(muted,      other.muted,      t)!,
      hint       : Color.lerp(hint,       other.hint,       t)!,
      isDark     : t > 0.5 ? (other.isDark) : isDark,
    );
  }
}

// ── Context shorthand ──────────────────────────────────────────────────────
extension FLColorsExt on BuildContext {
  FLColors get clr => Theme.of(this).extension<FLColors>() ?? FLColors.light;
}
