// Shiry Kids — Design Tokens extracted from Figma
// Primary token: Accents/Red = #FF383C
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand / Accent ───────────────────────────────────────────
  static const Color primary   = Color(0xffaa0036); // Accents/Red
  static const Color primaryLight = Color(0xFFFF6B6E);
  static const Color primaryDark  = Color(0xFFD42D30);

  // ── Neutral ──────────────────────────────────────────────────
  static const Color textDark   = Color(0xFF444444);
  static const Color textMedium = Color(0xFF888888);
  static const Color textLight  = Color(0xFFAAAAAA);
  static const Color white      = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF8F8F8);
  static const Color surface    = Color(0xFFFFFFFF);
  static const Color divider    = Color(0xFFEEEEEE);

  // ── Palettes (from Figma resources) ──────────────────────────
  // Pizazz / Trinidad orange-red palette
  static const Color pizazz100 = Color(0xFFFFEDD5);
  static const Color pizazz200 = Color(0xFFFFCCA0);
  static const Color pizazz300 = Color(0xFFFFAA6B);
  static const Color pizazz400 = Color(0xFFFF8836);
  static const Color pizazz500 = Color(0xFFFF6600); // Pizazz
  static const Color trinidad  = Color(0xFFE84A1E); // Trinidad

  // Cyan / Aqua palette
  static const Color aqua100 = Color(0xFFD0F8FF);
  static const Color aqua500 = Color(0xFF00BCD4);

  // ── Semantic ─────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error   = Color(0xFFFF383C);
  static const Color info    = Color(0xFF2196F3);

  // ── Overlay ──────────────────────────────────────────────────
  static const Color overlay = Color(0x1AFFFFFF); // #FFFFFF 10%
  static const Color scrim   = Color(0x80000000);
}
