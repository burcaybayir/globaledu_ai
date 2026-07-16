import 'package:flutter/material.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';
import 'package:globaledu_ai/core/widgets/buttons/gradient_button.dart';

class ScholarshipDetailScreen extends StatelessWidget {
  const ScholarshipDetailScreen({super.key, required this.scholarshipId});
  final String scholarshipId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scholarship Detail'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.of(context).pop()),
        actions: [IconButton(icon: const Icon(Icons.bookmark_outline_rounded), onPressed: () {})],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🇺🇸', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: AppSpacing.md),
            Text('Fulbright Scholarship', style: context.textTheme.headlineMedium),
            Text('U.S. Department of State', style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.xxl),
            Text('Full tuition coverage + monthly stipend + travel costs + health insurance', style: context.textTheme.bodyLarge?.copyWith(height: 1.6)),
            const SizedBox(height: AppSpacing.xxl),
            Text('Requirements', style: context.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            _Requirement('Bachelor\'s degree or equivalent'),
            _Requirement('Strong academic record'),
            _Requirement('English language proficiency'),
            _Requirement('2+ years work experience (preferred)'),
            _Requirement('Leadership experience'),
            const SizedBox(height: AppSpacing.xxl),
            GradientButton(text: 'Apply Now', icon: Icons.open_in_new_rounded, onPressed: () {}),
            const SizedBox(height: AppSpacing.md),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Check My Eligibility with AI'),
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(AppSpacing.buttonHeight)),
            ),
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }
}

class _Requirement extends StatelessWidget {
  const _Requirement(this.text);
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(children: [
        const Icon(Icons.check_circle_outline, size: 18, color: Colors.green),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text, style: context.textTheme.bodyMedium)),
      ]),
    );
  }
}
