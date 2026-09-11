import 'package:flutter/material.dart';

// ============================================================
// Design System — Danapathi Asset Management (sumber: danapathi.co.id,
// lihat sekuritas-infra/DESIGN_DANAPATHI.md). Navy untuk teks/judul/tombol,
// hijau untuk aksen. Nama field dipertahankan agar seluruh screen ikut berubah.
// ============================================================

class AppColors {
  AppColors._();

  // Brand primary — navy Danapathi
  static const primary = Color(0xFF14365F);
  static const primaryDark = Color(0xFF00214A);
  static const primaryLight = Color(0xFF234A74);

  // Accent — hijau Danapathi
  static const accent = Color(0xFF198754);
  static const accentLight = Color(0xFF6CBF96);

  // "Premium" accent — hijau (dulu gold/rose)
  static const gold = Color(0xFF198754);
  static const goldLight = Color(0xFFCDEBDC);

  // Secondary — hijau semantik "naik/sukses"
  static const secondary = Color(0xFF1F8A5B);

  // Backgrounds — putih & abu kebiruan lembut
  static const background = Color(0xFFF9FAFB);
  static const surface = Color(0xFFF8FAFC);
  static const surfaceVariant = Color(0xFFE5E7EB);

  // Dark sections (header/hero) — navy
  static const darkBg = Color(0xFF00214A);
  static const darkBg2 = Color(0xFF0F2F55);
  static const darkSurface = Color(0xFF14365F);

  // Status (semantik universal)
  static const error = Color(0xFFD84B4B);
  static const success = Color(0xFF198754);
  static const warning = Color(0xFFEBBA45);

  // Text — navy judul, abu biru body
  static const textPrimary = Color(0xFF00214A);
  static const textSecondary = Color(0xFF617286);
  static const textHint = Color(0xFF94A3B8);

  // UI elements
  static const divider = Color(0xFFE5E7EB);
  static const cardShadow = Color(0x1410305A);
  static const overlay = Color(0x80000000);
  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF000000);

  // Badge colors
  static const badgeWarning = Color(0xFFFEF3C7);
  static const badgeWarningText = Color(0xFF92400E);
  static const badgeError = Color(0xFFFEE2E2);
  static const badgeErrorText = Color(0xFFDC2626);
  static const badgeSuccess = Color(0xFFE9F5EF);
  static const badgeSuccessText = Color(0xFF146B40);
  static const badgeInfo = Color(0xFFEEF3F9);
  static const badgeInfoText = Color(0xFF14365F);

  // Gradient stops — navy -> biru panel kepercayaan
  static const gradientStart = Color(0xFF00214A);
  static const gradientMid = Color(0xFF14365F);
  static const gradientEnd = Color(0xFF1F4F87);

  // Bottom nav
  static const navUnselected = Color(0xFF94A3B8);
  static const navSelected = Color(0xFF14365F);

  // Glassmorphism
  static const glassWhite = Color(0x1AFFFFFF);
  static const glassBorder = Color(0x1AFFFFFF);
}
