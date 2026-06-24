import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// Renders an avatar by id. Avatars are emoji-based so the app ships with zero
/// image assets while still feeling personalised; swap the map for image assets
/// later without touching call sites.
class AvatarView extends StatelessWidget {
  const AvatarView({super.key, required this.avatarId, this.size = 48});

  final String avatarId;
  final double size;

  static const Map<String, String> _emoji = <String, String>{
    'avatar_01': '🐱',
    'avatar_02': '🦊',
    'avatar_03': '🐼',
    'avatar_04': '🦁',
    'avatar_05': '🐸',
    'avatar_06': '🐙',
    'avatar_07': '🦄',
    'avatar_08': '🐲',
  };

  static List<String> get allAvatarIds => _emoji.keys.toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        _emoji[avatarId] ?? '🎮',
        style: TextStyle(fontSize: size * 0.55),
      ),
    );
  }
}
