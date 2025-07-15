import 'package:flutter/material.dart';
import 'package:luma/screens/edit_profile_screen.dart';
import 'package:luma/services/persistence_service.dart';
import 'package:luma/widgets/avatar_picker.dart'; // Import to get access to the avatar and color lists
import 'package:luma/widgets/themed_background.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final PersistenceService _persistenceService = PersistenceService();
  String _userName = '';
  int _avatarId = 0;
  int _totalXp = 0;
  int _streak = 0;
  List<String> _completedTopics = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final results = await Future.wait([
      _persistenceService.getUserName(),
      _persistenceService.getAvatarId(),
      _persistenceService.getTotalXp(),
      _persistenceService.updateAndGetStreak(),
      _persistenceService.getCompletedTopics(),
    ]);

    if (mounted) {
      setState(() {
        _userName = results[0] as String;
        _avatarId = results[1] as int;
        _totalXp = results[2] as int;
        _streak = results[3] as int;
        _completedTopics = results[4] as List<String>;
        _isLoading = false;
      });
    }
  }

  Map<String, dynamic> _calculateLevelInfo(int totalXp) {
    int level = 1;
    int xpForNextLevel = 100;
    int cumulativeXpForCurrentLevel = 0;

    while (totalXp >= cumulativeXpForCurrentLevel + xpForNextLevel) {
      cumulativeXpForCurrentLevel += xpForNextLevel;
      level++;
      xpForNextLevel += 50;
    }

    final int xpIntoCurrentLevel = totalXp - cumulativeXpForCurrentLevel;
    final double progress =
        xpForNextLevel > 0 ? xpIntoCurrentLevel / xpForNextLevel : 0.0;

    return {
      'level': level,
      'xpProgress': progress,
      'xpForCurrentLevel': xpIntoCurrentLevel,
      'xpForNextLevel': xpForNextLevel,
    };
  }

  @override
  Widget build(BuildContext context) {
    final levelInfo = _calculateLevelInfo(_totalXp);
    final int level = levelInfo['level'];
    final double xpProgress = levelInfo['xpProgress'];
    final int xpForCurrentLevel = levelInfo['xpForCurrentLevel'];
    final int xpForNextLevel = levelInfo['xpForNextLevel'];
    
    // --- THIS IS THE UPDATED PART ---
    // Get the correct color for the selected avatar
    final Color avatarColor = avatarColors[_avatarId % avatarColors.length];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Profile"),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final bool? profileWasUpdated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (context) => const EditProfileScreen()),
              );
              if (profileWasUpdated == true) {
                _loadStats();
              }
            },
          ),
        ],
      ),
      body: ThemedBackground(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Column(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: avatarColor.withOpacity(0.2), // Use the avatar's color
                        child: Icon(
                          LumaAvatars[_avatarId],
                          size: 50,
                          color: avatarColor, // Use the avatar's color
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _userName,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Level $level",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    elevation: 4,
                    color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                            Text("Next Level Progress", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold)),
                            Text("$xpForCurrentLevel / $xpForNextLevel XP", style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                          ]),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: xpProgress,
                            minHeight: 12,
                            borderRadius: BorderRadius.circular(6),
                            backgroundColor: Colors.grey.shade800,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.amber.shade700),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _StatCard(
                    icon: Icons.local_fire_department_rounded,
                    label: 'Current Streak',
                    value: '$_streak Days',
                    color: Colors.orange.shade800,
                  ),
                  const SizedBox(height: 32),
                  Text(
                    "Achievements",
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_completedTopics.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(20.0), child: Text("Complete your first topic to earn a badge!")))
                  else
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4, crossAxisSpacing: 12, mainAxisSpacing: 12),
                      itemCount: _completedTopics.length,
                      itemBuilder: (context, index) {
                        return const _AchievementBadge();
                      },
                    )
                ],
              ),
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  const _AchievementBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.15),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.green.shade300, width: 2),
      ),
      child: Icon(Icons.school_rounded, color: Colors.green.shade300, size: 40),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  const _StatCard(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, size: 32, color: color),
          ),
          const SizedBox(width: 20),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(color: Colors.white70)),
                Text(value,
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ])
        ],
      ),
    );
  }
}