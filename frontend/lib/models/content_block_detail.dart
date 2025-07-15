// lib/models/content_block_detail.dart

import './block_type.dart';
import './question_detail.dart';

class ContentBlockDetail {
  final String id;
  final int blockOrder;
  final BlockType blockType;
  final String contentPayload;
  final List<QuestionDetail> questions;

  ContentBlockDetail({
    required this.id,
    required this.blockOrder,
    required this.blockType,
    required this.contentPayload,
    required this.questions,
  });

  factory ContentBlockDetail.fromJson(Map<String, dynamic> json) {
    var questionsList = json['questions'] as List;
    List<QuestionDetail> questions =
        questionsList.map((i) => QuestionDetail.fromJson(i)).toList();

    return ContentBlockDetail(
      id: json['id'],
      blockOrder: json['blockOrder'],
      blockType: BlockType.fromString(json['blockType']),
      contentPayload: json['contentPayload'],
      questions: questions,
    );
  }
}