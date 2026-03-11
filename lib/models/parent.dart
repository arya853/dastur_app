/// Represents a parent linked to a student.
/// Includes data for the Virtual Parent ID Card feature.
class Parent {
  final String id;
  final String name;
  final String linkedStudentId;
  final String parentId;   // Unique school-issued parent ID
  final String? photoUrl;
  final String qrCodeId;   // Unique string for QR verification
  final String phone;
  final String email;

  Parent({
    required this.id,
    required this.name,
    required this.linkedStudentId,
    required this.parentId,
    this.photoUrl,
    required this.qrCodeId,
    required this.phone,
    required this.email,
  });

  factory Parent.fromMap(Map<String, dynamic> map, String id) {
    return Parent(
      id: id,
      name: map['name'] ?? '',
      linkedStudentId: map['linkedStudentId'] ?? '',
      parentId: map['parentId'] ?? '',
      photoUrl: map['photoUrl'],
      qrCodeId: map['qrCodeId'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'linkedStudentId': linkedStudentId,
      'parentId': parentId,
      'photoUrl': photoUrl,
      'qrCodeId': qrCodeId,
      'phone': phone,
      'email': email,
    };
  }
}
