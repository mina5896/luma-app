// lib/models/learning_objective_summary.dart

class LearningObjectiveSummary {
  final String id;
  final String title;
  final int difficulty;

  LearningObjectiveSummary({
    required this.id,
    required this.title,
    required this.difficulty,
  });

  factory LearningObjectiveSummary.fromJson(Map<String, dynamic> json) {
    return LearningObjectiveSummary(
      id: json['id'],
      title: json['title'],
      difficulty: json['difficulty'],
    );
  }
}