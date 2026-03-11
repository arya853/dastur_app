/// Subject with syllabus / chapter tracking.
class Subject {
  final String id;
  final String name;
  final String classId;
  final List<Chapter> chapters;

  Subject({
    required this.id,
    required this.name,
    required this.classId,
    required this.chapters,
  });

  factory Subject.fromMap(Map<String, dynamic> map, String id) {
    return Subject(
      id: id,
      name: map['name'] ?? '',
      classId: map['classId'] ?? '',
      chapters: (map['chapters'] as List<dynamic>?)
              ?.map((c) => Chapter.fromMap(c))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'classId': classId,
      'chapters': chapters.map((c) => c.toMap()).toList(),
    };
  }

  /// How many chapters are marked as completed
  int get completedCount => chapters.where((c) => c.completed).length;

  /// Completion percentage for progress indicator
  double get completionPercentage =>
      chapters.isNotEmpty ? completedCount / chapters.length : 0;
}

/// A single chapter within a subject's syllabus.
class Chapter {
  final String name;
  final bool completed;

  Chapter({required this.name, required this.completed});

  factory Chapter.fromMap(Map<String, dynamic> map) {
    return Chapter(
      name: map['name'] ?? '',
      completed: map['completed'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'completed': completed,
    };
  }
}
