// lib/screens/new_topic_screen.dart
import 'package:flutter/material.dart';
import 'package:luma/screens/assessment_screen.dart';
import 'package:luma/services/api_service.dart';
import 'package:luma/widgets/themed_background.dart';

class NewTopicScreen extends StatefulWidget {
  const NewTopicScreen({super.key});

  @override
  State<NewTopicScreen> createState() => _NewTopicScreenState();
}

class _NewTopicScreenState extends State<NewTopicScreen> {
  final TextEditingController _topicController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final List<String> _suggestions = [
    "Python for Beginners",
    "Java Fundamentals",
    "Introduction to SQL",
    "Basics of Web Design",
    "History of Ancient Rome",
    "The Solar System",
  ];

  void _handleSubmission(bool takeTest) {
    if (_formKey.currentState!.validate()) {
      final topic = _topicController.text;
      if (takeTest) {
        // Navigate to assessment and wait for a result
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AssessmentScreen(topic: topic)),
        );
      } else {
        // Skip the test and call the generic curriculum endpoint
        _apiService.generateGenericCurriculum(topic);
        // Pop back to topics screen with the topic name to show generating state
        Navigator.of(context).pop(topic);
      }
    }
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create a New Course")),
      body: ThemedBackground(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              Text("What would you like to learn?", style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              TextFormField(
                controller: _topicController,
                decoration: const InputDecoration(labelText: "e.g., 'The Roman Empire'"),
                validator: (v) => (v == null || v.isEmpty) ? "Please enter a topic" : null,
              ),
              const SizedBox(height: 24),
              const Text("Or get inspired by our suggestions:"),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _suggestions.map((s) => ActionChip(label: Text(s), onPressed: () => _topicController.text = s)).toList(),
              ),
              const SizedBox(height: 40),
              const Divider(),
              const SizedBox(height: 20),
              // Button to skip the test
              ElevatedButton.icon(
                icon: const Icon(Icons.rocket_launch_outlined),
                label: const Text("I'm a Complete Beginner!"),
                onPressed: () => _handleSubmission(false),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Theme.of(context).colorScheme.onSecondary,
                ),
              ),
              const SizedBox(height: 12),
              // Button to take the test
              FilledButton.icon(
                icon: const Icon(Icons.quiz_outlined),
                label: const Text("Take Placement Test"),
                onPressed: () => _handleSubmission(true),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}