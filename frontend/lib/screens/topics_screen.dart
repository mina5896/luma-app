// lib/screens/topics_screen.dart
import 'package:flutter/material.dart';
import 'package:luma/models/topic_summary.dart';
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
  late Future<List<TopicSummary>> _topicsFuture;
  final ApiService _apiService = ApiService();
  final PersistenceService _persistenceService = PersistenceService();

  @override
  void initState() {
    super.initState();
    _topicsFuture = _apiService.getTopicSummaries();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Luma'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_rounded, size: 30),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              ).then((_) => setState(() {
                    // Refresh the topics screen to update progress when returning
                    _topicsFuture = _apiService.getTopicSummaries();
                  }));
            },
          )
        ],
      ),
      body: ThemedBackground(
        child: FutureBuilder<List<TopicSummary>>(
          future: _topicsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error loading topics: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              final topics = snapshot.data!;
              return ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  return TopicCard(
                    topic: topic,
                    persistenceService: _persistenceService,
                  );
                },
              );
            }
            return const Center(child: Text("No topics found. Run the backend to generate content."));
          },
        ),
      ),
    );
  }
}

class TopicCard extends StatelessWidget {
  const TopicCard({
    super.key,
    required this.topic,
    required this.persistenceService,
  });

  final TopicSummary topic;
  final PersistenceService persistenceService;

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
              .then((_) => (context as Element));
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
                    Text(topic.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
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