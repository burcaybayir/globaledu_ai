import 'package:flutter/material.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';

/// Study abroad topic suggested prompts
class SuggestedPrompts extends StatelessWidget {
  const SuggestedPrompts({super.key, required this.onTap});
  final ValueChanged<String> onTap;

  static const _categories = [
    _Category(
      label: '🎓 Universities',
      color: AppColors.primary,
      prompts: [
        'What are the best universities for CS in USA?',
        'Compare MIT vs Stanford for AI programs',
        'What GPA do I need for Oxford admission?',
        'Which universities accept IELTS 6.5?',
      ],
    ),
    _Category(
      label: '💰 Scholarships',
      color: AppColors.accentGold,
      prompts: [
        'What scholarships are available for Turkish students?',
        'How do I apply for a Fulbright scholarship?',
        'List government-funded scholarships for Germany',
        'Is there financial aid for international students at Harvard?',
      ],
    ),
    _Category(
      label: '🛂 Visa',
      color: AppColors.accentMint,
      prompts: [
        'What documents do I need for a UK student visa?',
        'How long does US F-1 visa processing take?',
        'Can I work while on a student visa in Canada?',
        'What is the Schengen student visa process?',
      ],
    ),
    _Category(
      label: '📝 IELTS/TOEFL',
      color: AppColors.secondary,
      prompts: [
        'How to improve IELTS writing from band 6 to 7?',
        'IELTS vs TOEFL — which is easier?',
        'Best IELTS preparation strategies for band 8',
        'How many times can I take TOEFL?',
      ],
    ),
    _Category(
      label: '🏠 Accommodation',
      color: AppColors.accent,
      prompts: [
        'Is on-campus or off-campus housing cheaper in London?',
        'Average rent for students in Berlin?',
        'Tips for finding student housing in Canada',
        'What is student accommodation like in Australia?',
      ],
    ),
    _Category(
      label: '💼 Career',
      color: AppColors.primaryLight,
      prompts: [
        'Best countries for post-study work visa?',
        'How to get a job in Germany after graduation?',
        'OPT extension rules for STEM graduates',
        'Top career paths for international CS graduates',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'What can I help with?',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap a topic to get started',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (_, i) => _CategorySection(
                category: _categories[i],
                onTap: onTap,
              ),
              childCount: _categories.length,
            ),
          ),
        ),
      ],
    );
  }
}

class _Category {
  const _Category({
    required this.label,
    required this.color,
    required this.prompts,
  });
  final String label;
  final Color color;
  final List<String> prompts;
}

class _CategorySection extends StatefulWidget {
  const _CategorySection({required this.category, required this.onTap});
  final _Category category;
  final ValueChanged<String> onTap;

  @override
  State<_CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends State<_CategorySection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = widget.category;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(c.label, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const Spacer(),
                  Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded) ...[
            const Divider(height: 1),
            ...c.prompts.map((p) => _PromptTile(
                  prompt: p,
                  color: c.color,
                  onTap: () => widget.onTap(p),
                )),
          ],
        ],
      ),
    );
  }
}

class _PromptTile extends StatelessWidget {
  const _PromptTile({required this.prompt, required this.color, required this.onTap});
  final String prompt;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                prompt,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 12,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
