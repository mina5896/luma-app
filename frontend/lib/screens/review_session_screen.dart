// lib/screens/review_session_screen.dart

import 'package:flutter/material.dart';
import 'package:luma/models/question_detail.dart';
import 'package:luma/models/review_item.dart';
import 'package:luma/services/api_service.dart';
import 'package:luma/services/persistence_service.dart';
import 'package:luma/widgets/lesson/feedback_bottom_sheet.dart';
import 'package:luma/widgets/lesson/quiz_card.dart';
import 'package:luma/widgets/themed_background.dart';

class ReviewSessionScreen extends StatefulWidget {
  final List<ReviewItem> reviewItems;
  const ReviewSessionScreen({super.key, required this.reviewItems});

  @override
  State<ReviewSessionScreen> createState() => _ReviewSessionScreenState();
}

class _ReviewSessionScreenState extends State<ReviewSessionScreen> {
  late Future<List<QuestionDetail>> _questionsFuture;
  final ApiService _apiService = ApiService();
  final PersistenceService _persistenceService = PersistenceService();
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    final questionIds = widget.reviewItems.map((item) => item.questionId).toList();
    _questionsFuture = _apiService.getQuestionDetailsByIds(questionIds);
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onAnswered(String questionId, bool isCorrect, String explanation) {
    // Update the review schedule for this question
    _persistenceService.updateReviewItem(questionId, isCorrect);
    
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) => FeedbackBottomSheet(
        isCorrect: isCorrect,
        explanation: explanation,
        onContinue: () {
          Navigator.of(context).pop();
          _moveToNextPage();
        },
      ),
    );
  }

  void _moveToNextPage() {
    if (_currentPage < widget.reviewItems.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Finished the review session
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Review Session")),
      body: ThemedBackground(
        child: FutureBuilder<List<QuestionDetail>>(
          future: _questionsFuture,
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
                    child: LinearProgressIndicator(
                      value: (_currentPage + 1) / questions.length,
                      minHeight: 12,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: questions.length,
                      onPageChanged: (index) => setState(() => _currentPage = index),
                      itemBuilder: (context, index) {
                        final question = questions[index];
                        return QuizCard(
                          key: ValueKey(question.id),
                          question: question,
                          onAnswerSelected: (isCorrect, explanation) =>
                              _onAnswered(question.id, isCorrect, explanation),
                        );
                      },
                    ),
                  ),
                ],
              );
            }
            return const Center(child: Text("No questions to review."));
          },
        ),
      ),
    );
  }
}