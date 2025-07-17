// lib/models/review_item.dart

class ReviewItem {
  final String questionId;
  final DateTime nextReviewDate;
  final int level; // New field for SRS level

  ReviewItem({
    required this.questionId,
    required this.nextReviewDate,
    required this.level,
  });

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'nextReviewDate': nextReviewDate.toIso8601String(),
        'level': level,
      };

  factory ReviewItem.fromJson(Map<String, dynamic> json) => ReviewItem(
        questionId: json['questionId'],
        nextReviewDate: DateTime.parse(json['nextReviewDate']),
        level: json['level'] ?? 1, // Default to level 1 if missing
      );
}