/// Represents a downloadable e-book / textbook.
class Ebook {
  final String id;
  final String title;
  final String subject;
  final String classId;
  final String pdfUrl;
  final String? uploadedBy;

  Ebook({
    required this.id,
    required this.title,
    required this.subject,
    required this.classId,
    required this.pdfUrl,
    this.uploadedBy,
  });

  factory Ebook.fromMap(Map<String, dynamic> map, String id) {
    return Ebook(
      id: id,
      title: map['title'] ?? '',
      subject: map['subject'] ?? '',
      classId: map['classId'] ?? '',
      pdfUrl: map['pdfUrl'] ?? '',
      uploadedBy: map['uploadedBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'subject': subject,
      'classId': classId,
      'pdfUrl': pdfUrl,
      'uploadedBy': uploadedBy,
    };
  }
}
