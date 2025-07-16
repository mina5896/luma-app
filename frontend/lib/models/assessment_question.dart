// lib/models/assessment_question.dart

class AssessmentQuestion {
  final String questionText;
  final Map<String, String> options;
  final String correctAnswerKey;

  AssessmentQuestion({
    required this.questionText,
    required this.options,
    required this.correctAnswerKey,
  });

  factory AssessmentQuestion.fromJson(Map<String, dynamic> json) {
    return AssessmentQuestion(
      questionText: json['questionText'],
      options: Map<String, String>.from(json['options']),
      correctAnswerKey: json['correctAnswerKey'],
    );
  }
}