// lib/models/topic_detail.dart

import 'learning_objective_summary.dart';

class TopicDetail {
  final String id;
  final String name;
  final String? description;
  final List<LearningObjectiveSummary> learningObjectives;

  TopicDetail({
    required this.id,
    required this.name,
    this.description,
    required this.learningObjectives,
  });

  factory TopicDetail.fromJson(Map<String, dynamic> json) {
    var objectivesList = json['learningObjectives'] as List;
    List<LearningObjectiveSummary> objectives = objectivesList
        .map((i) => LearningObjectiveSummary.fromJson(i))
        .toList();

    return TopicDetail(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      learningObjectives: objectives,
    );
  }
}