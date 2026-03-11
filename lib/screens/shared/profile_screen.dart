import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/mock_data_service.dart';

/// Student Profile Screen – shows student and parent information.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final student = MockDataService.demoStudent;
    final parent = MockDataService.demoParent;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Student Profile', showBackButton: true),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Student photo and name card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppConstants.radiusXl),
              ),
              child: Column(children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: AppColors.accent.withValues(alpha: 0.2),
                  child: Text(student.name[0], style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: AppColors.accent)),
                ),
                const SizedBox(height: 12),
                Text(student.name, style: const TextStyle(color: AppColors.textOnDark, fontSize: 22, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text('Class ${student.fullClass}', style: const TextStyle(color: AppColors.accent, fontSize: 14, fontWeight: FontWeight.w500)),
              ]),
            ),
            const SizedBox(height: 16),
            // Student details
            _infoCard('Student Information', [
              _infoRow(Icons.badge, 'Roll Number', student.rollNumber),
              _infoRow(Icons.class_, 'Class & Section', student.fullClass),
              _infoRow(Icons.email, 'Email', student.email),
              _infoRow(Icons.school, 'Academic Year', AppConstants.academicYear),
            ]),
            const SizedBox(height: 12),
            // Parent details
            _infoCard('Parent Information', [
              _infoRow(Icons.person, 'Parent Name', parent.name),
              _infoRow(Icons.phone, 'Contact', parent.phone),
              _infoRow(Icons.email, 'Email', parent.email),
              _infoRow(Icons.badge, 'Parent ID', parent.parentId),
            ]),
            const SizedBox(height: 16),
            // Virtual ID Card button
            SizedBox(
              width: double.infinity, height: 52,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pushNamed(context, '/parent-id-card'),
                icon: const Icon(Icons.credit_card),
                label: const Text('View Virtual Parent ID Card'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _infoCard(String title, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusLg),
        boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.primary)),
        const SizedBox(height: 12),
        ...children,
      ]),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Icon(icon, size: 18, color: AppColors.accent),
        const SizedBox(width: 10),
        Text('$label: ', style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.right)),
      ]),
    );
  }
}
