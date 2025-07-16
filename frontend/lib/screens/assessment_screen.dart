import 'package:flutter/material.dart';
import 'package:luma/models/assessment_question.dart';
import 'package:luma/screens/assessment_results_screen.dart';
import 'package:luma/services/api_service.dart';
import 'package:luma/widgets/themed_background.dart';

class AssessmentScreen extends StatefulWidget {
  final String topic;
  const AssessmentScreen({super.key, required this.topic});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  late Future<List<AssessmentQuestion>> _assessmentFuture;
  final ApiService _apiService = ApiService();
  final PageController _pageController = PageController();
  final List<Map<String, String>> _userAnswers = [];
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _assessmentFuture = _apiService.getAssessmentQuestions(widget.topic);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onAnswered(String questionText, String selectedKey, String correctKey, int totalQuestions) {
    _userAnswers.add({
      'questionText': questionText,
      'selectedAnswerKey': selectedKey,
      'correctAnswerKey': correctKey,
    });

    // Wait a moment after showing feedback, then move on
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      if (_currentPage < totalQuestions - 1) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => AssessmentResultsScreen(
              topic: widget.topic,
              answers: _userAnswers,
            ),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.topic} Placement Test", maxLines: 2,)),
      body: ThemedBackground(
        child: FutureBuilder<List<AssessmentQuestion>>(
          future: _assessmentFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error: ${snapshot.error}"));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final questions = snapshot.data!;
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Question ${_currentPage + 1} of ${questions.length}", style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70)),
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: (_currentPage + 1) / questions.length,
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(6),
                          backgroundColor: Colors.grey.shade800,
                          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(), // User cannot swipe
                      itemCount: questions.length,
                      onPageChanged: (index) => setState(() => _currentPage = index),
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        return _AssessmentQuizCard(
                          key: ValueKey(question.questionText),
                          question: question,
                          onAnswered: (selectedKey) => _onAnswered(
                            question.questionText,
                            selectedKey,
                            question.correctAnswerKey,
                            questions.length,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const Center(child: Text("No assessment questions found."));
          },
        ),
      ),
    );
  }
}

class _AssessmentQuizCard extends StatefulWidget {
  final AssessmentQuestion question;
  final Function(String) onAnswered;
  const _AssessmentQuizCard({super.key, required this.question, required this.onAnswered});

  @override
  State<_AssessmentQuizCard> createState() => _AssessmentQuizCardState();
}

class _AssessmentQuizCardState extends State<_AssessmentQuizCard> {
  String? _selectedKey;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Let's see what you know", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Text(widget.question.questionText, style: Theme.of(context).textTheme.titleLarge?.copyWith(height: 1.4, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          ...widget.question.options.entries.map((entry) {
            final isSelected = _selectedKey == entry.key;
            final isCorrect = entry.key == widget.question.correctAnswerKey;
            
            Color tileColor = Theme.of(context).colorScheme.surface.withOpacity(0.5);
            BorderSide borderSide = BorderSide(color: Colors.grey.shade700);
            Widget? trailingIcon;

            if (_selectedKey != null) {
              if (isCorrect) {
                tileColor = Colors.green.withOpacity(0.25);
                borderSide = const BorderSide(color: Colors.green, width: 2);
                trailingIcon = const Icon(Icons.check_circle, color: Colors.green);
              } else if (isSelected) {
                tileColor = Colors.red.withOpacity(0.25);
                borderSide = const BorderSide(color: Colors.red, width: 2);
                trailingIcon = const Icon(Icons.cancel, color: Colors.red);
              }
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: ListTile(
                onTap: () {
                  if (_selectedKey == null) {
                    setState(() => _selectedKey = entry.key);
                    widget.onAnswered(entry.key);
                  }
                },
                tileColor: tileColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15), side: borderSide),
                title: Text(entry.value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                trailing: trailingIcon,
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}