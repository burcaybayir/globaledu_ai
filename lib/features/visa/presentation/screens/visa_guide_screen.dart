import 'package:flutter/material.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';

class VisaGuideScreen extends StatelessWidget {
  const VisaGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visa Guide'),
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded), onPressed: () => Navigator.of(context).pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
        children: [
          Text('Select Your Destination', style: context.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('Get country-specific visa guidance', style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.xxl),
          _CountryVisaCard(country: 'United States', visaType: 'F-1 Student Visa', icon: '🇺🇸', processingTime: '3-5 months', difficulty: 'High'),
          _CountryVisaCard(country: 'United Kingdom', visaType: 'Tier 4 Student Visa', icon: '🇬🇧', processingTime: '3-4 weeks', difficulty: 'Medium'),
          _CountryVisaCard(country: 'Germany', visaType: 'Student Visa (§16b)', icon: '🇩🇪', processingTime: '6-12 weeks', difficulty: 'Medium'),
          _CountryVisaCard(country: 'Canada', visaType: 'Study Permit', icon: '🇨🇦', processingTime: '4-16 weeks', difficulty: 'Medium'),
          _CountryVisaCard(country: 'Australia', visaType: 'Subclass 500', icon: '🇦🇺', processingTime: '4-6 weeks', difficulty: 'Low'),
          _CountryVisaCard(country: 'Netherlands', visaType: 'MVV + VVR', icon: '🇳🇱', processingTime: '2-3 months', difficulty: 'Low'),
        ],
      ),
    );
  }
}

class _CountryVisaCard extends StatelessWidget {
  const _CountryVisaCard({required this.country, required this.visaType, required this.icon, required this.processingTime, required this.difficulty});
  final String country;
  final String visaType;
  final String icon;
  final String processingTime;
  final String difficulty;

  Color get _difficultyColor => difficulty == 'High' ? AppColors.error : difficulty == 'Medium' ? AppColors.warning : AppColors.success;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(country, style: context.textTheme.titleSmall),
                    Text(visaType, style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant)),
                    const SizedBox(height: AppSpacing.xs),
                    Row(children: [
                      Icon(Icons.schedule, size: 14, color: context.colorScheme.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(processingTime, style: const TextStyle(fontSize: 12)),
                      const SizedBox(width: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(color: _difficultyColor.withOpacity(0.1), borderRadius: BorderRadius.circular(AppSpacing.radiusRound)),
                        child: Text(difficulty, style: TextStyle(fontSize: 11, color: _difficultyColor, fontWeight: FontWeight.w600)),
                      ),
                    ]),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}
