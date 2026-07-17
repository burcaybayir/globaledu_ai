import 'package:flutter/material.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/widgets/section_header.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  static const _steps = [
    _StepData(
      phase: 'Research',
      title: 'Explore Universities',
      desc: 'Research programs, rankings, and admission requirements.',
      icon: Icons.search_rounded,
      gradient: AppColors.primaryGradient,
      done: true,
      tasks: ['Profile assessment', 'University shortlisting', 'Program comparison'],
      doneTasks: 3,
    ),
    _StepData(
      phase: 'Preparation',
      title: 'Prepare Documents',
      desc: 'Collect transcripts, recommendation letters, and write your SOP.',
      icon: Icons.description_rounded,
      gradient: AppColors.skyGradient,
      done: true,
      tasks: ['Transcripts', 'LORs', 'CV / Resume', 'SOP Draft'],
      doneTasks: 3,
    ),
    _StepData(
      phase: 'Language Tests',
      title: 'Take Required Tests',
      desc: 'IELTS/TOEFL for English, GRE/GMAT if required.',
      icon: Icons.quiz_rounded,
      gradient: AppColors.mintGradient,
      done: true,
      tasks: ['IELTS/TOEFL', 'GRE/GMAT', 'Other requirements'],
      doneTasks: 2,
    ),
    _StepData(
      phase: 'Applications',
      title: 'Submit Applications',
      desc: 'Apply to your shortlisted universities before deadlines.',
      icon: Icons.send_rounded,
      gradient: AppColors.goldGradient,
      done: false,
      tasks: ['Online applications', 'Pay fees', 'Track submissions'],
      doneTasks: 1,
    ),
    _StepData(
      phase: 'Scholarships',
      title: 'Apply for Funding',
      desc: 'Search and apply for scholarships and financial aid.',
      icon: Icons.card_giftcard_rounded,
      gradient: AppColors.sunsetGradient,
      done: false,
      tasks: ['Merit scholarships', 'Government grants', 'University funding'],
      doneTasks: 0,
    ),
    _StepData(
      phase: 'Visa',
      title: 'Visa Application',
      desc: 'Prepare and submit your student visa application.',
      icon: Icons.flight_takeoff_rounded,
      gradient: AppColors.accentGradient,
      done: false,
      tasks: ['Acceptance letter', 'Financial proof', 'Visa interview', 'Submit application'],
      doneTasks: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedSteps = _steps.where((s) => s.done).length;
    final progress = completedSteps / _steps.length;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            title: Text('Study Roadmap', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
          ),

          // ── Progress summary ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Overall Progress',
                            style: TextStyle(color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '$completedSteps of ${_steps.length} phases complete',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation(Colors.white),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Timeline ─────────────────────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => _TimelineStep(
                  data: _steps[i],
                  isLast: i == _steps.length - 1,
                ),
                childCount: _steps.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepData {
  const _StepData({
    required this.phase,
    required this.title,
    required this.desc,
    required this.icon,
    required this.gradient,
    required this.done,
    required this.tasks,
    required this.doneTasks,
  });

  final String phase, title, desc;
  final IconData icon;
  final LinearGradient gradient;
  final bool done;
  final List<String> tasks;
  final int doneTasks;
}

class _TimelineStep extends StatefulWidget {
  const _TimelineStep({required this.data, required this.isLast});
  final _StepData data;
  final bool isLast;

  @override
  State<_TimelineStep> createState() => _TimelineStepState();
}

class _TimelineStepState extends State<_TimelineStep> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final d = widget.data;
    final taskPct = d.tasks.isEmpty ? 0.0 : d.doneTasks / d.tasks.length;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Timeline line & dot ──
          Column(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: d.done ? d.gradient : null,
                  color: d.done ? null : theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                  border: d.done ? null : Border.all(
                    color: theme.colorScheme.outline,
                    width: 2,
                  ),
                ),
                child: Icon(
                  d.done ? Icons.check_rounded : d.icon,
                  color: d.done ? Colors.white : theme.colorScheme.onSurfaceVariant,
                  size: 18,
                ),
              ),
              if (!widget.isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      gradient: d.done
                          ? d.gradient
                          : LinearGradient(
                              colors: [
                                theme.colorScheme.outlineVariant,
                                theme.colorScheme.outlineVariant,
                              ],
                            ),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 14),

          // ── Content ──
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: d.done
                        ? d.gradient.colors.first.withOpacity(0.3)
                        : theme.colorScheme.outline.withOpacity(0.3),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            gradient: d.done ? d.gradient : null,
                            color: d.done ? null : theme.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Text(
                            d.phase,
                            style: TextStyle(
                              color: d.done ? Colors.white : theme.colorScheme.onSurfaceVariant,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 18,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(d.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      d.desc,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.5,
                      ),
                    ),
                    if (d.tasks.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: LinearProgressIndicator(
                                value: taskPct,
                                backgroundColor: theme.colorScheme.outlineVariant.withOpacity(0.3),
                                valueColor: AlwaysStoppedAnimation(
                                  d.done ? d.gradient.colors.first : theme.colorScheme.primary,
                                ),
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${d.doneTasks}/${d.tasks.length}',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (_expanded && d.tasks.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      ...d.tasks.asMap().entries.map((e) {
                        final completed = e.key < d.doneTasks;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  gradient: completed ? d.gradient : null,
                                  color: completed ? null : Colors.transparent,
                                  shape: BoxShape.circle,
                                  border: completed
                                      ? null
                                      : Border.all(color: theme.colorScheme.outline),
                                ),
                                child: completed
                                    ? const Icon(Icons.check_rounded, color: Colors.white, size: 12)
                                    : null,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                e.value,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  decoration: completed ? TextDecoration.lineThrough : null,
                                  color: completed
                                      ? theme.colorScheme.onSurfaceVariant
                                      : theme.colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
