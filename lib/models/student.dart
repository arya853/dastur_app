/// Represents a student enrolled in the school.
class Student {
  final String id;
  final String name;
  final String className; // e.g., 'VIII'
  final String division;  // A, B, C, D
  final String rollNumber;
  final String email;
  final String? photoUrl;
  final String grNo;      // General Register Number (Unique ID)
  final Map<String, dynamic>? parentDetails;

  Student({
    required this.id,
    required this.name,
    required this.className,
    required this.division,
    required this.rollNumber,
    required this.email,
    this.photoUrl,
    required this.grNo,
    this.parentDetails,
  });

  factory Student.fromMap(Map<String, dynamic> map, String id) {
    return Student(
      id: id,
      name: map['name'] ?? '',
      className: map['className'] ?? '',
      division: map['division'] ?? map['section'] ?? '', // Handle migration from 'section'
      rollNumber: map['rollNumber'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      grNo: map['grNo'] ?? '',
      parentDetails: map['parentDetails'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'className': className,
      'division': division,
      'rollNumber': rollNumber,
      'email': email,
      'photoUrl': photoUrl,
      'grNo': grNo,
      'parentDetails': parentDetails,
    };
  }

  /// Full class identifier like "5 - A"
  String get fullClass => '$className - $division';

  /// Alias for className to match UI usage
  String get grade => className;
}
