import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';

import '../../widgets/shared_widgets.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';

/// Timetable Screen – Optimized premium UI with ID-card header and glassmorphic frame.
class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});
  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> with SingleTickerProviderStateMixin {
  final TransformationController _transformController = TransformationController();
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _transformController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final studentProfile = authService.studentProfile;
    final rawClassName = (studentProfile?['className'] ?? studentProfile?['CLASS'] ?? MockDataService.demoStudent.className).toString();
    final rawDivision = (studentProfile?['division'] ?? studentProfile?['DIV'] ?? MockDataService.demoStudent.division).toString();

    final grade = _normalizeGrade(rawClassName);
    final division = rawDivision.trim().toUpperCase();

    final timetableAsset = _timetableAssetForGradeDivision(grade: grade, division: division);
    final label = 'Class $grade - $division';

    return Scaffold(
      appBar: const GradientAppBar(title: 'Weekly Timetable', showBackButton: true),
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Dynamic Premium Background
          Positioned.fill(
            child: CustomPaint(
              painter: _EnhancedBackgroundPainter(),
            ),
          ),
          FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              children: [
                // Premium Header
                _buildPremiumHeader(label),

                // Main Content Area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                    child: _buildTimetableFrame(timetableAsset, grade, division),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumHeader(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Stack(
        children: [
          // Background Gradient Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon/Badge Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.calendar_today_rounded,
                      color: AppColors.accent,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'ACADEMIC SCHEDULE',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Decorative Accent
          Positioned(
            right: -10,
            top: -10,
            child: Icon(
              Icons.school_rounded,
              size: 80,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimetableFrame(String asset, String grade, String division) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Stack(
          children: [
            // Glassy Background overlay
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white,
                      AppColors.surfaceElevated,
                    ],
                  ),
                ),
              ),
            ),
            
            // The Image with InteractiveViewer
            Positioned.fill(
              child: GestureDetector(
                onDoubleTap: () => _transformController.value = Matrix4.identity(),
                child: InteractiveViewer(
                  transformationController: _transformController,
                  minScale: 1,
                  maxScale: 5,
                  boundaryMargin: const EdgeInsets.all(40),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(
                      asset,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stack) => _EnhancedMissingAsset(
                        division: '$grade$division',
                        expectedPath: asset,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Top Info Bar
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white.withValues(alpha: 0.95),
                      Colors.white.withValues(alpha: 0.0),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.pinch_rounded, size: 14, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Pinch to zoom • Double tap to reset',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primary.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Premium Zoom Controls
            Positioned(
              right: 16,
              bottom: 16,
              child: _ModernZoomControls(
                onZoomIn: () => _applyZoom(1.3),
                onZoomOut: () => _applyZoom(1 / 1.3),
                onReset: () => _transformController.value = Matrix4.identity(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _applyZoom(double factor) {
    final current = _transformController.value.clone();
    final currentScale = current.getMaxScaleOnAxis();
    final nextScale = (currentScale * factor).clamp(1.0, 5.0);
    final relative = nextScale / (currentScale == 0 ? 1 : currentScale);

    final size = MediaQuery.of(context).size;
    final focal = Offset(size.width / 2, size.height / 2);

    _transformController.value = Matrix4.identity()
      ..translateByDouble(focal.dx, focal.dy, 0, 1)
      ..scaleByDouble(relative, relative, 1, 1)
      ..translateByDouble(-focal.dx, -focal.dy, 0, 1)
      ..multiply(current);
  }

  String _timetableAssetForGradeDivision({required String grade, required String division}) {
    return 'assets/images/timetable_${grade.toLowerCase()}${division.toLowerCase()}.png';
  }

  String _normalizeGrade(String raw) {
    final digits = RegExp(r'\d+').firstMatch(raw)?.group(0);
    if (digits != null && digits.isNotEmpty) return digits;
    final v = raw.trim().toUpperCase();
    const romanToNumber = {
      'I': '1', 'II': '2', 'III': '3', 'IV': '4', 'V': '5',
      'VI': '6', 'VII': '7', 'VIII': '8', 'IX': '9', 'X': '10',
    };
    return romanToNumber[v] ?? '5';
  }
}

class _ModernZoomControls extends StatelessWidget {
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;
  final VoidCallback onReset;

  const _ModernZoomControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildBtn(Icons.add_rounded, onZoomIn, isTop: true),
          Container(
            width: 24,
            height: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          _buildBtn(Icons.remove_rounded, onZoomOut),
          Container(
            width: 24,
            height: 1,
            color: Colors.white.withValues(alpha: 0.1),
          ),
          _buildBtn(Icons.restart_alt_rounded, onReset, isBottom: true, color: AppColors.accent),
        ],
      ),
    );
  }

  Widget _buildBtn(IconData icon, VoidCallback onTap, {bool isTop = false, bool isBottom = false, Color color = Colors.white}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(isTop ? 20 : 0),
          bottom: Radius.circular(isBottom ? 20 : 0),
        ),
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }
}

class _EnhancedBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Soft Blue Blob
    paint.shader = RadialGradient(
      colors: [
        AppColors.primary.withValues(alpha: 0.04),
        AppColors.primary.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromLTWH(-100, -100, 500, 500));
    canvas.drawCircle(const Offset(50, 50), 400, paint);

    // Soft Gold Blob
    paint.shader = RadialGradient(
      colors: [
        AppColors.accent.withValues(alpha: 0.06),
        AppColors.accent.withValues(alpha: 0.0),
      ],
    ).createShader(Rect.fromLTWH(size.width - 250, size.height * 0.5, 500, 500));
    canvas.drawCircle(Offset(size.width - 50, size.height * 0.7), 350, paint);

    // Geometric lines
    final linePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.015)
      ..strokeWidth = 1.5;
    
    for (double i = 0; i < size.width; i += 60) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), linePaint);
    }
    for (double i = 0; i < size.height; i += 60) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _EnhancedMissingAsset extends StatelessWidget {
  final String division;
  final String expectedPath;

  const _EnhancedMissingAsset({required this.division, required this.expectedPath});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.calendar_view_day_rounded, size: 56, color: AppColors.accent),
            ),
            const SizedBox(height: 28),
            const Text(
              'Schedule Unavailable',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.primary),
            ),
            const SizedBox(height: 12),
            Text(
              'The weekly timetable for $division hasn\'t been uploaded to the portal yet.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 32),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'HELP FOR ADMINS',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSubtle, letterSpacing: 1),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Please ensure the image is at:\n$expectedPath',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, fontFamily: 'monospace', color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ExamTimetableScreen extends StatelessWidget {
  const ExamTimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final exams = MockDataService.examTimetable;
    return Scaffold(
      appBar: const GradientAppBar(title: 'Exam Schedule', showBackButton: true),
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        itemCount: exams.length,
        itemBuilder: (context, i) {
          final e = exams[i];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              children: [
                // Premium Date Banner
                Container(
                  width: 75,
                  height: 110,
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      bottomLeft: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${e.date.day}',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 28),
                      ),
                      Text(
                        _monthShort(e.date.month),
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                // Exam Details
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          e.subject,
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: AppColors.primary),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            e.examName.toUpperCase(),
                            style: const TextStyle(fontSize: 10, color: AppColors.accentDark, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 16, color: AppColors.textSubtle),
                            const SizedBox(width: 6),
                            Text(
                              e.time,
                              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 20),
                  child: Icon(Icons.arrow_forward_ios_rounded, size: 18, color: AppColors.border),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _monthShort(int m) {
    const months = ['JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'];
    return months[m - 1];
  }
}
