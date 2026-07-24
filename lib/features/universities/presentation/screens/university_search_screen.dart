import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:globaledu_ai/core/router/route_names.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/widgets/section_header.dart';
import 'package:globaledu_ai/core/widgets/status_badge.dart';

class UniversitySearchScreen extends ConsumerStatefulWidget {
  const UniversitySearchScreen({super.key});

  @override
  ConsumerState<UniversitySearchScreen> createState() =>
      _UniversitySearchScreenState();
}

class _UniversitySearchScreenState
    extends ConsumerState<UniversitySearchScreen> {
  final _searchCtrl = TextEditingController();
  String _selectedFilter = 'All';

  static const _filters = ['All', 'USA', 'UK', 'Germany', 'Canada', 'Australia', 'Netherlands'];

  static const _universities = [
    _UniData(name: 'MIT', country: 'USA', flag: '🇺🇸', rank: 1, match: 95, tuition: '\$55,000', program: 'Computer Science', deadline: 'Jan 15', hasScholarship: true),
    _UniData(name: 'Stanford University', country: 'USA', flag: '🇺🇸', rank: 3, match: 88, tuition: '\$57,000', program: 'AI & Machine Learning', deadline: 'Jan 5', hasScholarship: true),
    _UniData(name: 'Oxford University', country: 'UK', flag: '🇬🇧', rank: 2, match: 82, tuition: '£35,000', program: 'Data Science', deadline: 'Feb 1', hasScholarship: false),
    _UniData(name: 'ETH Zurich', country: 'Switzerland', flag: '🇨🇭', rank: 7, match: 90, tuition: 'CHF 1,500', program: 'Computer Science', deadline: 'Dec 15', hasScholarship: true),
    _UniData(name: 'TU Munich', country: 'Germany', flag: '🇩🇪', rank: 50, match: 78, tuition: '€500', program: 'Robotics', deadline: 'Mar 1', hasScholarship: false),
    _UniData(name: 'University of Toronto', country: 'Canada', flag: '🇨🇦', rank: 21, match: 85, tuition: 'CAD 28,000', program: 'Software Engineering', deadline: 'Feb 15', hasScholarship: true),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ──────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            snap: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 60),
              title: Text(
                'Universities',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(52),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Search universities, programs...',
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchCtrl.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() {});
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ),

          // ── Filter Chips ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final isActive = _filters[i] == _selectedFilter;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedFilter = _filters[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: isActive ? AppColors.primaryGradient : null,
                        color: isActive ? null : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        _filters[i],
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: isActive ? Colors.white : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── AI Recommend CTA Banner ──────────────────────────────────
          SliverToBoxAdapter(
            child: GestureDetector(
              onTap: () => context.goNamed(RouteNames.recommendationInput),
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 14, 16, 4),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Center(
                        child: Text('✨', style: TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI University Finder',
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Get personalized recommendations based on your profile',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        color: Colors.white, size: 16),
                  ],
                ),
              ),
            ),
          ),

          // ── Results count ────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                '${_universities.length} universities found',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          // ── University Cards ─────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _UniversityCard(
                  data: _universities[i],
                  onTap: () => context.goNamed(RouteNames.universityDetail, pathParameters: {'id': i.toString()}),
                ),
                childCount: _universities.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _UniData {
  const _UniData({
    required this.name,
    required this.country,
    required this.flag,
    required this.rank,
    required this.match,
    required this.tuition,
    required this.program,
    required this.deadline,
    required this.hasScholarship,
  });

  final String name, country, flag, tuition, program, deadline;
  final int rank, match;
  final bool hasScholarship;
}

class _UniversityCard extends StatelessWidget {
  const _UniversityCard({required this.data, required this.onTap});

  final _UniData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final matchColor = data.match >= 85
        ? AppColors.matchHigh
        : data.match >= 70
            ? AppColors.matchMedium
            : AppColors.matchLow;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.4)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Flag circle
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(child: Text(data.flag, style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.name,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${data.country} · Rank #${data.rank}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                // Match ring
                Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: matchColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        '${data.match}% match',
                        style: TextStyle(
                          color: matchColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Tags row
            Row(
              children: [
                _InfoChip(icon: Icons.book_outlined, label: data.program),
                const SizedBox(width: 8),
                _InfoChip(icon: Icons.attach_money_rounded, label: data.tuition),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.calendar_today_rounded,
                  label: 'Deadline: ${data.deadline}',
                  color: AppColors.warning,
                ),
                if (data.hasScholarship) ...[
                  const SizedBox(width: 8),
                  _InfoChip(
                    icon: Icons.card_giftcard_rounded,
                    label: 'Scholarship',
                    color: AppColors.accentMint,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label, this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final c = color ?? theme.colorScheme.onSurfaceVariant;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: c),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: c,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
