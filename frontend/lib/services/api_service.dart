// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:luma/models/learning_objective_detail.dart';
import 'package:luma/models/topic_detail.dart';
import 'package:luma/models/topic_summary.dart'; // Import the new model

class ApiService {
  final String _baseUrl = //"http://192.168.1.149:8080/api"; 
  "http://10.178.57.80:8080/api";

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