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
  late PageController _pageController;
  Timer? _carouselTimer;
  int _currentPage = 0;
  int _announcementCount = 5; // Show top 5 recent announcements
  int _actualCount = 0; // Actual filtered count for the timer

  @override
  void initState() {
    super.initState();
    // Auto-subscribe to student's class topic for notifications
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscribeToStudentTopic();
    });
    
    _pageController = PageController(initialPage: 0);
    _startCarouselTimer();
  }

  void _startCarouselTimer() {
    _carouselTimer?.cancel();
    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients && _actualCount > 0) {
        _currentPage = (_currentPage + 1) % _actualCount;
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _subscribeToStudentTopic() {
    // Note: Notification listening is now handled by StreamBuilders in
    // NotificationScreen and NotificationBadge.
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
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
            child: _buildAnnouncementCarousel(),
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

  Widget _buildAnnouncementCarousel() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final userRole = authService.currentUser?.role ?? 'parent';
    
    // Extract logical user class for filtering
    String? userClass;
    if (userRole == 'parent' && authService.studentProfile != null) {
      final cInfo = authService.studentProfile!['CLASS'] ?? authService.studentProfile!['className'];
      if (cInfo != null) userClass = cInfo.toString();
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('announcements')
          .orderBy('date', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(height: 90, child: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasError) {
          return SizedBox(height: 90, child: Center(child: Text("Error: ${snapshot.error}")));
        }

        final docs = snapshot.data?.docs ?? [];
        
        final List<Announcement> allVisible = [];
        for (var doc in docs) {
          final data = doc.data() as Map<String, dynamic>;
          final ann = Announcement.fromMap(data, doc.id);
          
          if (!ann.isActive) continue; // Filter inactive announcements manually
          if (ann.targetRole != 'all' && ann.targetRole != '${userRole}s') continue;
          if (ann.targetClass != null && ann.targetClass != userClass) continue;

          allVisible.add(ann);
        }

        final announcements = allVisible.take(_announcementCount).toList();
        _actualCount = announcements.length; // Sync actual count for the timer

        if (announcements.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusMd),
              border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.school, color: AppColors.primary),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome to Dastur School', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                      Text('Stay tuned for upcoming announcements.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Adjust current page if announcements shrink dynamically
        if (_currentPage >= announcements.length) {
          _currentPage = 0;
        }

        return Column(
          children: [
            SizedBox(
              height: 90,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: announcements.length,
                itemBuilder: (context, index) {
                  final ann = announcements[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: InkWell(
                      onTap: () => Navigator.pushNamed(
                        context, 
                        '/announcement-detail', 
                        arguments: ann,
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: _getAnnouncementColor(ann.type).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getAnnouncementIcon(ann.type),
                                color: _getAnnouncementColor(ann.type),
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    ann.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${ann.date.day}/${ann.date.month}/${ann.date.year}',
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
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
                    ),
                  );
                },
              ),
            ),
            // Indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                announcements.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: _currentPage == index ? 12 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(3),
                    color: _currentPage == index 
                        ? AppColors.primary 
                        : AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        );
      }
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
