import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
// import '../../core/app_constants.dart';
import '../../widgets/dashboard_tile.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../../models/teacher.dart';

/// Teacher Dashboard Screen
///
/// Overview of today's classes, quick actions for attendance,
/// quizzes, syllabus updates, and class management.
class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final teacher = MockDataService.demoTeacher;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Header
          SliverToBoxAdapter(child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28)),
            ),
            child: SafeArea(bottom: false, child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Good Morning,', style: TextStyle(color: AppColors.textOnDark.withValues(alpha: 0.7), fontSize: 14)),
                    Text(authService.currentUser?.displayName ?? 'Teacher', style: const TextStyle(color: AppColors.textOnDark, fontSize: 20, fontWeight: FontWeight.w700)),
                  ]),
                  Row(children: [
                    const RoleBadge(role: 'teacher'),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () async { await authService.logout(); if (context.mounted) Navigator.pushReplacementNamed(context, '/login'); },
                      child: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.logout, color: AppColors.textOnDark, size: 20)),
                    ),
                  ]),
                ]),
                const SizedBox(height: 12),
                // Classes & subjects
                Wrap(spacing: 8, runSpacing: 6, children: [
                  ...teacher.subjects.map((s) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                    child: Text(s, style: const TextStyle(color: AppColors.accent, fontSize: 12, fontWeight: FontWeight.w600)),
                  )),
                  ...teacher.assignedClasses.map((c) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
                    child: Text(c, style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 12, fontWeight: FontWeight.w500)),
                  )),
                ]),
              ]),
            )),
          )),
          const SliverToBoxAdapter(child: SectionHeader(title: 'Quick Actions')),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.count(
              crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.95,
              children: [
                DashboardTile(icon: Icons.fact_check, label: 'Mark\nAttendance', iconColor: AppColors.tileIconColors[8],
                  onTap: () => Navigator.pushNamed(context, '/teacher-mark-attendance')),
                DashboardTile(icon: Icons.campaign, label: 'Post\nAnnouncement', iconColor: AppColors.tileIconColors[1],
                  onTap: () => Navigator.pushNamed(context, '/teacher-announcements')),
                DashboardTile(icon: Icons.menu_book, label: 'Update\nSyllabus', iconColor: AppColors.tileIconColors[3],
                  onTap: () => Navigator.pushNamed(context, '/syllabus')),
                DashboardTile(icon: Icons.quiz, label: 'Create\nQuiz', iconColor: AppColors.tileIconColors[5],
                  onTap: () => Navigator.pushNamed(context, '/teacher-quizzes')),
                DashboardTile(icon: Icons.upload_file, label: 'Upload\nE-Book', iconColor: AppColors.tileIconColors[4],
                  onTap: () => Navigator.pushNamed(context, '/ebooks')),
                DashboardTile(icon: Icons.description, label: 'Upload\nPapers', iconColor: AppColors.tileIconColors[6],
                  onTap: () => Navigator.pushNamed(context, '/practice-papers')),
                DashboardTile(icon: Icons.schedule, label: 'My\nTimetable', iconColor: AppColors.tileIconColors[9],
                  onTap: () => Navigator.pushNamed(context, '/timetable')),
                DashboardTile(icon: Icons.groups, label: 'Class\nStudents', iconColor: AppColors.tileIconColors[11],
                  onTap: () => Navigator.pushNamed(context, '/teacher-students')),
                DashboardTile(icon: Icons.person, label: 'My\nProfile', iconColor: AppColors.tileIconColors[0],
                  onTap: () => Navigator.pushNamed(context, '/teacher-profile')),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
