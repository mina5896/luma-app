import 'package:flutter/material.dart';
import 'package:luma/models/learning_objective_summary.dart';

class LessonNode extends StatelessWidget {
  final LearningObjectiveSummary objective;
  final bool isLocked;
  final bool isUnlocked;
  final VoidCallback onTap;

  const LessonNode({
    super.key,
    required this.objective,
    required this.isLocked,
    required this.isUnlocked,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    Color nodeColor;
    IconData nodeIcon;
    Color textColor;

    if (isLocked) {
      nodeColor = Colors.grey.shade700;
      nodeIcon = Icons.lock_rounded;
      textColor = Colors.grey.shade400;
    } else if (isUnlocked) {
      nodeColor = colorScheme.primary;
      nodeIcon = Icons.play_arrow_rounded;
      textColor = Colors.white;
    } else { // Completed
      nodeColor = Colors.green;
      nodeIcon = Icons.check_circle_rounded;
      textColor = Colors.white;
    }

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: nodeColor,
              border: Border.all(color: Colors.white.withOpacity(0.5), width: 4),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.25), spreadRadius: 2, blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Icon(nodeIcon, color: Colors.white, size: 40),
          ),
          const SizedBox(height: 8),
          // --- THIS IS THE UPDATED PART ---
          Container(
            width: 130,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5), // Semi-transparent background
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              objective.title,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.visible,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: textColor, // Text color is now white or light grey
                fontSize: 12,
              ),
            ),
          )
        ],
      ),
    );
  }
}