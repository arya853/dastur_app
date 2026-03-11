/// Represents a student enrolled in the school.
class Student {
  final String id;
  final String name;
  final String className; // e.g., 'VIII'
  final String section;   // e.g., 'A'
  final String rollNumber;
  final String email;
  final String? photoUrl;
  final String parentId;  // linked parent's ID

  Student({
    required this.id,
    required this.name,
    required this.className,
    required this.section,
    required this.rollNumber,
    required this.email,
    this.photoUrl,
    required this.parentId,
  });

  factory Student.fromMap(Map<String, dynamic> map, String id) {
    return Student(
      id: id,
      name: map['name'] ?? '',
      className: map['className'] ?? '',
      section: map['section'] ?? '',
      rollNumber: map['rollNumber'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      parentId: map['parentId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'className': className,
      'section': section,
      'rollNumber': rollNumber,
      'email': email,
      'photoUrl': photoUrl,
      'parentId': parentId,
    };
  }

  /// Full class identifier like "VIII - A"
  String get fullClass => '$className - $section';
}
