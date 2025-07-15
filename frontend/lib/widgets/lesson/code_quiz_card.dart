import 'package:flutter/material.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:luma/models/content_block_detail.dart';
import 'package:luma/widgets/lesson/luma_mascot.dart';
import 'package:luma/widgets/lesson/quiz_card.dart'; // We reuse the QuizOption widget

// Theme for the code highlighter
const monokaiSublimeTheme = {
  'root': TextStyle(backgroundColor: Color(0xff23241f), color: Color(0xfff8f8f2)),
  'tag': TextStyle(color: Color(0xfff92672)),
  'subst': TextStyle(color: Color(0xfff8f8f2)),
  'strong': TextStyle(color: Color(0xffa6e22e), fontWeight: FontWeight.bold),
  'emphasis': TextStyle(color: Color(0xffa6e22e), fontStyle: FontStyle.italic),
  'bullet': TextStyle(color: Color(0xffae81ff)),
  'quote': TextStyle(color: Color(0xffae81ff)),
  'number': TextStyle(color: Color(0xffae81ff)),
  'regexp': TextStyle(color: Color(0xffae81ff)),
  'literal': TextStyle(color: Color(0xffae81ff)),
  'link': TextStyle(color: Color(0xffae81ff)),
  'code': TextStyle(color: Color(0xffa6e22e)),
  'title': TextStyle(color: Color(0xffa6e22e)),
  'section': TextStyle(color: Color(0xffa6e22e)),
  'selector-class': TextStyle(color: Color(0xffa6e22e)),
  'keyword': TextStyle(color: Color(0xfff92672)),
  'selector-tag': TextStyle(color: Color(0xfff92672)),
  'name': TextStyle(color: Color(0xfff92672)),
  'attr': TextStyle(color: Color(0xfff92672)),
  'symbol': TextStyle(color: Color(0xff66d9ef)),
  'attribute': TextStyle(color: Color(0xff66d9ef)),
  'params': TextStyle(color: Color(0xfff8f8f2)),
  'string': TextStyle(color: Color(0xffe6db74)),
  'type': TextStyle(color: Color(0xffe6db74)),
  'built_in': TextStyle(color: Color(0xffe6db74)),
  'selector-id': TextStyle(color: Color(0xffe6db74)),
  'selector-attr': TextStyle(color: Color(0xffe6db74)),
  'selector-pseudo': TextStyle(color: Color(0xffe6db74)),
  'addition': TextStyle(color: Color(0xffe6db74)),
  'variable': TextStyle(color: Color(0xffe6db74)),
  'template-variable': TextStyle(color: Color(0xffe6db74)),
  'comment': TextStyle(color: Color(0xff75715e)),
  'deletion': TextStyle(color: Color(0xff75715e)),
  'meta': TextStyle(color: Color(0xff75715e)),
};


class CodeQuizCard extends StatefulWidget {
  final ContentBlockDetail block;
  final Function(bool, String) onAnswerSelected;

  const CodeQuizCard({super.key, required this.block, required this.onAnswerSelected});

  @override
  State<CodeQuizCard> createState() => _CodeQuizCardState();
}

class _CodeQuizCardState extends State<CodeQuizCard> {
  String? _selectedOptionKey;

  void _handleOptionTap(String key) {
    if (_selectedOptionKey != null) return;
    setState(() => _selectedOptionKey = key);

    final question = widget.block.questions.first;
    final isCorrect = key == question.correctAnswer;
    Future.delayed(const Duration(milliseconds: 300), () {
      widget.onAnswerSelected(isCorrect, question.explanation ?? '');
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.block.questions.isEmpty) {
      return const Center(child: Text("Code quiz content is missing questions."));
    }
    final question = widget.block.questions.first;

    // --- THIS IS THE CORRECTED LOGIC ---
    final parts = widget.block.contentPayload.split('|||');
    final String description = parts.length > 1 ? parts[0].trim() : '';
    final String code = parts.length > 1 ? parts[1].trim() : parts[0].trim();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Code Challenge", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              // Display the description if it exists
              if (description.isNotEmpty)
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
              if (description.isNotEmpty) const SizedBox(height: 16),
              // Display the code snippet with the theme
              SizedBox(
                width: double.infinity,
                child: HighlightView(
                  code.replaceAll('[BLANK]', '______'),
                  language: 'java',
                  theme: monokaiSublimeTheme, 
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(fontSize: 16, fontFamily: 'monospace'),
                ),
              ),
              const SizedBox(height: 24),
              Text(question.questionText, style: Theme.of(context).textTheme.titleLarge?.copyWith(height: 1.4, fontWeight: FontWeight.bold)),
              const SizedBox(height: 32),
              // Display the code fragment options
              ...question.options.entries.map((entry) {
                return QuizOption(
                  text: entry.value,
                  isSelected: _selectedOptionKey == entry.key,
                  isCorrect: entry.key == question.correctAnswer,
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