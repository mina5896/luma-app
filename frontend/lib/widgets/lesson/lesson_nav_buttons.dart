import 'package:flutter/material.dart';

class LessonNavButtons extends StatelessWidget {
  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final bool isFinalPage;

  const LessonNavButtons({
    super.key,
    required this.canGoBack,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
    required this.isFinalPage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back Button
          IconButton(
            onPressed: canGoBack ? onBack : null,
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: canGoBack ? Colors.grey.shade700 : Colors.grey.shade300),
            iconSize: 28,
          ),
          // Continue Button
          ElevatedButton.icon(
            onPressed: canGoForward ? onForward : null,
            icon: Icon(isFinalPage ? Icons.check_circle : Icons.arrow_forward_ios_rounded, size: 20),
            label: Text(isFinalPage ? "Finish" : "Continue"),
            style: ElevatedButton.styleFrom(
              backgroundColor: isFinalPage ? Colors.green : Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: Colors.grey.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}