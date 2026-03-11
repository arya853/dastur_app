import 'package:flutter/material.dart';

/// Dastur School Parent Portal - Color Design System
///
/// A unique, premium color palette inspired by the school's identity
/// but elevated with modern gradients and sophisticated tones.
class AppColors {
  AppColors._();

  // ─── PRIMARY PALETTE ───────────────────────────────────────────────
  /// Deep navy — the school's signature blue, darkened for a premium feel
  static const Color primary = Color(0xFF0A1628);

  /// Royal blue — a brighter blue for interactive elements
  static const Color primaryLight = Color(0xFF1E3A5F);

  /// Midnight — the deepest variant for backgrounds
  static const Color primaryDark = Color(0xFF060F1E);

  // ─── ACCENT PALETTE ────────────────────────────────────────────────
  /// Warm amber gold — school's signature accent, refined
  static const Color accent = Color(0xFFE8A838);

  /// Bright gold — for highlights and hover states
  static const Color accentLight = Color(0xFFF5C563);

  /// Deep amber — for pressed/active states
  static const Color accentDark = Color(0xFFC4892A);

  // ─── GRADIENT DEFINITIONS ─────────────────────────────────────────
  /// Premium header gradient (dark navy to royal blue)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0A1628), Color(0xFF1E3A5F)],
  );

  /// Gold shimmer gradient for accents and highlights
  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFE8A838), Color(0xFFF5C563)],
  );

  /// Card background gradient (subtle glassmorphism effect)
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FE)],
  );

  /// Dashboard tile gradient
  static const LinearGradient tileGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F2037), Color(0xFF1A3555)],
  );

  // ─── SURFACE COLORS ───────────────────────────────────────────────
  /// Main background — warm off-white
  static const Color background = Color(0xFFF4F6FA);

  /// Card surface — pure white
  static const Color surface = Color(0xFFFFFFFF);

  /// Elevated surface — slightly tinted
  static const Color surfaceElevated = Color(0xFFF8F9FE);

  /// Divider / border color
  static const Color border = Color(0xFFE2E8F0);

  // ─── TEXT COLORS ──────────────────────────────────────────────────
  /// Primary text — near-black
  static const Color textPrimary = Color(0xFF1A1D26);

  /// Secondary text — muted grey
  static const Color textSecondary = Color(0xFF6B7280);

  /// Subtle text — light grey
  static const Color textSubtle = Color(0xFF9CA3AF);

  /// Text on dark backgrounds
  static const Color textOnDark = Color(0xFFFFFFFF);

  /// Text on dark backgrounds (muted)
  static const Color textOnDarkMuted = Color(0xFFB0BEC5);

  // ─── STATUS / SEMANTIC COLORS ─────────────────────────────────────
  /// Attendance: Present
  static const Color statusPresent = Color(0xFF10B981);

  /// Attendance: Absent
  static const Color statusAbsent = Color(0xFFEF4444);

  /// Attendance: Leave
  static const Color statusLeave = Color(0xFFF59E0B);

  /// Success actions / confirmations
  static const Color success = Color(0xFF10B981);

  /// Warning / caution
  static const Color warning = Color(0xFFF59E0B);

  /// Error / destructive
  static const Color error = Color(0xFFEF4444);

  /// Informational
  static const Color info = Color(0xFF3B82F6);

  // ─── ROLE BADGE COLORS ────────────────────────────────────────────
  /// Admin role badge
  static const Color roleAdmin = Color(0xFF7C3AED);

  /// Teacher role badge
  static const Color roleTeacher = Color(0xFF0891B2);

  /// Parent role badge
  static const Color roleParent = Color(0xFF059669);

  // ─── DASHBOARD TILE ICON BACKGROUNDS ──────────────────────────────
  static const List<Color> tileIconColors = [
    Color(0xFF3B82F6), // Calendar - blue
    Color(0xFFF59E0B), // Announcements - amber
    Color(0xFF8B5CF6), // PTM - purple
    Color(0xFF10B981), // Syllabus - green
    Color(0xFFEC4899), // E-Books - pink
    Color(0xFF06B6D4), // Quizzes - cyan
    Color(0xFFF97316), // Practice Papers - orange
    Color(0xFF6366F1), // Fees - indigo
    Color(0xFF14B8A6), // Attendance - teal
    Color(0xFFE11D48), // Timetable - rose
    Color(0xFF8B5CF6), // Exam Timetable - violet
    Color(0xFF0EA5E9), // Profile - sky
  ];
}
