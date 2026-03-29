import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/dashboard_tile.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../../models/announcement.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/announcement_carousel.dart';

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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Auto-subscribe to student's class topic for notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscribeToStudentTopic();
    });
  }

  void _subscribeToStudentTopic() {
    // Note: Notification listening is now handled by StreamBuilders in
    // NotificationScreen and NotificationBadge.
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final userRole = authService.currentUser?.role ?? 'parent';
    final studentData = authService.studentProfile;
    final studentDisplayName = studentData?['name'] ?? studentData?['NAME'] ?? 'Student';
    final studentClass = studentData?['className'] ?? studentData?['CLASS'] ?? '?';
    final studentDiv = studentData?['division'] ?? studentData?['DIV'] ?? '?';
    final studentRoll = studentData?['rollNumber'] ?? studentData?['ROLL NO.'] ?? '?';

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      endDrawer: const AppDrawer(),
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
                      // Top row: greeting + menu
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Parent: ${authService.currentUser?.displayName ?? "User"}',
                                  style: const TextStyle(
                                    color: AppColors.textOnDark,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Student: $studentDisplayName',
                                  style: TextStyle(
                                    color: AppColors.accent.withValues(alpha: 0.9),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Row(
                            children: [
                              const NotificationBadge(),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    Icons.menu,
                                    color: AppColors.textOnDark,
                                    size: 24,
                                  ),
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
                                studentDisplayName.isNotEmpty ? studentDisplayName[0] : 'S',
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
                                    studentDisplayName,
                                    style: const TextStyle(
                                      color: AppColors.textOnDark,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Class $studentClass - $studentDiv • Roll No. $studentRoll',
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

          // ── Announcement Carousel ──
          SliverToBoxAdapter(
            child: AnnouncementCarousel(
              userRole: userRole,
              userClass: studentData?['CLASS']?.toString() ?? studentData?['className']?.toString(),
            ),
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
                DashboardTile(
                  icon: Icons.checklist_rtl_rounded,
                  label: 'Exam\nSyllabus',
                  iconColor: AppColors.tileIconColors[6],
                  onTap: () => Navigator.pushNamed(context, '/parent-exam-syllabus'),
                ),
                DashboardTile(
                  icon: Icons.book_rounded,
                  label: 'Home Work',
                  iconColor: AppColors.tileIconColors[5],
                  onTap: () => Navigator.pushNamed(context, '/home-work'),
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }
}
