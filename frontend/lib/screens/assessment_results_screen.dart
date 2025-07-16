import 'package:flutter/material.dart';
import 'package:luma/services/api_service.dart';
import 'package:luma/widgets/themed_background.dart';

class AssessmentResultsScreen extends StatelessWidget {
  final String topic;
  final List<Map<String, String>> answers;
  final ApiService _apiService = ApiService();

  AssessmentResultsScreen({
    super.key,
    required this.topic,
    required this.answers,
  });

  void _startGeneration(BuildContext context) {
    // Tell the backend to start generating the course
    _apiService.generatePersonalizedCurriculum(topic, answers);
    
    // --- THIS IS THE FIX ---
    // Pop back and return the topic name to signal that generation has started.
    Navigator.of(context).pop(topic);
  }

  @override
  Widget build(BuildContext context) {
    final correctAnswers = answers.where((a) => a['selectedAnswerKey'] == a['correctAnswerKey']).length;
    final totalQuestions = answers.length;

    return Scaffold(
      appBar: AppBar(title: const Text("Your Results")),
      body: ThemedBackground(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  "Great Job!",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  "You answered $correctAnswers out of $totalQuestions questions correctly.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  "We'll use this to build a learning path tailored just for you.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white60),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: () => _startGeneration(context),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Build My Course!", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}