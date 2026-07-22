import 'package:flutter/material.dart';

// ============================================================
// Design System — "Victoria Merah" (warna brand ASLI Victoria Sekuritas)
// Brand mark = ornamen MERAH #A40001, wordmark hitam, netral hangat.
// Palet logo: #a40001 #f0f3ec #c67177 #d59997 #fffdfc #e2dad3 #d2d7d3
// Nama field dipertahankan agar seluruh screen ikut berubah otomatis.
// ============================================================

class AppColors {
  AppColors._();

  // Brand primary — merah Victoria
  static const primary = Color(0xFFA40001);
  static const primaryDark = Color(0xFF7D0001);
  static const primaryLight = Color(0xFFC85155);

  // Accent — rose (dari logo)
  static const accent = Color(0xFFC67177);
  static const accentLight = Color(0xFFD59997);

  // "Premium" accent — rose (dulu gold/violet)
  static const gold = Color(0xFFC67177);
  static const goldLight = Color(0xFFE2DAD3);

  // Secondary — hijau dipertahankan utk semantik "naik/sukses"
  static const secondary = Color(0xFF10B981);

  // Backgrounds — netral hangat brand (krem)
  static const background = Color(0xFFFFFDFC);
  static const surface = Color(0xFFF0F3EC);
  static const surfaceVariant = Color(0xFFE2DAD3);

  // Dark sections (header/hero) — merah tua Victoria
  static const darkBg = Color(0xFF7D0001);
  static const darkBg2 = Color(0xFF8F0001);
  static const darkSurface = Color(0xFFA40001);

  // Status (semantik universal)
  static const error = Color(0xFFEF4444);
  static const success = Color(0xFF10B981);
  static const warning = Color(0xFFF59E0B);

  // Text — near-black (wordmark Victoria hitam)
  static const textPrimary = Color(0xFF1A1A1A);
  static const textSecondary = Color(0xFF6B6560);
  static const textHint = Color(0xFF9C9691);

  // UI elements
  static const divider = Color(0xFFE2DAD3);
  static const cardShadow = Color(0x14A40001);
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
  static const badgeInfo = Color(0xFFFBEAEA);
  static const badgeInfoText = Color(0xFFA40001);

  // Gradient stops — merah -> rose
  static const gradientStart = Color(0xFF7D0001);
  static const gradientMid = Color(0xFFA40001);
  static const gradientEnd = Color(0xFFC67177);

  // Bottom nav
  static const navUnselected = Color(0xFF9C9691);
  static const navSelected = Color(0xFFA40001);

  // Glassmorphism
  static const glassWhite = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x1AFFFFFF);
}
