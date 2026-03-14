/// Dastur School Parent Portal - App Constants
///
/// Centralized constants for the entire application including
/// school branding, spacing, border radius, and demo credentials.
class AppConstants {
  AppConstants._();

  // ─── SCHOOL BRANDING ──────────────────────────────────────────────
  static const String schoolName = 'Sardar Dastur Hormazdiar High School';
  static const String schoolShortName = 'Dastur School';
  static const String schoolTagline = 'Good Thoughts, Good Words, Good Deeds';
  static const String schoolCity = 'Pune';
  static const String schoolWebsite = 'https://coed.dasturschools.in/';
  static const String schoolLogoPath = 'assets/images/school_logo.png';
  static const String defaultAvatarPath = 'assets/images/default_avatar.png';

  // ─── SPACING SYSTEM ───────────────────────────────────────────────
  static const double spacingXs = 4.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double spacingXxl = 48.0;

  // ─── BORDER RADIUS ────────────────────────────────────────────────
  static const double radiusSm = 8.0;
  static const double radiusMd = 12.0;
  static const double radiusLg = 16.0;
  static const double radiusXl = 24.0;
  static const double radiusRound = 100.0;

  // ─── ELEVATION ────────────────────────────────────────────────────
  static const double elevationSm = 2.0;
  static const double elevationMd = 4.0;
  static const double elevationLg = 8.0;

  // ─── ICON SIZES ───────────────────────────────────────────────────
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 48.0;

  // ─── DEMO CREDENTIALS ─────────────────────────────────────────────
  /// Demo accounts for immediate testing without Firebase
  static const String demoAdminEmail = 'admin@dasturschool.in';
  static const String demoTeacherEmail = 'teacher@dasturschool.in';
  static const String demoParentEmail = 'parent@dasturschool.in';
  static const String demoPassword = 'dastur123';

  // ─── APP INFO ─────────────────────────────────────────────────────
  static const String appVersion = '1.0.0';
  static const String academicYear = '2025-2026';

  // ─── ROLE STRINGS ─────────────────────────────────────────────────
  static const String roleAdmin = 'admin';
  static const String roleTeacher = 'teacher';
  static const String roleParent = 'parent';
}
