import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';
import 'package:globaledu_ai/core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.of(context).pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
        children: [
          // Appearance
          Text('Appearance', style: context.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                RadioListTile<ThemeMode>(
                  title: const Text('System'),
                  value: ThemeMode.system,
                  groupValue: themeMode,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Light'),
                  value: ThemeMode.light,
                  groupValue: themeMode,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v!),
                ),
                RadioListTile<ThemeMode>(
                  title: const Text('Dark'),
                  value: ThemeMode.dark,
                  groupValue: themeMode,
                  onChanged: (v) => ref.read(themeModeProvider.notifier).setThemeMode(v!),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Notifications
          Text('Notifications', style: context.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                SwitchListTile(title: const Text('Push Notifications'), value: true, onChanged: (v) {}),
                SwitchListTile(title: const Text('Deadline Reminders'), value: true, onChanged: (v) {}),
                SwitchListTile(title: const Text('AI Tips'), value: true, onChanged: (v) {}),
                SwitchListTile(title: const Text('Email Notifications'), value: false, onChanged: (v) {}),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Data & Privacy
          Text('Data & Privacy', style: context.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Card(
            child: Column(
              children: [
                ListTile(title: const Text('Privacy Policy'), trailing: const Icon(Icons.chevron_right_rounded, size: 20), onTap: () {}),
                ListTile(title: const Text('Terms of Service'), trailing: const Icon(Icons.chevron_right_rounded, size: 20), onTap: () {}),
                ListTile(title: const Text('Delete Account'), trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  textColor: AppColors.error, onTap: () {}),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),

          // App Info
          Center(child: Text('GlobalEdu AI v1.0.0', style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant))),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }
}
