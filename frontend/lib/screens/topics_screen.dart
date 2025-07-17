import 'package:flutter/material.dart';
import 'package:luma/models/topic_summary.dart';
import 'package:luma/screens/new_topic_screen.dart';
import 'package:luma/screens/profile_screen.dart';
import 'package:luma/screens/topic_detail_screen.dart';
import 'package:luma/services/api_service.dart';
import 'package:luma/services/persistence_service.dart';
import 'package:luma/widgets/themed_background.dart';
import 'package:luma/widgets/topic_progress_indicator.dart';
import 'package:luma/widgets/lesson/luma_mascot.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  Future<List<TopicSummary>>? _topicsFuture;
  final ApiService _apiService = ApiService();
  final PersistenceService _persistenceService = PersistenceService();

  @override
  void initState() {
    super.initState();
    _fetchTopics();
  }

  void _fetchTopics() {
    setState(() {
      _topicsFuture = _apiService.getTopicSummaries();
    });
  }

  Future<void> _navigateToNewTopicScreen() async {
    // This will trigger the backend generation.
    // When we come back, we'll refresh the list.
    await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const NewTopicScreen()),
    );
    _fetchTopics();
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
              Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()))
                  .then((_) => _fetchTopics()); // Refresh on return from profile
            },
          )
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToNewTopicScreen,
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
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error loading topics: ${snapshot.error}'));
              }
              
              final topics = snapshot.data ?? [];
              
              if (topics.isEmpty) {
                return const _EmptyStateView();
              }

              // Sort topics to show "GENERATING" ones at the top
              topics.sort((a, b) {
                if (a.status == TopicStatus.GENERATING) return -1;
                if (b.status == TopicStatus.GENERATING) return 1;
                return a.name.compareTo(b.name);
              });

              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // Padding for FAB
                itemCount: topics.length,
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  // Use the status from the backend to decide which card to show
                  if (topic.status == TopicStatus.GENERATING) {
                    return GeneratingTopicCard(topicName: topic.name);
                  } else {
                    return TopicCard(
                      topic: topic,
                      persistenceService: _persistenceService,
                      onNavigate: _fetchTopics,
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _EmptyStateView extends StatelessWidget {
  const _EmptyStateView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LumaMascot(state: MascotState.happy),
          const SizedBox(height: 24),
          Text(
            "Your learning journey starts here!",
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              "Tap the '+' button below to create your first personalized course.",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
          ),
        ],
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
        subtitle: const Text("This may take a moment. You can pull down to refresh."),
      ),
    );
  }
}