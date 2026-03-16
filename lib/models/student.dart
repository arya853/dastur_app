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
      className: (map['className'] ?? map['CLASS'] ?? map['className'] ?? '').toString(),
      division: map['division'] ?? map['DIV'] ?? map['SECTION'] ?? map['section'] ?? '', 
      rollNumber: (map['rollNumber'] ?? map['ROLL NO.'] ?? '').toString(),
      email: map['email'] ?? map['EMAIL'] ?? '',
      photoUrl: map['photoUrl'],
      grNo: (map['grNo'] ?? map['GR NO.'] ?? '').toString(),
      parentDetails: map['parentDetails'] ?? map['PARENT DETAILS'] ?? map,
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

<<<<<<< HEAD
  /// Alias for className to match UI usage
  String get grade => className;
=======
  /// Helper to get parent name from details
  String get parentName {
    if (parentDetails == null) return 'Parent';
    return parentDetails!['name'] ?? 
           parentDetails!['NAME'] ?? 
           parentDetails!['PARENT 1 NAME'] ?? 
           parentDetails!['PARENT NAME'] ?? 
           'Parent';
  }
  
  /// Helper to get parent phone from details
  String get parentPhone => parentDetails?['phone'] ?? parentDetails?['PHONE'] ?? 'N/A';
>>>>>>> main
}
