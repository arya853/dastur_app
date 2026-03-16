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
      name: map['name'] ?? map['NAME'] ?? '',
      className: map['className'] ?? map['CLASS'] ?? '',
      division: map['division'] ?? map['DIV'] ?? map['section'] ?? '', 
      rollNumber: (map['rollNumber'] ?? map['ROLL NO.'] ?? '').toString(),
      email: map['email'] ?? map['EMAIL'] ?? '',
      photoUrl: map['photoUrl'],
      grNo: (map['grNo'] ?? map['GR NO.'] ?? '').toString(),
      parentDetails: map['parentDetails'] ?? map['PARENT DETAILS'],
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
}
