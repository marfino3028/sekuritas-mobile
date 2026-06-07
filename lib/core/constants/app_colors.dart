import 'package:flutter/material.dart';

// ============================================================
// Design System — "Indigo Premium"
// Brand: indigo (primary) + violet (accent). Sengaja dijauhkan
// dari teal/navy/gold. Nama field dipertahankan agar seluruh
// screen yang memakai AppColors.* ikut berubah otomatis.
// ============================================================

class AppColors {
  AppColors._();

  // Brand primary — indigo
  static const primary = Color(0xFF4F46E5);
  static const primaryDark = Color(0xFF4338CA);
  static const primaryLight = Color(0xFF818CF8);

  // Accent — violet (dulu sky blue)
  static const accent = Color(0xFF8B5CF6);
  static const accentLight = Color(0xFFA78BFA);

  // "Premium" accent — dialihkan dari gold ke violet agar on-brand
  static const gold = Color(0xFF7C3AED);
  static const goldLight = Color(0xFFC4B5FD);

  // Secondary — green dipertahankan utk semantik "naik/sukses"
  static const secondary = Color(0xFF10B981);

  // Backgrounds (sedikit ber-tint indigo/violet, premium & airy)
  static const background = Color(0xFFFFFFFF);
  static const surface = Color(0xFFF5F4FF);
  static const surfaceVariant = Color(0xFFECEAFE);

  // Dark sections (header/hero) — deep indigo, BUKAN navy
  static const darkBg = Color(0xFF312E81);
  static const darkBg2 = Color(0xFF3730A3);
  static const darkSurface = Color(0xFF4338CA);

  // Status (semantik universal — dipertahankan)
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);

  // Text — heading dark indigo utk nuansa premium
  static const textPrimary = Color(0xFF1E1B4B);
  static const textSecondary = Color(0xFF6B7280);
  static const textHint = Color(0xFF9CA3AF);

  // UI elements
  static const divider = Color(0xFFE8E7F3);
  static const cardShadow = Color(0x14312E81);
  static const overlay = Color(0x80000000);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  // Badge colors
  static const badgeWarning = Color(0xFFFEF3C7);
  static const badgeWarningText = Color(0xFF92400E);
  static const badgeError = Color(0xFFFEE2E2);
  static const badgeErrorText = Color(0xFFDC2626);
  static const badgeSuccess = Color(0xFFD1FAE5);
  static const badgeSuccessText = Color(0xFF065F46);
  static const badgeInfo = Color(0xFFE0E7FF);
  static const badgeInfoText = Color(0xFF4338CA);

  // Gradient stops — indigo -> violet
  static const gradientStart = Color(0xFF4F46E5);
  static const gradientMid = Color(0xFF6366F1);
  static const gradientEnd = Color(0xFF8B5CF6);

  // Bottom nav
  static const navUnselected = Color(0xFF9CA3AF);
  static const navSelected = Color(0xFF4F46E5);

  // Glassmorphism
  static const glassWhite = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x1AFFFFFF);
}
