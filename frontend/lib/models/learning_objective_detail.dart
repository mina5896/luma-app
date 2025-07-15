// lib/models/learning_objective_detail.dart

// Use the full package path for BOTH imports
import 'package:luma/models/content_block_detail.dart';
import 'package:luma/models/question_detail.dart';

class LearningObjectiveDetail {
  final String id;
  final String title;
  final List<ContentBlockDetail> contentBlocks;
  final List<QuestionDetail> finalQuizQuestions;

  LearningObjectiveDetail({
    required this.id,
    required this.title,
    required this.contentBlocks,
    required this.finalQuizQuestions,
  });

  factory LearningObjectiveDetail.fromJson(Map<String, dynamic> json) {
    var blocksList = json['contentBlocks'] as List;
    List<ContentBlockDetail> contentBlocks =
        blocksList.map((i) => ContentBlockDetail.fromJson(i)).toList();

    var quizList = json['finalQuizQuestions'] as List;
    List<QuestionDetail> finalQuiz =
        quizList.map((i) => QuestionDetail.fromJson(i)).toList();

    return LearningObjectiveDetail(
      id: json['id'],
      title: json['title'],
      contentBlocks: contentBlocks,
      finalQuizQuestions: finalQuiz,
    );
  }
}