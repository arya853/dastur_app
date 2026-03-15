import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/dashboard_tile.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../../models/student.dart';
import 'package:provider/provider.dart';

import '../../services/notification_service.dart';

/// Parent Dashboard Screen
///
/// Shows a grid of 12 feature tiles and a welcome header.
/// This is the main landing page after a parent logs in.
class ParentDashboardScreen extends StatefulWidget {
  const ParentDashboardScreen({super.key});

  @override
  State<ParentDashboardScreen> createState() => _ParentDashboardScreenState();
}

class _ParentDashboardScreenState extends State<ParentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Auto-subscribe to student's class topic for notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscribeToStudentTopic();
    });
  }

  void _subscribeToStudentTopic() {
    final student = MockDataService.demoStudent;
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    
    // Topic format: class_8_div_A
    final topic = 'class_${student.grade}_div_${student.division}'.toLowerCase();
    notificationService.subscribeToTopic(topic);
    notificationService.subscribeToTopic('school_announcements');
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final student = MockDataService.demoStudent;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── Premium Header with student info ──
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top row: greeting + logout
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Parent: ${authService.currentUser?.displayName ?? "User"}',
                                style: const TextStyle(
                                  color: AppColors.textOnDark,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Student: ${student.name}',
                                style: TextStyle(
                                  color: AppColors.accent.withValues(alpha: 0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const RoleBadge(role: 'parent'),
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: () async {
                                  await authService.logout();
                                  if (context.mounted) {
                                    Navigator.pushReplacementNamed(
                                        context, '/login');
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.logout,
                                      color: AppColors.textOnDark, size: 20),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Student info card
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppConstants.radiusMd),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.12)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor:
                                  AppColors.accent.withValues(alpha: 0.2),
                              child: Text(
                                student.name[0],
                                style: const TextStyle(
                                    color: AppColors.accent,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    student.name,
                                    style: const TextStyle(
                                      color: AppColors.textOnDark,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Class ${student.fullClass} • Roll No. ${student.rollNumber}',
                                    style: TextStyle(
                                      color: AppColors.textOnDark
                                          .withValues(alpha: 0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                AppConstants.academicYear,
                                style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Dashboard Grid Title ──
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Quick Access'),
          ),

          // ── 12-Tile Dashboard Grid ──
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.count(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.95,
              children: [
                DashboardTile(
                  icon: Icons.calendar_month,
                  label: 'Academic\nCalendar',
                  iconColor: AppColors.tileIconColors[0],
                  onTap: () =>
                      Navigator.pushNamed(context, '/academic-calendar'),
                ),
                DashboardTile(
                  icon: Icons.campaign,
                  label: 'Announce-\nments',
                  iconColor: AppColors.tileIconColors[1],
                  onTap: () =>
                      Navigator.pushNamed(context, '/announcements'),
                ),
                DashboardTile(
                  icon: Icons.menu_book,
                  label: 'Syllabus',
                  iconColor: AppColors.tileIconColors[3],
                  onTap: () => Navigator.pushNamed(context, '/syllabus'),
                ),
                DashboardTile(
                  icon: Icons.auto_stories,
                  label: 'E-Books',
                  iconColor: AppColors.tileIconColors[4],
                  onTap: () => Navigator.pushNamed(context, '/ebooks'),
                ),
                DashboardTile(
                  icon: Icons.quiz,
                  label: 'Quizzes',
                  iconColor: AppColors.tileIconColors[5],
                  onTap: () => Navigator.pushNamed(context, '/quizzes'),
                ),
                DashboardTile(
                  icon: Icons.description,
                  label: 'Practice\nPapers',
                  iconColor: AppColors.tileIconColors[6],
                  onTap: () =>
                      Navigator.pushNamed(context, '/practice-papers'),
                ),
                DashboardTile(
                  icon: Icons.account_balance_wallet,
                  label: 'Fees',
                  iconColor: AppColors.tileIconColors[7],
                  onTap: () => Navigator.pushNamed(context, '/fees'),
                ),
                DashboardTile(
                  icon: Icons.fact_check,
                  label: 'Attendance',
                  iconColor: AppColors.tileIconColors[8],
                  onTap: () => Navigator.pushNamed(context, '/attendance'),
                ),
                DashboardTile(
                  icon: Icons.schedule,
                  label: 'Timetable',
                  iconColor: AppColors.tileIconColors[9],
                  onTap: () => Navigator.pushNamed(context, '/timetable'),
                ),
                DashboardTile(
                  icon: Icons.event_note,
                  label: 'Exam\nTimetable',
                  iconColor: AppColors.tileIconColors[10],
                  onTap: () =>
                      Navigator.pushNamed(context, '/exam-timetable'),
                ),
                DashboardTile(
                  icon: Icons.person,
                  label: 'Profile',
                  iconColor: AppColors.tileIconColors[11],
                  onTap: () => Navigator.pushNamed(context, '/profile'),
                ),
              ],
            ),
          ),

          // ── Recent Announcements Preview ──
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Recent Announcements'),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final ann = MockDataService.announcements[index];
                return Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusMd),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _getAnnouncementColor(ann.type)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            _getAnnouncementIcon(ann.type),
                            color: _getAnnouncementColor(ann.type),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                ann.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${ann.date.day}/${ann.date.month}/${ann.date.year}',
                                style: const TextStyle(
                                  color: AppColors.textSubtle,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        StatusChip(
                          label: ann.type.toUpperCase(),
                          color: _getAnnouncementColor(ann.type),
                        ),
                      ],
                    ),
                  ),
                );
              },
              childCount: 3, // Show only first 3
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Color _getAnnouncementColor(String type) {
    switch (type) {
      case 'alert':
        return AppColors.error;
      case 'event':
        return AppColors.info;
      case 'circular':
        return AppColors.accent;
      default:
        return AppColors.success;
    }
  }

  IconData _getAnnouncementIcon(String type) {
    switch (type) {
      case 'alert':
        return Icons.warning_amber;
      case 'event':
        return Icons.celebration;
      case 'circular':
        return Icons.mail;
      default:
        return Icons.info_outline;
    }
  }
}
