import 'package:flutter/material.dart';
import 'package:luma/widgets/lesson/luma_mascot.dart'; // Import the mascot

class FeedbackBottomSheet extends StatelessWidget {
  final bool isCorrect;
  final String explanation;
  final VoidCallback onContinue;

  const FeedbackBottomSheet({
    super.key,
    required this.isCorrect,
    required this.explanation,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final color = isCorrect ? const Color(0xffd7ffb8) : const Color(0xffffdfe0);
    final textColor = isCorrect ? const Color(0xff58a700) : const Color(0xffea2b2b);
    final title = isCorrect ? "Excellent!" : "Incorrect";

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: color, borderRadius: const BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              LumaMascot(state: isCorrect ? MascotState.happy : MascotState.sad),
              const SizedBox(width: 12),
              Expanded( // Use Expanded to prevent title from overflowing
                child: Text(title, style: TextStyle(color: textColor, fontSize: 22, fontWeight: FontWeight.bold))
              ),
            ],
          ),
          if (explanation.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(explanation, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500)),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: isCorrect ? Colors.green : Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            child: const Text('Continue'),
          )
        ],
      ),
    );
  }
}