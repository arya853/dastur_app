import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

// Core
import 'core/app_theme.dart';
import 'core/app_constants.dart';

// Services
import 'services/auth_service.dart';
import 'services/photo_upload_service.dart';
import 'services/notification_service.dart';

// Screens - Auth
import 'screens/auth/login_screen.dart';
import 'screens/auth/auth_wrapper.dart';

// Screens - Parent
import 'screens/parent/parent_dashboard.dart';

// Screens - Teacher
import 'screens/teacher/teacher_dashboard.dart';
import 'screens/teacher/teacher_screens.dart';

// Screens - Admin
import 'screens/admin/admin_dashboard.dart';
import 'screens/admin/admin_screens.dart';

// Screens - Shared (used across roles)
import 'screens/shared/academic_calendar_screen.dart';
import 'screens/shared/announcements_screen.dart';
import 'screens/shared/ptm_screen.dart';
import 'screens/shared/syllabus_screen.dart';
import 'screens/shared/ebooks_screen.dart';
import 'screens/shared/quizzes_screen.dart';
import 'screens/shared/practice_papers_screen.dart';
import 'screens/shared/home_work_screen.dart';
import 'screens/shared/fees_screen.dart';
import 'screens/shared/attendance_screen.dart';
import 'screens/shared/timetable_screen.dart';
import 'screens/shared/profile_screen.dart';
import 'screens/shared/parent_id_card_screen.dart';
import 'screens/shared/notifications_screen.dart';
import 'screens/shared/announcement_detail_screen.dart';
import 'models/announcement.dart';

/// Dastur School Parent Portal
///
/// Entry point for the cross-platform Flutter app.
/// Supports 3 roles: Admin, Teacher, Parent.

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Handle background message
  debugPrint("Handling a background message: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Request Notification Permissions
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // Handle Foreground Messages
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    debugPrint('Got a message whilst in the foreground!');
    if (message.notification != null) {
      debugPrint('Message also contained a notification: \${message.notification}');
    }
  });

  // Lock to portrait mode for consistent UI
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  runApp(const DasturParentPortalApp());
}

class DasturParentPortalApp extends StatelessWidget {
  const DasturParentPortalApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        Provider(create: (_) => PhotoUploadService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
      ],
      child: MaterialApp(
        title: AppConstants.schoolShortName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        // Use AuthWrapper to handle session persistence
        home: const AuthWrapper(),

        // ── Named Routes ──
        routes: {
          // Authentication
          '/login': (_) => const LoginScreen(),

          // Role-specific dashboards
          '/parent-dashboard': (_) => const ParentDashboardScreen(),
          '/teacher-dashboard': (_) => const TeacherDashboardScreen(),
          '/admin-dashboard': (_) => const AdminDashboardScreen(),

          // Shared screens (accessible by multiple roles)
          '/academic-calendar': (_) => const AcademicCalendarScreen(),
          '/announcements': (_) => const AnnouncementsScreen(),
          '/ptm': (_) => const PtmScreen(),
          '/syllabus': (_) => const SyllabusScreen(),
          '/ebooks': (_) => const EbooksScreen(),
          '/pdf-viewer': (_) => const PdfViewerScreen(),
          '/quizzes': (_) => const QuizzesScreen(),
          '/quiz-play': (_) => const QuizPlayScreen(),
          '/practice-papers': (_) => const PracticePapersScreen(),
          '/home-work': (_) => const HomeWorkScreen(),
          '/fees': (_) => const FeesScreen(),
          '/attendance': (_) => const AttendanceScreen(),
          '/timetable': (_) => const TimetableScreen(),
          '/exam-timetable': (_) => const ExamTimetableScreen(),
          '/profile': (_) => const ProfileScreen(),
          '/parent-id-card': (_) => const ParentIdCardScreen(),
          '/notifications': (_) => const NotificationsScreen(),

          // Teacher-specific screens
          '/teacher-mark-attendance': (_) => const MarkAttendanceScreen(),
          '/teacher-announcements': (_) => const TeacherAnnouncementsScreen(),
          '/teacher-students': (_) => const TeacherStudentsScreen(),
          '/teacher-quizzes': (_) => const TeacherQuizzesScreen(),
          '/teacher-profile': (_) => const TeacherProfileScreen(),

          // Admin-specific screens
          '/admin-students': (_) => const AdminStudentsScreen(),
          '/admin-teachers': (_) => const AdminTeachersScreen(),
          '/admin-parents': (_) => const AdminParentsScreen(),
          '/admin-announcements': (_) => const AdminAnnouncementsScreen(),
          '/admin-calendar': (_) => const AdminCalendarScreen(),
          '/admin-timetable': (_) => const AdminTimetableScreen(),
          '/admin-fees': (_) => const AdminFeesScreen(),
          '/admin-exam-timetable': (_) => const AdminExamTimetableScreen(),
          '/admin-reports': (_) => const AdminReportsScreen(),
          '/admin-settings': (_) => const AdminSettingsScreen(),
          '/announcement-detail': (context) {
            final ann = ModalRoute.of(context)!.settings.arguments as Announcement;
            return AnnouncementDetailScreen(announcement: ann);
          },
        },
      ),
    );
  }
}
