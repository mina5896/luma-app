// lib/models/topic_summary.dart

class TopicSummary {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? category;
  final int totalObjectives; // New field for progress

  TopicSummary({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.category,
    required this.totalObjectives,
  });

  factory TopicSummary.fromJson(Map<String, dynamic> json) {
    return TopicSummary(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      category: json['category'],
      totalObjectives: json['totalObjectives'] ?? 0,
    );
  }
}