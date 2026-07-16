import 'package:flutter/material.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';

class InterviewPrepScreen extends StatelessWidget {
  const InterviewPrepScreen({super.key, required this.country});
  final String country;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$country Interview Prep'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.of(context).pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
        children: [
          _SectionCard(icon: Icons.help_outline_rounded, title: 'Common Questions', color: AppColors.primary, items: [
            'Why do you want to study in the US?',
            'Which university have you been accepted to?',
            'How will you fund your education?',
            'What are your plans after graduation?',
            'Why did you choose this program?',
          ]),
          _SectionCard(icon: Icons.check_circle_outline, title: 'Do\'s', color: AppColors.success, items: [
            'Be confident and honest',
            'Make eye contact with the officer',
            'Bring all required documents organized',
            'Arrive 15 minutes early',
            'Dress professionally',
          ]),
          _SectionCard(icon: Icons.cancel_outlined, title: 'Don\'ts', color: AppColors.error, items: [
            'Don\'t memorize answers — speak naturally',
            'Don\'t lie or provide false information',
            'Don\'t mention immigration intent',
            'Don\'t bring unnecessary documents',
            'Don\'t be nervous — stay calm',
          ]),
          const SizedBox(height: AppSpacing.xl),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Practice with AI Mock Interview'),
            style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(AppSpacing.buttonHeight)),
          ),
          const SizedBox(height: AppSpacing.huge),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.icon, required this.title, required this.color, required this.items});
  final IconData icon;
  final String title;
  final Color color;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Text(title, style: context.textTheme.titleMedium),
            ]),
            const SizedBox(height: AppSpacing.md),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('• ', style: TextStyle(color: color, fontWeight: FontWeight.w700)),
                Expanded(child: Text(item, style: context.textTheme.bodyMedium?.copyWith(height: 1.4))),
              ]),
            )),
          ],
        ),
      ),
    );
  }
}
