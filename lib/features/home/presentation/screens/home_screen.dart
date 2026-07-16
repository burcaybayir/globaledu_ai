import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:globaledu_ai/core/router/route_names.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';
import 'package:globaledu_ai/core/widgets/cards/glass_card.dart';
import 'package:globaledu_ai/features/auth/presentation/providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isDark = context.isDarkMode;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // ─── App Bar ───
          SliverAppBar(
            expandedHeight: 0,
            floating: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello ${user.valueOrNull?.displayName?.split(' ').first ?? ''}! 👋',
                  style: context.textTheme.titleLarge,
                ),
                Text(
                  'Let\'s continue your journey',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => context.pushNamed(RouteNames.notifications),
                icon: Badge(
                  smallSize: 8,
                  child: const Icon(Icons.notifications_outlined),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ─── Journey Progress ───
                _JourneyProgressCard(),
                const SizedBox(height: AppSpacing.xl),

                // ─── Quick Actions ───
                Text('Quick Actions',
                    style: context.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                _QuickActionsGrid(),
                const SizedBox(height: AppSpacing.xl),

                // ─── AI Insight ───
                _AiInsightCard(),
                const SizedBox(height: AppSpacing.xl),

                // ─── Upcoming Deadlines ───
                Text('Upcoming Deadlines',
                    style: context.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                _DeadlineItem(
                  title: 'MIT Application Deadline',
                  date: 'Jan 15, 2026',
                  daysLeft: 12,
                  color: AppColors.error,
                ),
                const SizedBox(height: AppSpacing.sm),
                _DeadlineItem(
                  title: 'IELTS Exam',
                  date: 'Feb 3, 2026',
                  daysLeft: 31,
                  color: AppColors.warning,
                ),
                const SizedBox(height: AppSpacing.sm),
                _DeadlineItem(
                  title: 'Oxford Scholarship',
                  date: 'Mar 1, 2026',
                  daysLeft: 57,
                  color: AppColors.success,
                ),
                const SizedBox(height: AppSpacing.huge),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _JourneyProgressCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Your Journey',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                ),
                child: const Text(
                  '35%',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
            child: LinearProgressIndicator(
              value: 0.35,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'Research → Application → Documents → Visa',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: AppSpacing.md,
      crossAxisSpacing: AppSpacing.md,
      childAspectRatio: 1.5,
      children: [
        _QuickActionCard(
          icon: Icons.auto_awesome,
          label: 'Ask AI',
          gradient: AppColors.primaryGradient,
          onTap: () => context.go(
            '${RouteNames.shellPath}/${RouteNames.aiChatPath}',
          ),
        ),
        _QuickActionCard(
          icon: Icons.school_rounded,
          label: 'Universities',
          gradient: AppColors.secondaryGradient,
          onTap: () => context.go(
            '${RouteNames.shellPath}/${RouteNames.universitiesPath}',
          ),
        ),
        _QuickActionCard(
          icon: Icons.emoji_events_rounded,
          label: 'Scholarships',
          gradient: AppColors.accentGradient,
          onTap: () => context.pushNamed(RouteNames.scholarships),
        ),
        _QuickActionCard(
          icon: Icons.flight_takeoff_rounded,
          label: 'Visa Guide',
          gradient: AppColors.goldGradient,
          onTap: () {},
        ),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: AppSpacing.sm),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiInsightCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              child: const Icon(Icons.lightbulb_rounded,
                  color: Colors.white, size: 24),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Insight',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    'Based on your profile, consider applying to TU Munich — your GPA and field match their requirements perfectly!',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeadlineItem extends StatelessWidget {
  const _DeadlineItem({
    required this.title,
    required this.date,
    required this.daysLeft,
    required this.color,
  });

  final String title;
  final String date;
  final int daysLeft;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 4,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(title, style: context.textTheme.titleSmall),
        subtitle: Text(date, style: context.textTheme.bodySmall),
        trailing: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
          ),
          child: Text(
            '$daysLeft days',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
