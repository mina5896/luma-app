// lib/models/question_detail.dart

class QuestionDetail {
  final String id;
  final String questionText;
  final Map<String, String> options;
  final String correctAnswer;
  final String? explanation;

  QuestionDetail({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    this.explanation,
  });

  factory QuestionDetail.fromJson(Map<String, dynamic> json) {
    // --- THIS IS THE CORRECTED PART ---
    // The 'options' field is already a map, so we just need to cast it correctly.
    final Map<String, String> optionsMap =
        Map<String, String>.from(json['options']);

    return QuestionDetail(
      id: json['id'],
      questionText: json['questionText'],
      options: optionsMap,
      correctAnswer: json['correctAnswer'],
      explanation: json['explanation'],
    );
  }
}