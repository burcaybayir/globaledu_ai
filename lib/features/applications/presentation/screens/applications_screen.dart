import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:globaledu_ai/core/router/route_names.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';

class ApplicationsScreen extends StatelessWidget {
  const ApplicationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: Text('My Applications', style: context.textTheme.headlineMedium),
            actions: [
              IconButton(
                icon: const Icon(Icons.filter_list_rounded),
                onPressed: () {},
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _ApplicationCard(
                  university: 'MIT',
                  program: 'MSc Computer Science',
                  status: 'Under Review',
                  statusColor: AppColors.warning,
                  deadline: 'Jan 15, 2026',
                  progress: 0.75,
                  onTap: () => context.pushNamed(RouteNames.applicationDetail,
                      pathParameters: {'id': 'app_1'}),
                ),
                _ApplicationCard(
                  university: 'University of Oxford',
                  program: 'MSc Data Science',
                  status: 'Preparing',
                  statusColor: AppColors.statusPreparing,
                  deadline: 'Feb 1, 2026',
                  progress: 0.3,
                  onTap: () => context.pushNamed(RouteNames.applicationDetail,
                      pathParameters: {'id': 'app_2'}),
                ),
                _ApplicationCard(
                  university: 'ETH Zurich',
                  program: 'MSc Robotics',
                  status: 'Submitted',
                  statusColor: AppColors.info,
                  deadline: 'Dec 15, 2025',
                  progress: 1.0,
                  onTap: () => context.pushNamed(RouteNames.applicationDetail,
                      pathParameters: {'id': 'app_3'}),
                ),
                const SizedBox(height: AppSpacing.huge),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.pushNamed(RouteNames.createApplication),
        icon: const Icon(Icons.add_rounded),
        label: const Text('New Application'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.university,
    required this.program,
    required this.status,
    required this.statusColor,
    required this.deadline,
    required this.progress,
    required this.onTap,
  });

  final String university;
  final String program;
  final String status;
  final Color statusColor;
  final String deadline;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(university,
                        style: context.textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                    ),
                    child: Text(status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(program, style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant)),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(Icons.calendar_today_outlined, size: 14,
                      color: context.colorScheme.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text('Deadline: $deadline',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant)),
                  const Spacer(),
                  Text('${(progress * 100).toInt()}%',
                      style: context.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w600)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: context.colorScheme.outline.withOpacity(0.15),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
