import 'package:flutter/material.dart';
import 'package:luma/models/question_detail.dart';
import 'package:luma/widgets/lesson/luma_mascot.dart';

class QuizCard extends StatefulWidget {
  final QuestionDetail question;
  final Function(bool, String) onAnswerSelected;
  const QuizCard({super.key, required this.question, required this.onAnswerSelected});

  @override
  State<QuizCard> createState() => _QuizCardState();
}

class _QuizCardState extends State<QuizCard> {
  String? _selectedOptionKey;

  void _handleOptionTap(String key) {
    if (_selectedOptionKey != null) return;

    setState(() {
      _selectedOptionKey = key;
    });
    
    final isCorrect = key == widget.question.correctAnswer;
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onAnswerSelected(isCorrect, widget.question.explanation ?? '');
    });
  }
  // ... _getOptionColor and _getOptionBorder remain the same

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Check your knowledge", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Text(widget.question.questionText, style: Theme.of(context).textTheme.titleLarge?.copyWith(height: 1.4, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              ...widget.question.options.entries.map((entry) {
                // --- WRAP THE OPTION IN THE NEW ANIMATED WIDGET ---
                return QuizOption(
                  text: entry.value,
                  isSelected: _selectedOptionKey == entry.key,
                  isCorrect: entry.key == widget.question.correctAnswer,
                  hasBeenAnswered: _selectedOptionKey != null,
                  onTap: () => _handleOptionTap(entry.key),
                );
              }),
            ],
          ),
          const SizedBox(height: 40),
          if (_selectedOptionKey == null)
            const LumaMascot(state: MascotState.thinking),
        ],
      ),
    );
  }
}

// --- NEW WIDGET FOR ANIMATED QUIZ OPTIONS ---
class QuizOption extends StatefulWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool hasBeenAnswered;
  final VoidCallback onTap;

  const QuizOption({
    super.key,
    required this.text,
    required this.isSelected,
    required this.isCorrect,
    required this.hasBeenAnswered,
    required this.onTap,
  });

  @override
  State<QuizOption> createState() => _QuizOptionState();
}

class _QuizOptionState extends State<QuizOption> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getOptionColor() {
    if (!widget.hasBeenAnswered) return Colors.white;
    if (widget.isCorrect) return Colors.green.shade50;
    if (widget.isSelected) return Colors.red.shade50;
    return Colors.white.withOpacity(0.5);
  }
  
  Border? _getOptionBorder() {
    if (!widget.hasBeenAnswered) return Border.all(color: Colors.grey.shade300);
    if (widget.isCorrect) return Border.all(color: Colors.green, width: 2.5);
    if (widget.isSelected) return Border.all(color: Colors.red, width: 2.5);
    return Border.all(color: Colors.grey.shade300);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getOptionColor(),
            border: _getOptionBorder(),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.text,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: widget.hasBeenAnswered && !widget.isSelected && !widget.isCorrect
                            ? Colors.grey
                            : Colors.black87,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}