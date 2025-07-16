import 'package:flutter/material.dart';
import 'package:luma/services/api_service.dart';
import 'package:luma/widgets/themed_background.dart';
import 'package:luma/screens/topics_screen.dart'; // Navigate here when done

class GeneratingCurriculumScreen extends StatefulWidget {
  final String topic;
  final List<Map<String, String>> answers;

  const GeneratingCurriculumScreen({
    super.key,
    required this.topic,
    required this.answers,
  });

  @override
  State<GeneratingCurriculumScreen> createState() => _GeneratingCurriculumScreenState();
}

class _GeneratingCurriculumScreenState extends State<GeneratingCurriculumScreen> {
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _generateAndNavigate();
  }

  Future<void> _generateAndNavigate() async {
    try {
      // Tell the backend to start generating. This call returns immediately.
      await _apiService.generatePersonalizedCurriculum(widget.topic, widget.answers);
      
      // In a real app, you would use push notifications or polling to know when
      // the backend is finished. For now, we'll just wait a fixed amount of time.
      // This gives the backend time to generate all the content.
      await Future.delayed(const Duration(seconds: 45)); 

      if (mounted) {
        // Navigate to the main topics screen, which will now show the new course.
        // We use pushAndRemoveUntil to clear the navigation stack so the user can't go back.
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const TopicsScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      // Handle any errors during the process
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error generating course: ${e.toString()}")),
        );
        // Go back to the welcome screen on failure
        Navigator.of(context).pop(); 
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemedBackground(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              Text(
                "Building Your Course...",
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(
                  "Our AI is creating a personalized learning path just for you. This might take a moment.",
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}