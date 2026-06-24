import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../shared/widgets/avatar_view.dart';
import '../../shared/widgets/xp_bar.dart';
import '../achievements/achievements_provider.dart';
import '../statistics/statistics_screen.dart';
import 'profile_notifier.dart';

/// The Profile tab: identity, level/XP, economy and quick links to statistics,
/// the shop and achievements. The username and avatar are editable here.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final achievements = ref.watch(achievementSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: <Widget>[
          Center(
            child: Column(
              children: <Widget>[
                GestureDetector(
                  onTap: () => _pickAvatar(context, ref),
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: <Widget>[
                      AvatarView(avatarId: profile.avatarId, size: 96),
                      const CircleAvatar(
                        radius: 14,
                        backgroundColor: AppColors.primary,
                        child: Icon(Icons.edit_rounded,
                            size: 15, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(profile.username,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined, size: 18),
                      onPressed: () => _editUsername(context, ref),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: XpBar(
                level: profile.level,
                xpIntoLevel: profile.xpIntoLevel,
                xpForNextLevel: profile.xpForNextLevel,
                progress: profile.levelProgress,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              _MiniStat(
                  icon: Icons.monetization_on_rounded,
                  label: 'Coins',
                  value: '${profile.coins}',
                  color: AppColors.coin),
              _MiniStat(
                  icon: Icons.sports_esports_rounded,
                  label: 'Played',
                  value: '${profile.gamesPlayed}',
                  color: AppColors.primary),
              _MiniStat(
                  icon: Icons.workspace_premium_rounded,
                  label: 'Awards',
                  value: '${achievements.unlocked}/${achievements.total}',
                  color: AppColors.accent),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            child: Column(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.bar_chart_rounded),
                  title: const Text('Statistics'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        builder: (_) => const StatisticsScreen()),
                  ),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.store_rounded),
                  title: const Text('Shop'),
                  subtitle: const Text('Avatars, themes & Remove Ads'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/shop'),
                ),
                const Divider(height: 0),
                ListTile(
                  leading: const Icon(Icons.settings_rounded),
                  title: const Text('Settings'),
                  trailing: const Icon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/settings'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _editUsername(BuildContext context, WidgetRef ref) {
    final controller =
        TextEditingController(text: ref.read(profileProvider).username);
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Edit username'),
        content: TextField(
          controller: controller,
          maxLength: 16,
          decoration: const InputDecoration(hintText: 'Your name'),
        ),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              ref.read(profileProvider.notifier).setUsername(controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _pickAvatar(BuildContext context, WidgetRef ref) {
    final owned = ref.read(profileProvider).ownedAvatars;
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('Choose your avatar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: <Widget>[
                for (final String id in AvatarView.allAvatarIds)
                  GestureDetector(
                    onTap: owned.contains(id)
                        ? () {
                            ref
                                .read(profileProvider.notifier)
                                .setAvatar(id);
                            Navigator.pop(context);
                          }
                        : null,
                    child: Opacity(
                      opacity: owned.contains(id) ? 1 : 0.35,
                      child: AvatarView(avatarId: id, size: 60),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Locked avatars are available in the Shop',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: <Widget>[
              Icon(icon, color: color),
              const SizedBox(height: 6),
              Text(value,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}
