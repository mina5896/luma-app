import 'package:flutter/material.dart';
import 'package:luma/models/block_type.dart';
import 'package:luma/models/learning_objective_detail.dart';
import 'package:luma/models/content_block_detail.dart';
import 'package:luma/models/question_detail.dart';
import 'package:luma/services/api_service.dart';
import 'package:luma/services/persistence_service.dart';
import 'package:luma/screens/lesson_complete_screen.dart';
import 'package:luma/widgets/lesson/code_quiz_card.dart';
import 'package:luma/widgets/lesson/content_widgets.dart';
import 'package:luma/widgets/lesson/feedback_bottom_sheet.dart';
import 'package:luma/widgets/lesson/quiz_card.dart';
import 'package:luma/widgets/lesson/lesson_nav_buttons.dart';

class LessonPage {
  final dynamic content;
  final bool isQuiz;
  LessonPage({required this.content, required this.isQuiz});
}

class LessonScreen extends StatefulWidget {
  final String objectiveId;
  final String objectiveTitle;
  const LessonScreen({super.key, required this.objectiveId, required this.objectiveTitle});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  late Future<LearningObjectiveDetail> _lessonFuture;
  final ApiService _apiService = ApiService();
  final PersistenceService _persistenceService = PersistenceService(); // Add persistence service
  final PageController _pageController = PageController();
  List<LessonPage> _pages = [];
  int _currentPage = 0;
  int _totalXp = 0;
  bool _isAnswered = false;

  @override
  void initState() {
    super.initState();
    _lessonFuture = _apiService.getLearningObjectiveDetails(widget.objectiveId);
    _lessonFuture.then((lesson) => _buildPages(lesson));
  }

  void _buildPages(LearningObjectiveDetail lesson) {
    List<LessonPage> newPages = [];
    for (var block in lesson.contentBlocks) {
      if (block.blockType == BlockType.CODE_QUIZ) {
        newPages.add(LessonPage(content: block, isQuiz: true));
      } else {
        newPages.add(LessonPage(content: block, isQuiz: false));
        for (var question in block.questions) {
          newPages.add(LessonPage(content: question, isQuiz: true));
        }
      }
    }
    for (var question in lesson.finalQuizQuestions) {
      newPages.add(LessonPage(content: question, isQuiz: true));
    }
    setState(() => _pages = newPages);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- THIS METHOD IS UPDATED ---
  void _onAnswerSelected(String questionId, bool isCorrect, String explanation) {
    setState(() => _isAnswered = true);
    if (isCorrect) {
      setState(() => _totalXp += 10);
    } else {
      // If the answer is incorrect, save it for future review
      _persistenceService.scheduleForReview(questionId);
    }
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
              _onContinue(moveForward: true);
            }));
  }

  void _onContinue({required bool moveForward}) async {
    if (moveForward) {
      if (_currentPage < _pages.length - 1) {
        _pageController.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      } else {
        final bool? lessonReallyCompleted = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (context) => LessonCompleteScreen(totalXp: _totalXp)),
        );
        if (lessonReallyCompleted == true && mounted) {
          Navigator.of(context).pop(true);
        }
      }
    } else {
      if (_currentPage > 0) {
        _pageController.previousPage(duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SafeArea(
        child: FutureBuilder<LearningObjectiveDetail>(
          future: _lessonFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting || _pages.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (snapshot.hasData) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        IconButton(icon: const Icon(Icons.close, color: Colors.grey), onPressed: () => Navigator.of(context).pop(false)),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: (_currentPage + 1) / _pages.length,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                            minHeight: 12, borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      onPageChanged: (index) => setState(() {
                        _currentPage = index;
                        _isAnswered = false;
                      }),
                      itemCount: _pages.length,
                      itemBuilder: (context, index) {
                        final page = _pages[index];
                        if (page.isQuiz) {
                          // --- THIS IS THE UPDATED PART ---
                          if (page.content is ContentBlockDetail) {
                            final block = page.content as ContentBlockDetail;
                            final question = block.questions.first;
                            return CodeQuizCard(
                              key: ValueKey(block.id),
                              block: block,
                              onAnswerSelected: (isCorrect, explanation) => _onAnswerSelected(question.id, isCorrect, explanation),
                            );
                          } else {
                            final question = page.content as QuestionDetail;
                            return QuizCard(
                              key: ValueKey(question.id),
                              question: question,
                              onAnswerSelected: (isCorrect, explanation) => _onAnswerSelected(question.id, isCorrect, explanation),
                            );
                          }
                        } else {
                          return _buildContentWidget(page.content);
                        }
                      },
                    ),
                  ),
                  LessonNavButtons(
                    canGoBack: _currentPage > 0,
                    canGoForward: !_pages[_currentPage].isQuiz || _isAnswered,
                    onBack: () => _onContinue(moveForward: false),
                    onForward: () => _onContinue(moveForward: true),
                    isFinalPage: _currentPage == _pages.length - 1,
                  ),
                ],
              );
            }
            return const Center(child: Text('No lesson data found.'));
          },
        ),
      ),
    );
  }

  Widget _buildContentWidget(dynamic block) {
    switch (block.blockType as BlockType) {
      case BlockType.CODE_EXAMPLE:
        return CodeCard(key: ValueKey(block.id), content: block.contentPayload);
      case BlockType.SUMMARY:
        return AnimatedContentCard(key: ValueKey(block.id), icon: Icons.article_outlined, title: "Summary", content: block.contentPayload);
      case BlockType.DETAILED_EXPLANATION:
         return AnimatedContentCard(key: ValueKey(block.id), icon: Icons.zoom_in_rounded, title: "Deep Dive", content: block.contentPayload);
      default:
        return AnimatedContentCard(key: ValueKey(block.id), icon: Icons.lightbulb_outline, title: "Concept", content: block.contentPayload);
    }
  }
}