// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:luma/models/assessment_question.dart'; // New import
import 'package:luma/models/learning_objective_detail.dart';
import 'package:luma/models/topic_detail.dart';
import 'package:luma/models/topic_summary.dart';
import 'package:luma/models/question_detail.dart';

class ApiService {
  final String _baseUrl = "http://192.168.1.149:8080/api"; 
 // "http://10.178.57.80:8080/api";

 Future<void> generateGenericCurriculum(String topic) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/learning-flow/generate-generic-curriculum'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'topic': topic}),
    );
    if (response.statusCode != 202) {
      throw Exception('Failed to start generic curriculum generation');
    }
  }

  Future<List<QuestionDetail>> getQuestionDetailsByIds(List<String> questionIds) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/questions/details'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(questionIds),
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(decodedBody);
      return data.map((json) => QuestionDetail.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load question details');
    }
  }

  // --- NEW METHOD: Get Assessment Questions ---
  Future<List<AssessmentQuestion>> getAssessmentQuestions(String topic) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/learning-flow/assessment'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'topic': topic}),
    );

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(decodedBody);
      return data.map((json) => AssessmentQuestion.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load assessment questions');
    }
  }

  // --- NEW METHOD: Post Answers and Generate Curriculum ---
  Future<void> generatePersonalizedCurriculum(String topic, List<Map<String, String>> answers) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/learning-flow/generate-curriculum'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'topic': topic, 'userAnswers': answers}),
    );

    if (response.statusCode != 202) { // 202 Accepted
      throw Exception('Failed to start curriculum generation');
    }
  }
  
  Future<List<TopicSummary>> getTopicSummaries() async {
    final response = await http.get(Uri.parse('$_baseUrl/topics'));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      List<dynamic> data = json.decode(decodedBody);
      return data.map((json) => TopicSummary.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load topics');
    }
  }

  Future<TopicDetail> getTopicDetails(String topicId) async {
    final response = await http.get(Uri.parse('$_baseUrl/topics/$topicId'));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return TopicDetail.fromJson(json.decode(decodedBody));
    } else {
      throw Exception('Failed to load topic details');
    }
  }

  Future<LearningObjectiveDetail> getLearningObjectiveDetails(String objectiveId) async {
    final response = await http.get(Uri.parse('$_baseUrl/learning-objectives/$objectiveId'));

    if (response.statusCode == 200) {
      final decodedBody = utf8.decode(response.bodyBytes);
      return LearningObjectiveDetail.fromJson(json.decode(decodedBody));
    } else {
      throw Exception('Failed to load lesson details');
    }
  }
}