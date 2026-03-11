import 'package:flutter/material.dart';
import '../../core/app_colors.dart';
import '../../core/app_constants.dart';
import '../../widgets/shared_widgets.dart';
import '../../services/mock_data_service.dart';
import '../../models/quiz.dart';

/// Quizzes List Screen – shows available practice quizzes.
class QuizzesScreen extends StatelessWidget {
  const QuizzesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quizzes = MockDataService.quizzes;

    return Scaffold(
      appBar: const GradientAppBar(title: 'Practice Quizzes', showBackButton: true),
      backgroundColor: AppColors.background,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: quizzes.length,
        itemBuilder: (context, index) {
          final quiz = quizzes[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.tileIconColors[5].withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.quiz_rounded,
                    color: AppColors.tileIconColors[5], size: 24),
              ),
              title: Text(quiz.title,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '${quiz.subject} • ${quiz.totalQuestions} Questions',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  gradient: AppColors.accentGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Start',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark)),
              ),
              onTap: () => Navigator.pushNamed(context, '/quiz-play', arguments: quiz),
            ),
          );
        },
      ),
    );
  }
}

/// Quiz Play Screen – MCQ quiz with instant scoring.
class QuizPlayScreen extends StatefulWidget {
  const QuizPlayScreen({super.key});

  @override
  State<QuizPlayScreen> createState() => _QuizPlayScreenState();
}

class _QuizPlayScreenState extends State<QuizPlayScreen> {
  int _currentIndex = 0;
  final Map<int, int> _answers = {};
  bool _submitted = false;

  @override
  Widget build(BuildContext context) {
    final quiz = ModalRoute.of(context)!.settings.arguments as Quiz;
    final question = quiz.questions[_currentIndex];

    if (_submitted) {
      return _buildResultScreen(quiz);
    }

    return Scaffold(
      appBar: GradientAppBar(title: quiz.title, showBackButton: true),
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentIndex + 1) / quiz.totalQuestions,
            backgroundColor: AppColors.border,
            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
            minHeight: 4,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question number
                  Text(
                    'Question ${_currentIndex + 1} of ${quiz.totalQuestions}',
                    style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  // Question text
                  Text(
                    question.text,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w600, height: 1.4),
                  ),
                  const SizedBox(height: 24),
                  // Options
                  ...List.generate(question.options.length, (i) {
                    final isSelected = _answers[_currentIndex] == i;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GestureDetector(
                        onTap: () => setState(() => _answers[_currentIndex] = i),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.accent.withValues(alpha: 0.1)
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(AppConstants.radiusMd),
                            border: Border.all(
                              color: isSelected
                                  ? AppColors.accent
                                  : AppColors.border,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected
                                      ? AppColors.accent
                                      : AppColors.surfaceElevated,
                                ),
                                child: Center(
                                  child: Text(
                                    String.fromCharCode(65 + i),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: isSelected
                                          ? AppColors.primaryDark
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  question.options[i],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.textPrimary,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.surface,
            child: Row(
              children: [
                if (_currentIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () =>
                          setState(() => _currentIndex--),
                      child: const Text('Previous'),
                    ),
                  ),
                if (_currentIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      if (_currentIndex < quiz.totalQuestions - 1) {
                        setState(() => _currentIndex++);
                      } else {
                        setState(() => _submitted = true);
                      }
                    },
                    child: Text(_currentIndex < quiz.totalQuestions - 1
                        ? 'Next'
                        : 'Submit'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen(Quiz quiz) {
    int correct = 0;
    for (int i = 0; i < quiz.questions.length; i++) {
      if (_answers[i] == quiz.questions[i].correctIndex) correct++;
    }
    final percentage = (correct / quiz.totalQuestions * 100).round();

    return Scaffold(
      appBar: GradientAppBar(title: quiz.title, showBackButton: true),
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Score circle
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: percentage >= 60
                      ? const LinearGradient(
                          colors: [AppColors.success, Color(0xFF34D399)])
                      : const LinearGradient(
                          colors: [AppColors.error, Color(0xFFFB7185)]),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          color: Colors.white),
                    ),
                    Text(
                      '$correct/${quiz.totalQuestions}',
                      style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                percentage >= 80
                    ? 'Excellent! 🎉'
                    : percentage >= 60
                        ? 'Good Job! 👍'
                        : 'Keep Practicing! 💪',
                style: const TextStyle(
                    fontSize: 24, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'You scored $correct out of ${quiz.totalQuestions} questions correctly.',
                style: const TextStyle(
                    fontSize: 14, color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Quizzes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
