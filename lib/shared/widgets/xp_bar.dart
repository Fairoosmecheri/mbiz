import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// A labelled XP progress bar: "Level N" + fill + "x / y XP".
class XpBar extends StatelessWidget {
  const XpBar({
    super.key,
    required this.level,
    required this.xpIntoLevel,
    required this.xpForNextLevel,
    required this.progress,
    this.compact = false,
  });

  final int level;
  final int xpIntoLevel;
  final int xpForNextLevel;
  final double progress;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(
              'Level $level',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: compact ? 14 : 16,
              ),
            ),
            Text(
              '$xpIntoLevel / $xpForNextLevel XP',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: compact ? 12 : 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: compact ? 8 : 12,
            backgroundColor: AppColors.xp.withValues(alpha: 0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.xp),
          ),
        ),
      ],
    );
  }
}
