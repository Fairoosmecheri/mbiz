import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import 'settings_notifier.dart';

/// The Settings screen: audio/haptics toggles, theme selection, and legal
/// links. Every toggle persists immediately via [SettingsNotifier].
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: <Widget>[
          const _SectionLabel('Audio & Haptics'),
          SwitchListTile(
            secondary: const Icon(Icons.music_note_rounded),
            title: const Text('Music'),
            value: settings.musicEnabled,
            onChanged: notifier.toggleMusic,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.volume_up_rounded),
            title: const Text('Sound Effects'),
            value: settings.soundEnabled,
            onChanged: notifier.toggleSound,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.vibration_rounded),
            title: const Text('Vibration'),
            value: settings.vibrationEnabled,
            onChanged: notifier.toggleVibration,
          ),
          const _SectionLabel('Appearance'),
          RadioListTile<ThemeMode>(
            secondary: const Icon(Icons.brightness_auto_rounded),
            title: const Text('System default'),
            value: ThemeMode.system,
            groupValue: settings.themeMode,
            onChanged: (m) => notifier.setThemeMode(m!),
          ),
          RadioListTile<ThemeMode>(
            secondary: const Icon(Icons.light_mode_rounded),
            title: const Text('Light'),
            value: ThemeMode.light,
            groupValue: settings.themeMode,
            onChanged: (m) => notifier.setThemeMode(m!),
          ),
          RadioListTile<ThemeMode>(
            secondary: const Icon(Icons.dark_mode_rounded),
            title: const Text('Dark'),
            value: ThemeMode.dark,
            groupValue: settings.themeMode,
            onChanged: (m) => notifier.setThemeMode(m!),
          ),
          const _SectionLabel('About'),
          ListTile(
            leading: const Icon(Icons.privacy_tip_rounded),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.open_in_new_rounded, size: 18),
            onTap: () => _info(context, 'Privacy Policy',
                'Your gameplay data is stored locally on your device. When a backend is connected, only your username, avatar and scores are shared for leaderboards.'),
          ),
          ListTile(
            leading: const Icon(Icons.description_rounded),
            title: const Text('Terms of Service'),
            trailing: const Icon(Icons.open_in_new_rounded, size: 18),
            onTap: () => _info(context, 'Terms of Service',
                'Pocket Arcade is provided as-is for entertainment. Virtual coins and items have no monetary value and are non-refundable.'),
          ),
          const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
              child: Text('${AppConstants.appName} v${AppConstants.appVersion}',
                  style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }

  void _info(BuildContext context, String title, String body) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: SingleChildScrollView(child: Text(body)),
        actions: <Widget>[
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close')),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
