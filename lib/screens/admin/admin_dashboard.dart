import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/dashboard_tile.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/auth_service.dart';
import '../../services/mock_data_service.dart';
import '../../services/data_seeder_service.dart';

import '../../widgets/app_drawer.dart';

/// Admin Dashboard Screen
///
/// School-wide statistics, quick management actions,
/// and overview of key metrics.
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      endDrawer: const AppDrawer(),
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
                    Text('Admin Panel', style: TextStyle(color: AppColors.textOnDark.withValues(alpha: 0.7), fontSize: 14)),
                    Text(authService.currentUser?.displayName ?? 'Administrator', style: const TextStyle(color: AppColors.textOnDark, fontSize: 20, fontWeight: FontWeight.w700)),
                  ]),
                  Row(children: [
                    const RoleBadge(role: 'admin'),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.menu, color: AppColors.textOnDark, size: 24),
                      ),
                    ),
                  ]),
                ]),
                const SizedBox(height: 16),
                // Stats row
                Row(children: [
                  _statCard('Students', '${MockDataService.allStudents.length}', Icons.school, AppColors.accent),
                  const SizedBox(width: 10),
                  _statCard('Teachers', '${MockDataService.allTeachers.length}', Icons.person, AppColors.roleTeacher),
                  const SizedBox(width: 10),
                  _statCard('Classes', '6', Icons.class_, AppColors.success),
                ]),
              ]),
            )),
          )),
          // Management Grid
          const SliverToBoxAdapter(child: SectionHeader(title: 'Management')),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverGrid.count(
              crossAxisCount: 3, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.95,
              children: [
                DashboardTile(icon: Icons.people, label: 'Manage\nStudents', iconColor: AppColors.tileIconColors[0],
                  onTap: () => Navigator.pushNamed(context, '/admin-students')),
                DashboardTile(icon: Icons.person, label: 'Manage\nTeachers', iconColor: AppColors.tileIconColors[5],
                  onTap: () => Navigator.pushNamed(context, '/admin-teachers')),
                DashboardTile(icon: Icons.family_restroom, label: 'Manage\nParents', iconColor: AppColors.tileIconColors[3],
                  onTap: () => Navigator.pushNamed(context, '/admin-parents')),
                DashboardTile(icon: Icons.campaign, label: 'Announce-\nments', iconColor: AppColors.tileIconColors[1],
                  onTap: () => Navigator.pushNamed(context, '/admin-announcements')),
                DashboardTile(icon: Icons.calendar_month, label: 'Calendar\nEvents', iconColor: AppColors.tileIconColors[2],
                  onTap: () => Navigator.pushNamed(context, '/admin-calendar')),
                DashboardTile(icon: Icons.schedule, label: 'Manage\nTimetable', iconColor: AppColors.tileIconColors[9],
                  onTap: () => Navigator.pushNamed(context, '/admin-timetable')),
                DashboardTile(icon: Icons.account_balance_wallet, label: 'Manage\nFees', iconColor: AppColors.tileIconColors[7],
                  onTap: () => Navigator.pushNamed(context, '/admin-fees')),
                DashboardTile(icon: Icons.event_note, label: 'Exam\nSchedule', iconColor: AppColors.tileIconColors[10],
                  onTap: () => Navigator.pushNamed(context, '/admin-exam-timetable')),
                DashboardTile(icon: Icons.bar_chart, label: 'Reports', iconColor: AppColors.tileIconColors[8],
                  onTap: () => Navigator.pushNamed(context, '/admin-reports')),
                DashboardTile(icon: Icons.auto_stories, label: 'Manage\nE-Books', iconColor: AppColors.tileIconColors[4],
                  onTap: () => Navigator.pushNamed(context, '/ebooks')),
                DashboardTile(icon: Icons.settings, label: 'Settings', iconColor: AppColors.tileIconColors[11],
                  onTap: () => Navigator.pushNamed(context, '/admin-settings')),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: () async {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Starting database seed...')));
                  try {
                    await DataSeederService().seedDatabase();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Mock data uploaded to Firebase successfully!')));
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to seed database: \$e')));
                    }
                  }
                },
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Seed Firebase Database (Admin Only)'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  Widget _statCard(String label, String value, IconData icon, Color color) {
    return Expanded(child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(AppConstants.radiusMd)),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 20)),
        Text(label, style: const TextStyle(color: AppColors.textOnDarkMuted, fontSize: 11)),
      ]),
    ));
  }
}
