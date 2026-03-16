import 'package:flutter/material.dart';
import '../models/app_user.dart';

/// Authentication Service
///
/// Handles login/logout and role detection. Currently uses mock data
/// for immediate testing. Replace with Firebase Auth for production.
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AppUser? _currentUser;
  Map<String, dynamic>? _studentProfile;
  bool _isLoading = false;

  AppUser? get currentUser => _currentUser;
  Map<String, dynamic>? get studentProfile => _studentProfile;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  AuthService() {
    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        // Only clear if we aren't using the initial bypass
        if (_currentUser?.uid != null && !_currentUser!.uid.startsWith('initial-admin-bypass') && !_currentUser!.uid.startsWith('manual-')) {
          _currentUser = null;
          _studentProfile = null;
          notifyListeners();
        }
      } else {
        await _fetchUserProfile(user.uid);
      }
    });
  }

  Future<void> _fetchUserProfile(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Try fetching from generic users collection
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = AppUser.fromMap(
           doc.data() as Map<String, dynamic>,
           doc.id,
        );
        
        // If it's a parent/student, try to get their student record
        if (_currentUser!.role == 'parent') {
          final grNo = _currentUser!.email.split('@').first;
          _studentProfile = await _findStudentByGr(grNo);
        }
      } else {
        // 2. Try fetching from teachers collection if not in users
        DocumentSnapshot teacherDoc = await _db.collection('teachers').doc(uid).get();
        if (teacherDoc.exists) {
          final data = teacherDoc.data() as Map<String, dynamic>;
          _currentUser = AppUser(
            uid: uid,
            email: data['email'] ?? '',
            role: 'teacher',
            displayName: data['name'] ?? 'Teacher',
          );
        }
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password, {String? requiredRole}) async {
    _isLoading = true;
    _studentProfile = null;
    notifyListeners();

    try {
      // ── Strategy 1: Standard Firebase Auth ──
      UserCredential? credential;
      try {
        credential = await _auth.signInWithEmailAndPassword(
          email: email, 
          password: password
        );
        await _fetchUserProfile(credential.user!.uid);
      } on FirebaseAuthException catch (e) {
        // If it's a parent, we might be using the manual push data fallback
        if (requiredRole == 'parent' && (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password')) {
          // Fallback to searching the 'students' collection
          final grNo = email.contains('@') ? email.split('@').first : email;
          final studentData = await _findStudentByGr(grNo);
          
          // Match logic: password must be 'dastur123' OR the GR Number itself
          if (studentData != null && (password == 'dastur123' || password == grNo)) {
            _studentProfile = studentData;
            _currentUser = AppUser(
              uid: 'manual-${studentData['GR NO.'] ?? studentData['grNo']}',
              email: studentData['EMAIL'] ?? studentData['email'] ?? '$grNo@dastur.org',
              displayName: studentData['NAME'] ?? studentData['name'] ?? 'Parent',
              role: 'parent',
            );
            _isLoading = false;
            notifyListeners();
            return true;
          }
        }
        
        // ── Initial Setup Bypass (Admin Only) ──
        if ((e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password') && 
            email == 'admin1@dastur.org' && password == 'admin123') {
          
          if (requiredRole != null && requiredRole != 'admin') {
            _isLoading = false;
            notifyListeners();
            throw 'You are not authorized to access this portal.';
          }

          _currentUser = AppUser(
            uid: 'initial-admin-bypass',
            email: email,
            displayName: 'Setup Administrator',
            role: 'admin',
          );
          _isLoading = false;
          notifyListeners();
          return true;
        }

        debugPrint('FirebaseAuth Error: ${e.message}');
        _isLoading = false;
        notifyListeners();
        return false;
      }
      
      // If Auth succeeded but Firestore profile is still missing, search in teachers/students
      if (_currentUser == null) {
         if (requiredRole == 'teacher') {
            DocumentSnapshot teacherDoc = await _db.collection('teachers').doc(credential.user!.uid).get();
            if (teacherDoc.exists) {
               final data = teacherDoc.data() as Map<String, dynamic>;
               _currentUser = AppUser(
                  uid: credential.user!.uid,
                  email: data['email'] ?? email,
                  role: 'teacher',
                  displayName: data['name'] ?? 'Teacher',
               );
            }
         } else if (requiredRole == 'parent') {
            final grNo = email.contains('@') ? email.split('@').first : email;
             _studentProfile = await _findStudentByGr(grNo);
             if (_studentProfile != null) {
                _currentUser = AppUser(
                  uid: credential.user!.uid,
                  email: email,
                  role: 'parent',
                  displayName: _studentProfile!['NAME'] ?? _studentProfile!['name'] ?? 'Parent',
                );
             }
         }
      }

      // Default fallback
      _currentUser ??= AppUser(
        uid: credential.user!.uid,
        email: email,
        displayName: 'User',
        role: requiredRole ?? 'parent',
      );

      // ── Role Validation ──
      if (requiredRole != null && _currentUser!.role != requiredRole) {
        await _auth.signOut();
        _currentUser = null;
        _studentProfile = null;
        _isLoading = false;
        notifyListeners();
        throw 'You are not authorized to access this portal.';
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Login Error: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Searches the 'students' collection for a GR Number across all grades.
  Future<Map<String, dynamic>?> _findStudentByGr(String grNo) async {
    // 1. Try global student collection first (if it exists)
    try {
       QuerySnapshot globalSearch = await _db.collection('students').where('grNo', isEqualTo: grNo).get();
       if (globalSearch.docs.isNotEmpty) return globalSearch.docs.first.data() as Map<String, dynamic>;
    } catch (e) { /* Ignore */ }

    // 2. Try grade-level search (as used in the manual push script)
    final grades = ['grade5', 'grade6', 'grade7', 'grade8'];
    for (final grade in grades) {
      try {
        DocumentSnapshot doc = await _db
            .collection('students')
            .doc(grade)
            .collection('list')
            .doc(grNo)
            .get();
        
        if (doc.exists) {
          return doc.data() as Map<String, dynamic>;
        }
      } catch (e) {
        debugPrint("Error searching in $grade: $e");
      }
    }
    return null;
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      debugPrint('Password Reset Error: $e');
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    _studentProfile = null;
    notifyListeners();
  }
}
