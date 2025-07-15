// lib/widgets/topic_progress_indicator.dart
import 'package:flutter/material.dart';

class TopicProgressIndicator extends StatelessWidget {
  final int totalObjectives;
  final int completedObjectives;

  const TopicProgressIndicator({
    super.key,
    required this.totalObjectives,
    required this.completedObjectives,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = totalObjectives > 0 ? completedObjectives / totalObjectives : 0;

    return SizedBox(
      width: 60,
      height: 60,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 6,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
          ),
          Center(
            child: Icon(
              Icons.school_rounded,
              size: 30,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}