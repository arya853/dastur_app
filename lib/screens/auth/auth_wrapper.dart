import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../auth/login_screen.dart';
import '../parent/parent_dashboard.dart';
import '../teacher/teacher_dashboard.dart';
import '../admin/admin_dashboard.dart';
import '../../core/app_colors.dart';

/// AuthWrapper
///
/// Decides whether to show the LoginScreen or the appropriate Dashboard
/// based on the user's authentication state and role.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, _) {
        // 1. Loading State (App Initializing)
        if (authService.isInitializing) {
          return const Scaffold(
            backgroundColor: AppColors.primary,
            body: Center(
              child: CircularProgressIndicator(
                color: Colors.white,
              ),
            ),
          );
        }

        // 2. Unauthenticated State
        if (!authService.isLoggedIn) {
          return const LoginScreen();
        }

        // 3. Authenticated State - Route by role
        final user = authService.currentUser!;
        
        switch (user.role) {
          case 'admin':
            return const AdminDashboardScreen();
          case 'teacher':
            return const TeacherDashboardScreen();
          case 'parent':
          default:
            return const ParentDashboardScreen();
        }
      },
    );
  }
}
