import 'package:flutter/material.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';

class ScholarshipsScreen extends StatelessWidget {
  const ScholarshipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scholarships'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.of(context).pop()),
        actions: [IconButton(icon: const Icon(Icons.tune_rounded), onPressed: () {})],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
        children: [
          _ScholarshipCard(name: 'Fulbright Scholarship', provider: 'U.S. Department of State', amount: 'Full tuition + stipend', deadline: 'Oct 15, 2026', matchScore: 92, country: '🇺🇸'),
          _ScholarshipCard(name: 'DAAD Scholarship', provider: 'German Academic Exchange', amount: '€934/month', deadline: 'Nov 30, 2026', matchScore: 85, country: '🇩🇪'),
          _ScholarshipCard(name: 'Chevening Scholarship', provider: 'UK Government', amount: 'Full tuition + living', deadline: 'Nov 3, 2026', matchScore: 78, country: '🇬🇧'),
          _ScholarshipCard(name: 'Erasmus Mundus', provider: 'European Commission', amount: '€1,400/month', deadline: 'Jan 10, 2026', matchScore: 72, country: '🇪🇺'),
          _ScholarshipCard(name: 'Australia Awards', provider: 'Australian Government', amount: 'Full tuition + stipend', deadline: 'Apr 30, 2026', matchScore: 65, country: '🇦🇺'),
        ],
      ),
    );
  }
}

class _ScholarshipCard extends StatelessWidget {
  const _ScholarshipCard({required this.name, required this.provider, required this.amount, required this.deadline, required this.matchScore, required this.country});
  final String name;
  final String provider;
  final String amount;
  final String deadline;
  final int matchScore;
  final String country;

  Color get _matchColor => matchScore >= 80 ? AppColors.success : matchScore >= 60 ? AppColors.warning : AppColors.accent;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(country, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: context.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(provider, style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  // Match score
                  Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: _matchColor.withOpacity(0.1)),
                    child: Center(child: Text('$matchScore%', style: TextStyle(color: _matchColor, fontWeight: FontWeight.w700, fontSize: 13))),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  _InfoChip(icon: Icons.attach_money_rounded, label: amount),
                  const SizedBox(width: AppSpacing.sm),
                  _InfoChip(icon: Icons.calendar_today_outlined, label: deadline),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(color: context.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(AppSpacing.radiusRound)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 14, color: context.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: context.colorScheme.onSurfaceVariant)),
      ]),
    );
  }
}
