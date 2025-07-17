// lib/models/topic_summary.dart

enum TopicStatus {
  GENERATING,
  READY,
  UNKNOWN, // A fallback for safety
}

class TopicSummary {
  final String id;
  final String name;
  final String? description;
  final String? imageUrl;
  final String? category;
  final int totalObjectives;
  final TopicStatus status; // New field

  TopicSummary({
    required this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.category,
    required this.totalObjectives,
    required this.status,
  });

  static TopicStatus _statusFromString(String? statusString) {
    if (statusString == 'GENERATING') {
      return TopicStatus.GENERATING;
    }
    if (statusString == 'READY') {
      return TopicStatus.READY;
    }
    return TopicStatus.UNKNOWN;
  }

  factory TopicSummary.fromJson(Map<String, dynamic> json) {
    return TopicSummary(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      category: json['category'],
      totalObjectives: json['totalObjectives'] ?? 0,
      status: _statusFromString(json['status']), // New field
    );
  }
}