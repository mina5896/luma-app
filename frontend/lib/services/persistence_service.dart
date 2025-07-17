import 'dart:convert';
import 'package:luma/models/review_item.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  static const String _totalXpKey = 'total_xp';
  static const String _lastSessionDateKey = 'last_session_date';
  static const String _streakKey = 'streak';
  static const String _completedTopicsKey = 'completed_topics'; // New key
  static const String _userNameKey = 'user_name';
  static const String _avatarIdKey = 'avatar_id';
  // New key for review items
  static const String _reviewItemsKey = 'review_items';

 // --- NEW: Spaced Repetition Methods ---

  // Schedules a question for review after an incorrect answer
  Future<void> scheduleForReview(String questionId) async {
    final allItems = await getReviewItems();
    // Remove any existing review for this question to avoid duplicates
    allItems.removeWhere((item) => item.questionId == questionId);
    
    // Add the new review item, scheduled for 1 day from now
    final newItem = ReviewItem(
      questionId: questionId,
      nextReviewDate: DateTime.now().add(const Duration(days: 1)),
      level: 1, // Start at SRS level 1
    );
    allItems.add(newItem);
    await _saveReviewItems(allItems);
  }
  
  // Updates a review item after it has been reviewed
  Future<void> updateReviewItem(String questionId, bool answeredCorrectly) async {
    final allItems = await getReviewItems();
    final itemIndex = allItems.indexWhere((item) => item.questionId == questionId);

    if (itemIndex != -1) {
      final item = allItems[itemIndex];
      if (answeredCorrectly) {
        // Correct answer: Increase SRS level and schedule for later
        final newLevel = item.level + 1;
        final nextReview = DateTime.now().add(_getDurationForLevel(newLevel));
        allItems[itemIndex] = ReviewItem(
          questionId: questionId,
          nextReviewDate: nextReview,
          level: newLevel,
        );
      } else {
        // Incorrect answer: Reset SRS level and schedule for tomorrow
        allItems[itemIndex] = ReviewItem(
          questionId: questionId,
          nextReviewDate: DateTime.now().add(const Duration(days: 1)),
          level: 1,
        );
      }
      await _saveReviewItems(allItems);
    }
  }

  // Helper to determine the next review duration based on SRS level
  Duration _getDurationForLevel(int level) {
    switch (level) {
      case 1: return const Duration(days: 1);
      case 2: return const Duration(days: 3);
      case 3: return const Duration(days: 7);
      case 4: return const Duration(days: 14);
      case 5: return const Duration(days: 30);
      default: return const Duration(days: 60);
    }
  }

  Future<List<ReviewItem>> getReviewItems() async {
    final prefs = await SharedPreferences.getInstance();
    final itemsAsJson = prefs.getStringList(_reviewItemsKey) ?? [];
    return itemsAsJson.map((itemJson) => ReviewItem.fromJson(json.decode(itemJson))).toList();
  }

  Future<void> _saveReviewItems(List<ReviewItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> itemsAsJson = items.map((item) => json.encode(item.toJson())).toList();
    await prefs.setStringList(_reviewItemsKey, itemsAsJson);
  }

  Future<List<ReviewItem>> getDueReviewItems() async {
    final allItems = await getReviewItems();
    final now = DateTime.now();
    return allItems.where((item) => item.nextReviewDate.isBefore(now)).toList();
  }

  // --- Unlocked Level Methods (unchanged) ---
  Future<void> saveUnlockedLevel(String topicId, int level) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('unlocked_level_$topicId', level);
  }

  Future<int> getUnlockedLevel(String topicId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('unlocked_level_$topicId') ?? 0;
  }

  // --- Total XP Methods (unchanged) ---
  Future<void> addXp(int xpToAdd) async {
    final prefs = await SharedPreferences.getInstance();
    final currentXp = prefs.getInt(_totalXpKey) ?? 0;
    await prefs.setInt(_totalXpKey, currentXp + xpToAdd);
  }

  Future<int> getTotalXp() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_totalXpKey) ?? 0;
  }

  // --- Daily Streak Methods (unchanged) ---
  Future<int> updateAndGetStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final lastSessionString = prefs.getString(_lastSessionDateKey);
    int currentStreak = prefs.getInt(_streakKey) ?? 0;

    if (lastSessionString != null) {
      final lastSessionDate = DateTime.parse(lastSessionString);
      final difference = today.difference(lastSessionDate).inDays;

      if (difference == 1) {
        currentStreak++;
      } else if (difference > 1) {
        currentStreak = 1;
      }
    } else {
      currentStreak = 1;
    }

    await prefs.setString(_lastSessionDateKey, today.toIso8601String());
    await prefs.setInt(_streakKey, currentStreak);
    return currentStreak;
  }

  // --- NEW: Completed Topics Methods ---
  Future<void> completeTopic(String topicId) async {
    final prefs = await SharedPreferences.getInstance();
    final completed = prefs.getStringList(_completedTopicsKey) ?? [];
    if (!completed.contains(topicId)) {
      completed.add(topicId);
      await prefs.setStringList(_completedTopicsKey, completed);
    }
  }

  Future<List<String>> getCompletedTopics() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_completedTopicsKey) ?? [];
  }

  Future<void> saveProfile(String name, int avatarId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userNameKey, name);
    await prefs.setInt(_avatarIdKey, avatarId);
  }

  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userNameKey) ?? 'Luma Learner'; // Default name
  }

  Future<int> getAvatarId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_avatarIdKey) ?? 0; // Default avatar index
  }
}