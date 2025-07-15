import 'package:flutter/material.dart';

// A simple list of avatar icons to choose from
const List<IconData> LumaAvatars = [
  Icons.lightbulb_rounded,
  Icons.face,
  Icons.star_rounded,
  Icons.rocket_launch_rounded,
  Icons.psychology_alt_rounded,
  Icons.emoji_objects_rounded,
  Icons.android,
  Icons.flutter_dash_rounded,
];

// --- NEW: A list of vibrant colors for the avatars ---
const List<Color> avatarColors = [
  Colors.orange,
  Colors.green,
  Colors.pink,
  Colors.blue,
  Colors.teal,
  Colors.red,
  Colors.purple,
  Colors.amber,
];

class AvatarPicker extends StatelessWidget {
  final int selectedAvatarId;
  final Function(int) onAvatarSelected;

  const AvatarPicker({
    super.key,
    required this.selectedAvatarId,
    required this.onAvatarSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: LumaAvatars.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) {
        final isSelected = index == selectedAvatarId;
        // Assign a unique color to each avatar
        final color = avatarColors[index % avatarColors.length];

        return GestureDetector(
          onTap: () => onAvatarSelected(index),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              // Use the unique color for the background
              color: isSelected
                  ? color.withOpacity(0.3)
                  : color.withOpacity(0.15),
              border: Border.all(
                color: isSelected
                    ? color
                    : Colors.transparent,
                width: 3,
              ),
            ),
            child: Icon(LumaAvatars[index],
                size: 40,
                // Use the unique color for the icon
                color: isSelected
                    ? color
                    : color.withOpacity(0.8)),
          ),
        );
      },
    );
  }
}