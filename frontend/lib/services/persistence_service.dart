import 'package:shared_preferences/shared_preferences.dart';

class PersistenceService {
  static const String _totalXpKey = 'total_xp';
  static const String _lastSessionDateKey = 'last_session_date';
  static const String _streakKey = 'streak';
  static const String _completedTopicsKey = 'completed_topics'; // New key
  static const String _userNameKey = 'user_name';
  static const String _avatarIdKey = 'avatar_id';

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