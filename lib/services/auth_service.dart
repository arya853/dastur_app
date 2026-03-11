import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../core/app_constants.dart';
import 'mock_data_service.dart';

/// Authentication Service
///
/// Handles login/logout and role detection. Currently uses mock data
/// for immediate testing. Replace with Firebase Auth for production.
class AuthService extends ChangeNotifier {
  AppUser? _currentUser;
  bool _isLoading = false;

  /// Currently logged-in user (null if not authenticated)
  AppUser? get currentUser => _currentUser;

  /// Whether an auth operation is in progress
  bool get isLoading => _isLoading;

  /// Whether a user is currently logged in
  bool get isLoggedIn => _currentUser != null;

  /// Attempt to log in with email and password.
  ///
  /// In demo mode, checks against the 3 predefined accounts.
  /// Returns true on success, false on failure.
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // ── Demo Authentication ──
      // In production, replace with Firebase Auth:
      // final credential = await FirebaseAuth.instance
      //     .signInWithEmailAndPassword(email: email, password: password);
      // Then fetch user role from Firestore users collection.

      if (password != AppConstants.demoPassword) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      if (email == AppConstants.demoAdminEmail) {
        _currentUser = MockDataService.adminUser;
      } else if (email == AppConstants.demoTeacherEmail) {
        _currentUser = MockDataService.teacherUser;
      } else if (email == AppConstants.demoParentEmail) {
        _currentUser = MockDataService.parentUser;
      } else {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Log out the current user
  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }
}
