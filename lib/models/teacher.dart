/// Represents a teacher with their assigned classes and subjects.
class Teacher {
  final String id;
  final String name;
  final String email;
  final String phone;
  final List<String> assignedClasses; // e.g., ['VIII-A', 'IX-B']
  final List<String> subjects;        // e.g., ['Mathematics', 'Science']
  final String? photoUrl;

  Teacher({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.assignedClasses,
    required this.subjects,
    this.photoUrl,
  });

  factory Teacher.fromMap(Map<String, dynamic> map, String id) {
    return Teacher(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      assignedClasses: List<String>.from(map['assignedClasses'] ?? []),
      subjects: List<String>.from(map['subjects'] ?? []),
      photoUrl: map['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'assignedClasses': assignedClasses,
      'subjects': subjects,
      'photoUrl': photoUrl,
    };
  }
}
