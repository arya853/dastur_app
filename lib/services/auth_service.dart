import 'package:flutter/material.dart';
import '../models/app_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'fcm_service.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  AppUser? _currentUser;
  Map<String, dynamic>? _studentProfile;
  Map<String, dynamic>? _teacherProfile;
  bool _isLoading = false;
  bool _isInitializing = true;

  AppUser? get currentUser => _currentUser;
  Map<String, dynamic>? get studentProfile => _studentProfile;
  Map<String, dynamic>? get teacherProfile => _teacherProfile;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  bool get isLoggedIn => _currentUser != null;

  AuthService() {
    _init();
  }

  Future<void> _init() async {
    // 1. Try to load internal cached session first (handles manual/bypass logins)
    await _loadSession();
    if (_currentUser != null) {
      _updateFcmToken();
    }

    // 2. Listen to Firebase Auth State Changes
    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        // If Firebase says no user, but we have a 'manual' session, don't clear it.
        // Firebase Auth only tracks Strategy 1 logins.
        if (_currentUser != null && (_currentUser!.uid.startsWith('manual-') || _currentUser!.uid.startsWith('initial-')) ) {
           _isInitializing = false;
           notifyListeners();
           return;
        }

        // Otherwise clear session
        _currentUser = null;
        _studentProfile = null;
        await _clearSession();
        _isInitializing = false;
        notifyListeners();
      } else {
        // Firebase user is present, ensure we have their profile
        if (_currentUser == null || _currentUser!.uid != user.uid) {
          await _fetchUserProfile(user.uid);
          await _saveSession();
        }
        _isInitializing = false;
        notifyListeners();
      }
    });

    // ── Initial Check ──
    final User? user = _auth.currentUser;
    if (user != null) {
      if (_currentUser == null || _currentUser!.uid != user.uid) {
        await _fetchUserProfile(user.uid);
        await _saveSession();
      }
      _isInitializing = false;
      notifyListeners();
    } else {
       // Give it a tiny bit of time for authStateChanges or _loadSession to settle
       Future.delayed(const Duration(milliseconds: 500), () {
         if (_isInitializing) {
           _isInitializing = false;
           notifyListeners();
         }
       });
    }
  }

  Future<void> _fetchUserProfile(String uid) async {
    _isLoading = true;
    notifyListeners();

    try {
      // 1. Search in users
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = AppUser.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      } else {
      // 1.5 Search in admin collection (by email)
      final email = _auth.currentUser?.email;
      if (email != null && _currentUser == null) {
        final adminDoc = await _db.collection('admin').doc(email.toLowerCase()).get();
        if (adminDoc.exists) {
          final data = adminDoc.data() as Map<String, dynamic>;
          _currentUser = AppUser(
            uid: uid,
            email: email,
            role: 'admin',
            displayName: data['NAME'] ?? data['name'] ?? 'Administrator',
          );
        }
      }

      // 2. Search in teachers (ID is now the email)
      if (_currentUser == null) {
        DocumentSnapshot? teacherDoc;
        
        if (email != null) {
          final docRef = _db.collection('teachers').doc(email.toLowerCase());
          final snap = await docRef.get();
          if (snap.exists) {
            teacherDoc = snap;
          } else {
            // Fallback for UID-based doc name
            final query = await _db.collection('teachers').where('uid', isEqualTo: uid).get();
            if (query.docs.isNotEmpty) teacherDoc = query.docs.first;
          }

          if (teacherDoc != null && teacherDoc.exists) {
            _teacherProfile = teacherDoc.data() as Map<String, dynamic>;
            final data = _teacherProfile!;
            
            // Link UID if not present
            if (data['uid'] == null) {
              await teacherDoc.reference.update({'uid': uid});
              _teacherProfile!['uid'] = uid;
            }

            _currentUser = AppUser(
              uid: uid,
              email: data['email'] ?? email,
              role: 'teacher',
              displayName: data['NAME'] ?? data['name'] ?? 'Teacher',
            );
          } else {
            // 3. Fallback: Search in students (Parent case)
            if (email.contains('@dastur.org')) {
               final grNo = email.split('@').first;
               _studentProfile = await _findStudentByGr(grNo);
               if (_studentProfile != null) {
                  final pName = _studentProfile!["MOTHER'S NAME"] ??
                               _studentProfile!["Mother's NAME"] ??
                               _studentProfile!["Mother's Name"] ??
                               _studentProfile!["MOTHER NAME"] ??
                               _studentProfile!["Father's NAME"] ??
                               _studentProfile!["FATHER'S NAME"] ??
                               _studentProfile!["Father's Name"] ??
                               _studentProfile!["FATHER NAME"] ??
                               _studentProfile!['Parent 1'] ?? 
                               'Parent';
                               
                  _currentUser = AppUser(
                    uid: uid,
                    email: email,
                    role: 'parent',
                    displayName: pName,
                  );
               }
            }
          }
        }
      }
    }

      // Final fallback if logged in but no profile found anywhere
      if (_currentUser == null && _auth.currentUser != null) {
        final email = _auth.currentUser?.email ?? '';
        final isAdmin = email == 'admin1@dastur.org' || email == 'admin@dastur.org';
        _currentUser = AppUser(
          uid: uid,
          email: email,
          displayName: isAdmin ? 'Administrator' : 'User',
          role: isAdmin ? 'admin' : 'parent',
        );
      }
      
      // Load student data if parent (ensure we have it even if direct fetch above failed)
      if (_currentUser?.role == 'parent' && _studentProfile == null) {
        final grNo = _currentUser!.email.split('@').first;
        _studentProfile = await _findStudentByGr(grNo);
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
    _teacherProfile = null;
    notifyListeners();

    try {
      // ── Strategy 1: Standard Firebase Auth ──
      try {
        UserCredential credential = await _auth.signInWithEmailAndPassword(email: email, password: password);
        await _fetchUserProfile(credential.user!.uid);
      } on FirebaseAuthException catch (e) {
        // ── Strategy 2: Student/Parent Manual Fallback ──
        if (requiredRole == 'parent' && (e.code == 'user-not-found' || e.code == 'invalid-credential' || e.code == 'wrong-password')) {
          final grNo = email.contains('@') ? email.split('@').first : email;
          final studentData = await _findStudentByGr(grNo);
          
          if (studentData != null && (password == 'dastur123' || password == grNo)) {
             _studentProfile = studentData;
            // Priority: Mother's Name, Father's Name, Parent 1/2, parentName, etc.
            final pName = studentData["MOTHER'S NAME"] ??
                         studentData["Mother's NAME"] ??
                         studentData["Mother's Name"] ??
                         studentData["MOTHER NAME"] ??
                         studentData["Father's NAME"] ??
                         studentData["FATHER'S NAME"] ??
                         studentData["Father's Name"] ??
                         studentData["FATHER NAME"] ??
                         studentData['Parent 1'] ?? 
                         studentData['parent 1'] ??
                         studentData['PARENT 1 NAME'] ??
                         studentData['parent 2 name'] ??
                         studentData['Parent 2 Name'] ??
                         studentData['PARENT 2 NAME'] ??
                         studentData['parentName'] ?? 
                         studentData['parentDetails']?['name'] ?? 
                         studentData['PARENT DETAILS']?['NAME'] ?? 
                         'Parent';
                         
            _currentUser = AppUser(
              uid: 'manual-${studentData['GR NO.'] ?? studentData['grNo']}',
              email: studentData['EMAIL'] ?? studentData['email'] ?? '$grNo@dastur.org',
              displayName: pName,
              role: 'parent',
            );
            await _saveSession();
            await _updateFcmToken(); // Ensure token is requested and saved on manual login
            _isLoading = false;
            notifyListeners();
            return true;
          }
        }
        
        // ── Strategy 3: Setup Bypass (Admin Only) ──
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
          await _saveSession();
          _isLoading = false;
          notifyListeners();
          return true;
        }

        _isLoading = false;
        notifyListeners();
        
        // Map common Firebase errors to user-friendly messages
        String fieldLabel = requiredRole == 'parent' ? 'GR number' : 'email';
        String msg = 'Invalid $fieldLabel or password.';
        if (e.code == 'user-disabled') msg = 'This account has been disabled.';
        if (e.code == 'too-many-requests') msg = 'Too many failed attempts. Try again later.';
        if (e.code == 'network-request-failed') msg = 'Network error. Please check your connection.';
        
        throw msg;
      }
      
      // After Strategy 1 success, check role authorization
      if (requiredRole != null && _currentUser!.role != requiredRole) {
        await logout();
        throw 'You are not authorized to access this portal.';
      }

      await _saveSession();
      await _updateFcmToken();
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> _updateFcmToken() async {
    try {
      final fcmService = FcmService();
      final token = await fcmService.getToken();
      if (token == null || _currentUser == null) return;

      if (_currentUser!.role == 'teacher') {
        await _db.collection('teachers').doc(_currentUser!.email.toLowerCase()).update({
          'fcmToken': token,
        }).catchError((_) async {
          // Fallback if doc name isn't email
          final q = await _db.collection('teachers').where('uid', isEqualTo: _currentUser!.uid).get();
          if (q.docs.isNotEmpty) await q.docs.first.reference.update({'fcmToken': token});
        });
      } else if (_currentUser!.role == 'parent' && _studentProfile != null) {
        // Find which grade collection the student is in
        final grades = ['grade5', 'grade6', 'grade7', 'grade8'];
        final grNo = _studentProfile!['GR NO.'] ?? _studentProfile!['grNo'] ?? _currentUser!.email.split('@').first;
        for (final grade in grades) {
          final docRef = _db.collection('students').doc(grade).collection('DIV_A').doc(grNo);
          final snap = await docRef.get();
          if (snap.exists) {
            await docRef.set({'fcmToken': token}, SetOptions(merge: true));
            break;
          }
        }
      }
    } catch (e) {
      debugPrint("Error updating FCM token: $e");
    }
  }

  // ── Session Persistence (SharedPreferences) ──

  Future<void> _saveSession() async {
    if (_currentUser == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_session', json.encode(_currentUser!.toMap()..['uid'] = _currentUser!.uid));
      if (_studentProfile != null) {
        await prefs.setString('student_profile', json.encode(_studentProfile));
      }
      if (_teacherProfile != null) {
        await prefs.setString('teacher_profile', json.encode(_teacherProfile));
      }
    } catch (e) {
      debugPrint("Error saving session: $e");
    }
  }

  Future<void> _loadSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionStr = prefs.getString('user_session');
      if (sessionStr != null) {
        final data = json.decode(sessionStr);
        _currentUser = AppUser.fromMap(data, data['uid']);
        
        final profileStr = prefs.getString('student_profile');
        if (profileStr != null) {
          _studentProfile = json.decode(profileStr);
        }
        final teacherProfileStr = prefs.getString('teacher_profile');
        if (teacherProfileStr != null) {
          _teacherProfile = json.decode(teacherProfileStr);
        }
      }
    } catch (e) {
      debugPrint("Error loading session: $e");
    }
  }

  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_session');
    await prefs.remove('student_profile');
    await prefs.remove('teacher_profile');
  }

  // ── Helpers ──

  Future<Map<String, dynamic>?> _findStudentByGr(String grNo) async {
     try {
       QuerySnapshot globalSearch = await _db.collection('students').where('GR NO.', isEqualTo: grNo).get();
       if (globalSearch.docs.isNotEmpty) return globalSearch.docs.first.data() as Map<String, dynamic>;
    } catch (e) {
      debugPrint("Search error in students collection: $e");
    }

    final grades = ['grade5', 'grade6', 'grade7', 'grade8'];
    for (final grade in grades) {
      try {
        DocumentSnapshot doc = await _db.collection('students').doc(grade).collection('DIV_A').doc(grNo).get();
        if (doc.exists) return doc.data() as Map<String, dynamic>;
      } catch (e) {
        debugPrint("Search error in grade collection $grade: $e");
      }
    }
    return null;
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    _studentProfile = null;
    _teacherProfile = null;
    await _clearSession();
  }
}
