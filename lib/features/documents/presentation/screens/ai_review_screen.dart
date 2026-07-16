import 'package:flutter/material.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';
import 'package:globaledu_ai/core/widgets/indicators/loading_indicator.dart';

class AiReviewScreen extends StatelessWidget {
  const AiReviewScreen({super.key, required this.documentId});
  final String documentId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Document Review'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Document info
            Card(
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(color: Colors.red.withOpacity(0.1), borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: Colors.red),
                ),
                title: Text('Statement_of_Purpose.pdf', style: context.textTheme.titleSmall),
                subtitle: const Text('245 KB • Uploaded Nov 15, 2025'),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Overall Assessment
            _ReviewSection(
              icon: Icons.grade_rounded,
              title: 'Overall Assessment',
              color: AppColors.success,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                    decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(AppSpacing.radiusRound)),
                    child: const Text('Good', style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w700, fontSize: 16)),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Text('Score: 78/100', style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),

            // Strengths
            _ReviewSection(
              icon: Icons.thumb_up_rounded,
              title: 'Strengths',
              color: AppColors.success,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BulletPoint('Clear articulation of research interests'),
                  _BulletPoint('Strong connection between past experience and future goals'),
                  _BulletPoint('Well-structured narrative flow'),
                ],
              ),
            ),

            // Improvements
            _ReviewSection(
              icon: Icons.lightbulb_outline_rounded,
              title: 'Areas for Improvement',
              color: AppColors.warning,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BulletPoint('Add specific faculty names you want to work with'),
                  _BulletPoint('Strengthen the opening paragraph with a hook'),
                  _BulletPoint('Include measurable achievements (GPA, publications)'),
                  _BulletPoint('Address "Why this university?" more specifically'),
                ],
              ),
            ),

            // Action Items
            _ReviewSection(
              icon: Icons.checklist_rounded,
              title: 'Action Items',
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ActionItem('1. Research 2-3 faculty members and mention them'),
                  _ActionItem('2. Rewrite the introduction paragraph'),
                  _ActionItem('3. Add quantifiable achievements'),
                  _ActionItem('4. Proofread for grammar (3 issues found)'),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  const _ReviewSection({required this.icon, required this.title, required this.color, required this.child});
  final IconData icon;
  final String title;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: AppSpacing.sm),
            Text(title, style: context.textTheme.titleMedium),
          ]),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('• ', style: TextStyle(fontSize: 16)),
        Expanded(child: Text(text, style: context.textTheme.bodyMedium?.copyWith(height: 1.5))),
      ]),
    );
  }
}

class _ActionItem extends StatelessWidget {
  const _ActionItem(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(text, style: context.textTheme.bodyMedium?.copyWith(height: 1.5, fontWeight: FontWeight.w500)),
    );
  }
}
