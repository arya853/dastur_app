/// Represents a user in the system with role-based access.
///
/// The [role] field determines which dashboard and permissions
/// the user gets: 'admin', 'teacher', or 'parent'.
class AppUser {
  final String uid;
  final String email;
  final String role; // 'admin', 'teacher', 'parent'
  final String displayName;
  final String? photoUrl;

  AppUser({
    required this.uid,
    required this.email,
    required this.role,
    required this.displayName,
    this.photoUrl,
  });

  /// Create from Firestore document map
  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'] ?? '',
      role: map['role'] ?? 'parent',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
    );
  }

  /// Convert to Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'role': role,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isTeacher => role == 'teacher';
  bool get isParent => role == 'parent';
}
