import 'package:flutter/material.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';

class ApplicationDetailScreen extends StatelessWidget {
  const ApplicationDetailScreen({super.key, required this.applicationId});
  final String applicationId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Detail'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert_rounded), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // University info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Row(
                  children: [
                    Container(
                      width: 56, height: 56,
                      decoration: BoxDecoration(
                        color: context.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Icon(Icons.school_rounded, color: context.colorScheme.primary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('MIT', style: context.textTheme.titleMedium),
                          Text('MSc Computer Science', style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                      ),
                      child: const Text('Under Review',
                          style: TextStyle(color: AppColors.warning, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Timeline
            Text('Application Timeline', style: context.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            _TimelineItem(title: 'Application Created', date: 'Nov 1, 2025', isDone: true),
            _TimelineItem(title: 'Documents Uploaded', date: 'Nov 15, 2025', isDone: true),
            _TimelineItem(title: 'Application Submitted', date: 'Dec 1, 2025', isDone: true),
            _TimelineItem(title: 'Under Review', date: 'Dec 5, 2025', isDone: false, isActive: true),
            _TimelineItem(title: 'Decision', date: 'Expected Feb 2026', isDone: false, isLast: true),
            const SizedBox(height: AppSpacing.xxl),

            // Document Checklist
            Text('Document Checklist', style: context.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.md),
            _ChecklistItem(label: 'Transcript', isDone: true),
            _ChecklistItem(label: 'Statement of Purpose', isDone: true),
            _ChecklistItem(label: 'CV / Resume', isDone: true),
            _ChecklistItem(label: 'Recommendation Letter 1', isDone: true),
            _ChecklistItem(label: 'Recommendation Letter 2', isDone: false),
            _ChecklistItem(label: 'TOEFL Score', isDone: true),
            _ChecklistItem(label: 'GRE Score', isDone: false),
            const SizedBox(height: AppSpacing.xxl),

            // Quick Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.folder_open_rounded),
                    label: const Text('Documents'),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.flight_takeoff_rounded),
                    label: const Text('Visa Guide'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.title, required this.date, required this.isDone,
    this.isActive = false, this.isLast = false,
  });
  final String title;
  final String date;
  final bool isDone;
  final bool isActive;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Container(
                  width: 16, height: 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDone ? AppColors.success : (isActive ? AppColors.primary : context.colorScheme.outline),
                    border: isActive ? Border.all(color: AppColors.primary, width: 3) : null,
                  ),
                  child: isDone ? const Icon(Icons.check, size: 10, color: Colors.white) : null,
                ),
                if (!isLast) Expanded(
                  child: Container(width: 2, color: isDone ? AppColors.success : context.colorScheme.outline.withOpacity(0.3)),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: isActive ? FontWeight.w700 : FontWeight.w500)),
                  Text(date, style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({required this.label, required this.isDone});
  final String label;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          Icon(
            isDone ? Icons.check_circle_rounded : Icons.circle_outlined,
            color: isDone ? AppColors.success : context.colorScheme.outline,
            size: 22,
          ),
          const SizedBox(width: AppSpacing.md),
          Text(label, style: context.textTheme.bodyMedium?.copyWith(
            decoration: isDone ? TextDecoration.lineThrough : null,
            color: isDone ? context.colorScheme.onSurfaceVariant : null)),
        ],
      ),
    );
  }
}
