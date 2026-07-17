import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/widgets/section_header.dart';
import 'package:globaledu_ai/core/widgets/glass_card.dart';

class BudgetPlannerScreen extends StatefulWidget {
  const BudgetPlannerScreen({super.key});

  @override
  State<BudgetPlannerScreen> createState() => _BudgetPlannerScreenState();
}

class _BudgetPlannerScreenState extends State<BudgetPlannerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  String _selectedCountry = 'USA';

  static const _countries = ['USA', 'UK', 'Germany', 'Canada', 'Australia'];

  static const _categories = [
    _BudgetItem(label: 'Tuition', amount: 45000, color: AppColors.primary, icon: Icons.school_rounded),
    _BudgetItem(label: 'Housing', amount: 15000, color: AppColors.secondary, icon: Icons.home_rounded),
    _BudgetItem(label: 'Food', amount: 6000, color: AppColors.accentMint, icon: Icons.restaurant_rounded),
    _BudgetItem(label: 'Transport', amount: 2400, color: AppColors.accentGold, icon: Icons.directions_bus_rounded),
    _BudgetItem(label: 'Misc', amount: 3600, color: AppColors.accent, icon: Icons.more_horiz_rounded),
  ];

  double get _total => _categories.fold(0, (s, c) => s + c.amount);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..forward();
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: Text('Budget Planner', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
          ),

          // ── Country selector ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 44,
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: _countries.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final active = _countries[i] == _selectedCountry;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCountry = _countries[i]),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        gradient: active ? AppColors.primaryGradient : null,
                        color: active ? null : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        _countries[i],
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: active ? Colors.white : theme.colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Donut chart ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _anim,
                      builder: (_, __) => SizedBox(
                        height: 200,
                        width: 200,
                        child: CustomPaint(
                          painter: _DonutPainter(
                            items: _categories,
                            total: _total,
                            progress: _anim.value,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'Total',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                Text(
                                  '\$${(_total / 1000).toStringAsFixed(1)}k',
                                  style: theme.textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'per year',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Legend
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: _categories.map((c) {
                        final pct = (c.amount / _total * 100).round();
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: c.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${c.label} $pct%',
                              style: theme.textTheme.labelSmall,
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Category breakdown ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
              child: SectionHeader(title: 'Cost Breakdown'),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) {
                  final item = _categories[i];
                  final pct = item.amount / _total;
                  return AnimatedBuilder(
                    animation: _anim,
                    builder: (_, __) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: item.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(item.icon, color: item.color, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(item.label, style: theme.textTheme.titleSmall),
                              ),
                              Text(
                                '\$${(item.amount / 12).round()}/mo',
                                style: theme.textTheme.titleSmall?.copyWith(
                                  color: item.color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: LinearProgressIndicator(
                              value: pct * _anim.value,
                              backgroundColor: item.color.withOpacity(0.12),
                              valueColor: AlwaysStoppedAnimation(item.color),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _categories.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BudgetItem {
  const _BudgetItem({
    required this.label,
    required this.amount,
    required this.color,
    required this.icon,
  });

  final String label;
  final double amount;
  final Color color;
  final IconData icon;
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.items,
    required this.total,
    required this.progress,
  });

  final List<_BudgetItem> items;
  final double total;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    const strokeWidth = 28.0;
    var startAngle = -math.pi / 2;

    for (final item in items) {
      final sweep = (item.amount / total) * 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweep - 0.03,
        false,
        Paint()
          ..color = item.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.butt,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(_DonutPainter old) => old.progress != progress;
}
