import 'package:flutter/material.dart';
import '../models/app_user.dart';
import '../core/app_constants.dart';
import 'mock_data_service.dart';

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
  bool _isLoading = false;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isLoggedIn => _currentUser != null;

  AuthService() {
    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        // Only clear if we aren't using the initial bypass
        if (_currentUser?.uid != 'initial-admin-bypass') {
          _currentUser = null;
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
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        _currentUser = AppUser.fromMap(
           doc.data() as Map<String, dynamic>,
           doc.id,
        );
      }
    } catch (e) {
      debugPrint("Error fetching user profile: \$e");
      debugPrint("Error fetching user profile: $e");
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password, {String? requiredRole}) async {
    _isLoading = true;
    notifyListeners();

    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      
      await _fetchUserProfile(credential.user!.uid);
      
      if (_currentUser == null) {
        // If Auth succeeded but Firestore profile is missing
        _currentUser = AppUser(
          uid: credential.user!.uid,
          email: email,
          displayName: 'User',
          role: requiredRole ?? 'parent',
        );
      }

      // ── Role Validation ──
      if (requiredRole != null && _currentUser!.role != requiredRole) {
        await _auth.signOut();
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
        throw 'You are not authorized to access this portal.';
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint('FirebaseAuth Error: ${e.message}');
      
      // ── Initial Setup Bypass ──
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
      
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      debugPrint('Login Error: $e');
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
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
    notifyListeners();
  }
}
