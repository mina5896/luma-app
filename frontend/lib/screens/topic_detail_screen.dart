import 'package:flutter/material.dart';
import 'package:luma/screens/profile_screen.dart';
import 'package:luma/screens/lesson_screen.dart';
import '../models/topic_detail.dart';
import '../services/api_service.dart';
import '../models/learning_objective_summary.dart';
import '../services/persistence_service.dart';
import '../widgets/topic_path/lesson_node.dart';
import '../widgets/topic_path/path_painter.dart';
import '../widgets/topic_path/cinematic_unlock_animation.dart';

class TopicDetailScreen extends StatefulWidget {
  final String topicId;
  final String topicName;
  const TopicDetailScreen({super.key, required this.topicId, required this.topicName});
  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> with TickerProviderStateMixin {
  late Future<TopicDetail> _topicDetailFuture;
  final ApiService _apiService = ApiService();
  final PersistenceService _persistenceService = PersistenceService();
  int _unlockedLevel = 0;
  bool _isLoadingProgress = true;
  late AnimationController _unlockAnimationController;
  int _animatingIndex = -1;
  List<Offset> _nodePositions = [];

  @override
  void initState() {
    super.initState();
    _unlockAnimationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    _topicDetailFuture = _apiService.getTopicDetails(widget.topicId);
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final savedLevel = await _persistenceService.getUnlockedLevel(widget.topicId);
    if (mounted) {
      setState(() {
        _unlockedLevel = savedLevel;
        _isLoadingProgress = false;
      });
    }
  }

  void _handleNodeTap(int index, LearningObjectiveSummary objective) async {
    final isLocked = index > _unlockedLevel;
    final isUnlocked = index == _unlockedLevel;
    final objectivesCount = _nodePositions.length;

    if (!isLocked) {
      final bool? lessonCompleted = await Navigator.push<bool>(context, MaterialPageRoute(builder: (context) => LessonScreen(objectiveId: objective.id, objectiveTitle: objective.title)));
      if (lessonCompleted == true && isUnlocked) {
        final newLevel = index + 1;
        if (newLevel >= objectivesCount) {
          await _persistenceService.saveUnlockedLevel(widget.topicId, newLevel);
          await _persistenceService.completeTopic(widget.topicId);
          setState(() => _unlockedLevel = newLevel);
        } else {
          _startUnlockAnimation(index);
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete the previous level first!')));
    }
  }

  void _startUnlockAnimation(int index) {
    if (_unlockAnimationController.isAnimating) return;
    setState(() => _animatingIndex = index);
    final keyOverlay = OverlayEntry(builder: (context) => CinematicUnlockAnimation(controller: _unlockAnimationController));
    Overlay.of(context).insert(keyOverlay);
    _unlockAnimationController.forward().whenComplete(() {
      keyOverlay.remove();
      final newLevel = index + 1;
      _persistenceService.saveUnlockedLevel(widget.topicId, newLevel);
      setState(() {
        _unlockedLevel = newLevel;
        _animatingIndex = -1;
      });
      _unlockAnimationController.reset();
    });
  }

  @override
  void dispose() {
    _unlockAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topicName),
        // --- THIS IS THE UPDATED PART ---
        actions: [
          IconButton(
            icon: const Icon(Icons.person_rounded, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: LinearGradient(colors: [Theme.of(context).colorScheme.primary.withOpacity(0.1), Theme.of(context).colorScheme.surface], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: _isLoadingProgress
            ? const Center(child: CircularProgressIndicator())
            : FutureBuilder<TopicDetail>(
                future: _topicDetailFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (snapshot.hasData) {
                    final objectives = snapshot.data!.learningObjectives;
                    _nodePositions = _generateNodePositions(objectives.length, context);

                    if (_nodePositions.isEmpty) return const Center(child: Text('No lessons in this topic yet.'));

                    return SingleChildScrollView(
                      child: SizedBox(
                        height: (objectives.length * 160.0) + 180,
                        child: Stack(
                          children: [
                            CustomPaint(size: Size.infinite, painter: PathPainter(nodePositions: _nodePositions, unlockedLevel: _unlockedLevel, animatingIndex: _animatingIndex)),
                            ...List.generate(objectives.length, (index) {
                              final objective = objectives[index];
                              final position = _nodePositions[index];
                              return Positioned(top: position.dy, left: position.dx, child: LessonNode(objective: objective, isLocked: index > _unlockedLevel, isUnlocked: index == _unlockedLevel, onTap: () => _handleNodeTap(index, objective)));
                            }),
                          ],
                        ),
                      ),
                    );
                  }
                  return const Center(child: Text('No learning objectives found.'));
                },
              ),
      ),
    );
  }

  List<Offset> _generateNodePositions(int count, BuildContext context) {
    if (count == 0) return [];
    final positions = <Offset>[];
    final width = MediaQuery.of(context).size.width;
    const nodeCenter = 40.0;
    for (int i = 0; i < count; i++) {
      final dy = (i * 160.0) + 40;
      final dx = i.isEven ? (width * 0.25) - nodeCenter : (width * 0.75) - nodeCenter;
      positions.add(Offset(dx, dy));
    }
    return positions;
  }
}