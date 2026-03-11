/// Represents a practice quiz with MCQ questions.
class Quiz {
  final String id;
  final String classId;
  final String subject;
  final String title;
  final List<QuizQuestion> questions;
  final String? createdBy;

  Quiz({
    required this.id,
    required this.classId,
    required this.subject,
    required this.title,
    required this.questions,
    this.createdBy,
  });

  factory Quiz.fromMap(Map<String, dynamic> map, String id) {
    return Quiz(
      id: id,
      classId: map['classId'] ?? '',
      subject: map['subject'] ?? '',
      title: map['title'] ?? '',
      questions: (map['questions'] as List<dynamic>?)
              ?.map((q) => QuizQuestion.fromMap(q))
              .toList() ??
          [],
      createdBy: map['createdBy'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'classId': classId,
      'subject': subject,
      'title': title,
      'questions': questions.map((q) => q.toMap()).toList(),
      'createdBy': createdBy,
    };
  }

  int get totalQuestions => questions.length;
}

/// A single MCQ question in a quiz.
class QuizQuestion {
  final String text;
  final List<String> options;
  final int correctIndex; // index of the correct option (0-based)

  QuizQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
  });

  factory QuizQuestion.fromMap(Map<String, dynamic> map) {
    return QuizQuestion(
      text: map['text'] ?? '',
      options: List<String>.from(map['options'] ?? []),
      correctIndex: map['correctIndex'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'options': options,
      'correctIndex': correctIndex,
    };
  }
}
