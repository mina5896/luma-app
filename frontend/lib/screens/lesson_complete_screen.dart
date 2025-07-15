import 'package:flutter/material.dart';
import 'package:luma/services/persistence_service.dart';
import 'package:luma/widgets/lesson/luma_mascot.dart';
import 'package:luma/widgets/themed_background.dart';

class LessonCompleteScreen extends StatefulWidget {
  final int totalXp;
  const LessonCompleteScreen({super.key, required this.totalXp});

  @override
  State<LessonCompleteScreen> createState() => _LessonCompleteScreenState();
}

class _LessonCompleteScreenState extends State<LessonCompleteScreen> {
  final PersistenceService _persistenceService = PersistenceService();

  @override
  void initState() {
    super.initState();
    // Save the XP and update the streak when the screen is shown
    if (widget.totalXp > 0) {
      _persistenceService.addXp(widget.totalXp);
      _persistenceService.updateAndGetStreak();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ThemedBackground(child:Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.green.shade300, Theme.of(context).colorScheme.primary.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LumaMascot(state: MascotState.celebrating),
            const SizedBox(height: 24),
            const Text(
              'Lesson Complete!',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [Shadow(blurRadius: 10, color: Colors.black26)]
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'You earned ${widget.totalXp} XP',
              style: const TextStyle(
                fontSize: 20,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Continue'),
            )
          ],
        ),
      ),),
    );
  }
}