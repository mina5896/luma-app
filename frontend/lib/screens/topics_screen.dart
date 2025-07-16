import 'package:flutter/material.dart';
import 'package:luma/models/topic_summary.dart';
import 'package:luma/screens/assessment_screen.dart';
import 'package:luma/screens/profile_screen.dart';
import 'package:luma/screens/topic_detail_screen.dart';
import 'package:luma/services/api_service.dart';
import 'package:luma/services/persistence_service.dart';
import 'package:luma/widgets/themed_background.dart';
import 'package:luma/widgets/topic_progress_indicator.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  Future<List<TopicSummary>>? _topicsFuture;
  final ApiService _apiService = ApiService();
  final PersistenceService _persistenceService = PersistenceService();
  String? _generatingTopic;

  @override
  void initState() {
    super.initState();
    _fetchTopics();
  }

  void _fetchTopics() {
    setState(() {
      _generatingTopic = null; // Clear generating topic on refresh
      _topicsFuture = _apiService.getTopicSummaries();
    });
  }

  Future<void> _showNewTopicDialog() async {
    final topicController = TextEditingController();
    final topic = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Learn Something New"),
        content: TextField(
          controller: topicController,
          autofocus: true,
          decoration: const InputDecoration(hintText: "Enter a topic..."),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              if (topicController.text.isNotEmpty) {
                Navigator.of(context).pop(topicController.text);
              }
            },
            child: const Text("Start"),
          ),
        ],
      ),
    );

    if (topic != null && topic.isNotEmpty && mounted) {
      // --- THIS IS THE UPDATED PART ---
      // The assessment flow will now return the topic name if generation starts
      final String? generatingTopicName = await Navigator.push<String>(
        context,
        MaterialPageRoute(builder: (context) => AssessmentScreen(topic: topic)),
      );
      if (generatingTopicName != null) {
        setState(() {
          _generatingTopic = generatingTopicName;
        });
        // After a delay, refresh the topics list to show the new course
        Future.delayed(const Duration(seconds: 45), _fetchTopics);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Luma'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_rounded, size: 30),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen())),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewTopicDialog,
        icon: const Icon(Icons.add),
        label: const Text("Learn New Topic"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ThemedBackground(
        child: RefreshIndicator(
          onRefresh: () async => _fetchTopics(),
          child: FutureBuilder<List<TopicSummary>>(
            future: _topicsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting && _generatingTopic == null) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading topics: ${snapshot.error}'));
              }
              
              final topics = snapshot.data ?? [];

              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: topics.length + (_generatingTopic != null ? 1 : 0),
                itemBuilder: (context, index) {
                  // If a topic is generating, show its card at the top
                  if (_generatingTopic != null && index == 0) {
                    return GeneratingTopicCard(topicName: _generatingTopic!);
                  }
                  final topicIndex = _generatingTopic != null ? index - 1 : index;
                  final topic = topics[topicIndex];
                  return TopicCard(
                    topic: topic,
                    persistenceService: _persistenceService,
                    onNavigate: _fetchTopics,
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class TopicCard extends StatelessWidget {
  const TopicCard({super.key, required this.topic, required this.persistenceService, required this.onNavigate});
  final TopicSummary topic;
  final PersistenceService persistenceService;
  final VoidCallback onNavigate;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => TopicDetailScreen(topicId: topic.id, topicName: topic.name)))
              .then((_) => onNavigate());
        },
        child: Row(
          children: [
            SizedBox(
              width: 120,
              height: 120,
              child: (topic.imageUrl != null && topic.imageUrl!.isNotEmpty)
                  ? Image.network(topic.imageUrl!, fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.school, size: 50, color: Colors.grey.shade600))
                  : Container(color: Colors.grey.shade800, child: Icon(Icons.school, size: 50, color: Colors.grey.shade600)),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (topic.category != null)
                      Text(topic.category!.toUpperCase(), style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
                    const SizedBox(height: 4),
                    Text(topic.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: FutureBuilder<int>(
                future: persistenceService.getUnlockedLevel(topic.id),
                builder: (context, snapshot) {
                  final completed = snapshot.data ?? 0;
                  return TopicProgressIndicator(
                    totalObjectives: topic.totalObjectives,
                    completedObjectives: completed,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GeneratingTopicCard extends StatelessWidget {
  final String topicName;
  const GeneratingTopicCard({super.key, required this.topicName});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).colorScheme.surface.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(20),
        leading: const CircularProgressIndicator(),
        title: Text("Generating '$topicName'..."),
        subtitle: const Text("This may take a moment. The list will refresh automatically."),
      ),
    );
  }
}