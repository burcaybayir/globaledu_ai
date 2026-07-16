import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:globaledu_ai/core/router/route_names.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';
import 'package:globaledu_ai/features/auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userData = user.valueOrNull;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            title: Text('Profile', style: context.textTheme.headlineMedium),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => context.pushNamed(RouteNames.settings),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Profile Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 44,
                          backgroundColor: context.colorScheme.primaryContainer,
                          child: Text(
                            userData?.displayInitials ?? 'U',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.w700,
                              color: context.colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(userData?.displayName ?? 'User',
                            style: context.textTheme.titleLarge),
                        const SizedBox(height: AppSpacing.xs),
                        Text(userData?.email ?? '',
                            style: context.textTheme.bodySmall?.copyWith(
                              color: context.colorScheme.onSurfaceVariant)),
                        const SizedBox(height: AppSpacing.md),
                        // Subscription badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.xs),
                          decoration: BoxDecoration(
                            gradient: userData?.isPremium == true ? AppColors.goldGradient : null,
                            color: userData?.isPremium == true ? null : context.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                          ),
                          child: Text(
                            userData?.isPremium == true ? '✨ Premium' : userData?.isPro == true ? '⭐ Pro' : 'Free Plan',
                            style: TextStyle(
                              color: userData?.isPremium == true ? Colors.white : context.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        if (userData?.isFree == true) ...[
                          const SizedBox(height: AppSpacing.md),
                          TextButton(
                            onPressed: () => context.pushNamed(RouteNames.subscription),
                            child: const Text('Upgrade your plan →'),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),

                // Stats
                Row(
                  children: [
                    _StatCard(value: '3', label: 'Applications', icon: Icons.description_outlined),
                    const SizedBox(width: AppSpacing.md),
                    _StatCard(value: '8', label: 'Universities', icon: Icons.school_outlined),
                    const SizedBox(width: AppSpacing.md),
                    _StatCard(value: '5', label: 'Documents', icon: Icons.folder_outlined),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Menu items
                _MenuItem(icon: Icons.person_outline, label: 'Edit Profile', onTap: () => context.pushNamed(RouteNames.editProfile)),
                _MenuItem(icon: Icons.workspace_premium_outlined, label: 'Subscription', onTap: () => context.pushNamed(RouteNames.subscription)),
                _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () => context.pushNamed(RouteNames.notifications)),
                _MenuItem(icon: Icons.language_outlined, label: 'Language', subtitle: 'English', onTap: () {}),
                _MenuItem(icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () {}),
                _MenuItem(icon: Icons.info_outline_rounded, label: 'About', onTap: () {}),
                const SizedBox(height: AppSpacing.xl),
                _MenuItem(icon: Icons.logout_rounded, label: 'Sign Out', isDestructive: true, onTap: () {
                  ref.read(authNotifierProvider.notifier).signOut();
                }),
                const SizedBox(height: AppSpacing.huge),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label, required this.icon});
  final String value;
  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
          child: Column(
            children: [
              Icon(icon, color: context.colorScheme.primary, size: 24),
              const SizedBox(height: AppSpacing.sm),
              Text(value, style: context.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
              Text(label, style: context.textTheme.labelSmall?.copyWith(color: context.colorScheme.onSurfaceVariant)),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.icon, required this.label, required this.onTap, this.subtitle, this.isDestructive = false});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? subtitle;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? AppColors.error : null),
      title: Text(label, style: TextStyle(color: isDestructive ? AppColors.error : null)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: isDestructive ? null : const Icon(Icons.chevron_right_rounded, size: 20),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
    );
  }
}
