import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/features/universities/domain/entities/recommendation_filters.dart';
import 'package:globaledu_ai/features/universities/domain/entities/university_recommendation.dart';
import 'package:globaledu_ai/features/universities/presentation/providers/recommendation_provider.dart';

class UniversityRecommendationScreen extends ConsumerStatefulWidget {
  const UniversityRecommendationScreen({super.key});

  @override
  ConsumerState<UniversityRecommendationScreen> createState() =>
      _UniversityRecommendationScreenState();
}

class _UniversityRecommendationScreenState
    extends ConsumerState<UniversityRecommendationScreen>
    with TickerProviderStateMixin {
  late AnimationController _staggerCtrl;

  @override
  void initState() {
    super.initState();
    _staggerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _staggerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recommendationProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Trigger animation when results arrive
    ref.listen<RecommendationState>(recommendationProvider, (prev, next) {
      if (prev?.status == RecommendationStatus.loading &&
          next.status == RecommendationStatus.success) {
        _staggerCtrl.forward(from: 0);
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0A0A1A), const Color(0xFF12122A)]
                : [const Color(0xFFF0EFFF), const Color(0xFFE8F4FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(theme, state),
              if (state.hasResults) _buildFilterBar(theme, state),
              Expanded(child: _buildBody(theme, state)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, RecommendationState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.outline.withOpacity(0.2),
                ),
              ),
              child: const Center(
                child: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.isLoading
                      ? '✨ Finding your matches...'
                      : '🎓 Your Recommendations',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 19,
                  ),
                ),
                if (state.hasResults)
                  Text(
                    '${state.filteredResults.length} universities found',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (state.hasResults)
            GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, color: Colors.white, size: 14),
                    SizedBox(width: 4),
                    Text('Re-run',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(ThemeData theme, RecommendationState state) {
    final filters = state.filters;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Sort + scholarship toggle row
          Row(
            children: [
              const Icon(Icons.sort_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Expanded(
                child: SizedBox(
                  height: 32,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<RecommendationSortBy>(
                      value: filters.sortBy,
                      isDense: true,
                      isExpanded: true,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      items: RecommendationSortBy.values
                          .map((s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.label),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          ref
                              .read(recommendationProvider.notifier)
                              .updateFilters(filters.copyWith(sortBy: v));
                        }
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _FilterChip(
                label: '🎓 Scholarships',
                isSelected: filters.scholarshipOnly,
                onTap: () {
                  ref.read(recommendationProvider.notifier).updateFilters(
                        filters.copyWith(
                            scholarshipOnly: !filters.scholarshipOnly),
                      );
                },
              ),
            ],
          ),
          // Country filter chips
          if (state.availableCountries.length > 1) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 28,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: state.availableCountries.length,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final country = state.availableCountries[index];
                  final isSelected =
                      filters.selectedCountries.contains(country);
                  return _FilterChip(
                    label: country,
                    isSelected: isSelected,
                    onTap: () {
                      final updated =
                          List<String>.from(filters.selectedCountries);
                      if (isSelected) {
                        updated.remove(country);
                      } else {
                        updated.add(country);
                      }
                      ref
                          .read(recommendationProvider.notifier)
                          .updateFilters(
                              filters.copyWith(selectedCountries: updated));
                    },
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(ThemeData theme, RecommendationState state) {
    if (state.isLoading) return _buildLoadingState(theme);
    if (state.hasError) return _buildErrorState(theme, state);
    if (state.hasResults) return _buildResultsList(theme, state);
    return _buildEmptyState(theme);
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _PulsingOrb(),
          const SizedBox(height: 24),
          Text(
            'Analyzing your profile...',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Our AI is finding the best universities for you',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          // Shimmer cards
          ...List.generate(3, (i) => _ShimmerCard(delay: i * 200)),
        ],
      ),
    );
  }

  Widget _buildErrorState(ThemeData theme, RecommendationState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text('😔', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error ?? 'Please try again',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Go Back & Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(
            'No recommendations yet',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Go back and fill in your preferences',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(ThemeData theme, RecommendationState state) {
    final results = state.filteredResults;

    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔎', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            Text('No results match your filters',
                style: theme.textTheme.titleSmall),
            TextButton(
              onPressed: () => ref
                  .read(recommendationProvider.notifier)
                  .updateFilters(const RecommendationFilters()),
              child: const Text('Clear all filters'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final uni = results[index];
        return _AnimatedCardEntry(
          index: index,
          controller: _staggerCtrl,
          child: _UniversityRecommendationCard(uni: uni),
        );
      },
    );
  }
}

// ─── Recommendation Card ──────────────────────────────────────────────────────

class _UniversityRecommendationCard extends StatelessWidget {
  const _UniversityRecommendationCard({required this.uni});
  final UniversityRecommendation uni;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final scoreColor = switch (uni.scoreCategory) {
      'high' => AppColors.success,
      'medium' => AppColors.warning,
      _ => AppColors.error,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.06)
            : Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: scoreColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: scoreColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header row: flag, name, score ring
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Text(uni.flag, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        uni.name,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${uni.city.isNotEmpty ? "${uni.city}, " : ""}${uni.country} · Rank #${uni.ranking}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _ScoreRing(score: uni.universityScore, color: scoreColor),
              ],
            ),
          ),

          // Progress bars: acceptance + employment
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _ProgressRow(
                  label: 'Acceptance',
                  value: uni.acceptanceProbability,
                  color: AppColors.secondary,
                ),
                const SizedBox(height: 6),
                _ProgressRow(
                  label: 'Employment',
                  value: uni.employmentRate,
                  color: AppColors.accentMint,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Stats chips row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                _StatChip(icon: '💰', label: uni.estimatedTuition),
                _StatChip(icon: '🏠', label: uni.livingExpenses),
                if (uni.hasScholarship)
                  _StatChip(
                    icon: '🎓',
                    label: uni.scholarshipAvailability,
                    highlight: true,
                  ),
                _StatChip(icon: '📅', label: uni.applicationDeadline),
                _StatChip(icon: '🌡️', label: uni.climate),
              ],
            ),
          ),

          // Match reason
          if (uni.matchReason.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡', style: TextStyle(fontSize: 12)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      uni.matchReason,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.primary,
                        height: 1.4,
                        fontSize: 11,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 14),
        ],
      ),
    );
  }
}

// ─── Score Ring ────────────────────────────────────────────────────────────────

class _ScoreRing extends StatelessWidget {
  const _ScoreRing({required this.score, required this.color});
  final int score;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(52, 52),
            painter: _RingPainter(
              progress: score / 100,
              color: color,
              trackColor: color.withOpacity(0.15),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  color: color,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '/100',
                style: TextStyle(
                  color: color.withOpacity(0.6),
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.trackColor,
  });

  final double progress;
  final Color color;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 3;

    // Track
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..color = trackColor,
    );

    // Progress arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round
        ..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

// ─── Progress Row ─────────────────────────────────────────────────────────────

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: color.withOpacity(0.12),
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 32,
          child: Text(
            '$value%',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Stat Chip ────────────────────────────────────────────────────────────────

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.label,
    this.highlight = false,
  });

  final String icon;
  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.accentMint.withOpacity(0.12)
            : isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.grey.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: highlight
            ? Border.all(color: AppColors.accentMint.withOpacity(0.3))
            : null,
      ),
      child: Text(
        '$icon  $label',
        style: TextStyle(
          fontSize: 11,
          fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
          color: highlight
              ? AppColors.accentMint
              : Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Theme.of(context).colorScheme.outline.withOpacity(0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Colors.white
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

// ─── Animated Card Entry ──────────────────────────────────────────────────────

class _AnimatedCardEntry extends StatelessWidget {
  const _AnimatedCardEntry({
    required this.index,
    required this.controller,
    required this.child,
  });

  final int index;
  final AnimationController controller;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final start = (index * 0.08).clamp(0.0, 0.6);
    final end = (start + 0.4).clamp(0.0, 1.0);

    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Interval(start, end, curve: Curves.easeOutCubic),
    ));

    final fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(start, end, curve: Curves.easeOut),
      ),
    );

    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) => Opacity(
        opacity: fadeAnim.value,
        child: SlideTransition(
          position: slideAnim,
          child: child,
        ),
      ),
    );
  }
}

// ─── Pulsing Orb (loading state) ──────────────────────────────────────────────

class _PulsingOrb extends StatefulWidget {
  @override
  State<_PulsingOrb> createState() => _PulsingOrbState();
}

class _PulsingOrbState extends State<_PulsingOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) {
        final scale = 0.8 + 0.2 * _ctrl.value;
        final opacity = 0.3 + 0.4 * _ctrl.value;
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.primaryGradient,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(opacity),
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Center(
              child: Text('✨', style: TextStyle(fontSize: 32)),
            ),
          ),
        );
      },
    );
  }
}

// ─── Shimmer Card ─────────────────────────────────────────────────────────────

class _ShimmerCard extends StatefulWidget {
  const _ShimmerCard({this.delay = 0});
  final int delay;

  @override
  State<_ShimmerCard> createState() => _ShimmerCardState();
}

class _ShimmerCardState extends State<_ShimmerCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmer;

  @override
  void initState() {
    super.initState();
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _shimmer.repeat();
    });
  }

  @override
  void dispose() {
    _shimmer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? Colors.white.withOpacity(0.05)
        : Colors.grey.withOpacity(0.1);

    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, _) => Container(
        height: 100,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: ShaderMask(
          shaderCallback: (bounds) {
            final offset = _shimmer.value * 2 - 0.5;
            return LinearGradient(
              begin: Alignment(-1 + offset * 2, 0),
              end: Alignment(offset * 2, 0),
              colors: [
                Colors.transparent,
                Colors.white.withOpacity(0.1),
                Colors.transparent,
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
      ),
    );
  }
}
