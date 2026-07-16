import 'package:flutter/material.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';
import 'package:globaledu_ai/core/widgets/buttons/gradient_button.dart';

class UniversityDetailScreen extends StatelessWidget {
  const UniversityDetailScreen({super.key, required this.universityId});
  final String universityId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back_ios_new_rounded,
                    color: Colors.white, size: 18),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black26,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.bookmark_outline_rounded,
                      color: Colors.white, size: 18),
                ),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppColors.primaryGradient,
                ),
                child: const Center(
                  child: Icon(Icons.school_rounded,
                      color: Colors.white38, size: 80),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Name & Location
                Text('Massachusetts Institute of Technology',
                    style: context.textTheme.headlineMedium),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 16, color: context.colorScheme.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text('Cambridge, MA, United States',
                        style: context.textTheme.bodyMedium?.copyWith(
                          color: context.colorScheme.onSurfaceVariant,
                        )),
                  ],
                ),
                const SizedBox(height: AppSpacing.xl),

                // Stats Row
                Row(
                  children: [
                    _StatBadge(label: 'World Rank', value: '#1', color: AppColors.goldGradient.colors.first),
                    const SizedBox(width: AppSpacing.md),
                    _StatBadge(label: 'Acceptance', value: '3.9%', color: AppColors.accent),
                    const SizedBox(width: AppSpacing.md),
                    _StatBadge(label: 'Students', value: '11.5K', color: AppColors.secondary),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),

                // About
                Text('About', style: context.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'The Massachusetts Institute of Technology (MIT) is a private research university in Cambridge, Massachusetts. Founded in 1861, MIT has played a key role in the development of modern technology and science.',
                  style: context.textTheme.bodyMedium?.copyWith(
                    height: 1.6,
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),

                // Tuition
                Text('Tuition & Fees', style: context.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                _InfoRow(label: 'Undergraduate', value: '\$57,590/year'),
                _InfoRow(label: 'Graduate', value: '\$55,450/year'),
                _InfoRow(label: 'Living Costs', value: '~\$20,000/year'),
                const SizedBox(height: AppSpacing.xxl),

                // Programs
                Text('Popular Programs', style: context.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                _ProgramChip('Computer Science & Engineering'),
                _ProgramChip('Electrical Engineering'),
                _ProgramChip('Mechanical Engineering'),
                _ProgramChip('Mathematics'),
                _ProgramChip('Physics'),
                _ProgramChip('Business Analytics'),
                const SizedBox(height: AppSpacing.xxl),

                // Requirements
                Text('Requirements', style: context.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                _InfoRow(label: 'GPA', value: '3.8+ recommended'),
                _InfoRow(label: 'TOEFL', value: '100+ (iBT)'),
                _InfoRow(label: 'IELTS', value: '7.0+'),
                _InfoRow(label: 'GRE', value: 'Recommended'),
                const SizedBox(height: AppSpacing.xxl),

                // Deadlines
                Text('Application Deadlines', style: context.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.md),
                _InfoRow(label: 'Fall Semester', value: 'January 1'),
                _InfoRow(label: 'Spring Semester', value: 'September 15'),
                const SizedBox(height: AppSpacing.xxxl),

                // Actions
                GradientButton(
                  text: 'Start Application',
                  icon: Icons.edit_document,
                  onPressed: () {},
                ),
                const SizedBox(height: AppSpacing.md),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Ask AI About This University'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(AppSpacing.buttonHeight),
                  ),
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

class _StatBadge extends StatelessWidget {
  const _StatBadge({required this.label, required this.value, required this.color});
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: 18)),
            const SizedBox(height: 2),
            Text(label, style: context.textTheme.labelSmall?.copyWith(
              color: context.colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: context.textTheme.bodyMedium?.copyWith(
            color: context.colorScheme.onSurfaceVariant)),
          Text(value, style: context.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _ProgramChip extends StatelessWidget {
  const _ProgramChip(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Chip(
        label: Text(label, style: const TextStyle(fontSize: 13)),
        avatar: const Icon(Icons.bookmark_outline, size: 16),
      ),
    );
  }
}
