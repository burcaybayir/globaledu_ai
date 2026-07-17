import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:globaledu_ai/core/router/route_names.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/features/universities/domain/entities/recommendation_filters.dart';
import 'package:globaledu_ai/features/universities/presentation/providers/recommendation_provider.dart';

class RecommendationInputScreen extends ConsumerStatefulWidget {
  const RecommendationInputScreen({super.key});

  @override
  ConsumerState<RecommendationInputScreen> createState() =>
      _RecommendationInputScreenState();
}

class _RecommendationInputScreenState
    extends ConsumerState<RecommendationInputScreen>
    with TickerProviderStateMixin {
  final _pageCtrl = PageController();
  int _currentPage = 0;
  static const _totalPages = 4;

  // Form state
  final Set<String> _selectedCountries = {};
  double _budgetMax = 50000;
  double _ielts = 6.5;
  double _gpa = 3.0;
  final _majorCtrl = TextEditingController();
  final _careerCtrl = TextEditingController();
  final Set<String> _selectedClimates = {};
  bool _workAfterGrad = false;

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  static const _countries = [
    ('🇺🇸', 'USA'), ('🇬🇧', 'UK'), ('🇨🇦', 'Canada'),
    ('🇦🇺', 'Australia'), ('🇩🇪', 'Germany'), ('🇳🇱', 'Netherlands'),
    ('🇸🇪', 'Sweden'), ('🇨🇭', 'Switzerland'), ('🇫🇷', 'France'),
    ('🇯🇵', 'Japan'), ('🇸🇬', 'Singapore'), ('🇳🇿', 'New Zealand'),
  ];

  static const _climates = [
    ('☀️', 'Sunny & Warm'), ('🌤️', 'Temperate'), ('❄️', 'Cold'),
    ('🌧️', 'Mild & Rainy'), ('🏜️', 'Hot & Dry'), ('🌿', 'Tropical'),
  ];

  static const _popularMajors = [
    'Computer Science', 'Data Science & AI', 'Business Administration',
    'Engineering', 'Medicine', 'Law', 'Architecture', 'Psychology',
    'Finance', 'Marketing', 'Environmental Science',
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _majorCtrl.dispose();
    _careerCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < _totalPages - 1) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _submit();
    }
  }

  void _back() {
    if (_currentPage > 0) {
      _pageCtrl.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  void _submit() {
    final prefs = RecommendationPreferences(
      countries: _selectedCountries.toList(),
      budgetMin: 0,
      budgetMax: _budgetMax,
      ieltsScore: _ielts,
      gpa: _gpa,
      major: _majorCtrl.text.trim(),
      careerGoals: _careerCtrl.text.trim(),
      climates: _selectedClimates.toList(),
      workAfterGraduation: _workAfterGrad,
    );
    ref.read(recommendationProvider.notifier).generate(prefs);
    context.goNamed(RouteNames.recommendations);
  }

  bool get _canProceed {
    switch (_currentPage) {
      case 0:
        return true; // country selection optional
      case 1:
        return true; // IELTS/GPA always valid
      case 2:
        return _majorCtrl.text.trim().isNotEmpty;
      case 3:
        return true;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

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
              _buildHeader(theme),
              _buildProgressBar(),
              Expanded(
                child: PageView(
                  controller: _pageCtrl,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (p) => setState(() => _currentPage = p),
                  children: [
                    _Step1Countries(
                      selected: _selectedCountries,
                      onToggle: (c) => setState(() {
                        if (_selectedCountries.contains(c)) {
                          _selectedCountries.remove(c);
                        } else {
                          _selectedCountries.add(c);
                        }
                      }),
                      budgetMax: _budgetMax,
                      onBudgetChanged: (v) => setState(() => _budgetMax = v),
                      countries: _countries,
                    ),
                    _Step2Scores(
                      ielts: _ielts,
                      gpa: _gpa,
                      onIeltsChanged: (v) => setState(() => _ielts = v),
                      onGpaChanged: (v) => setState(() => _gpa = v),
                    ),
                    _Step3Major(
                      majorCtrl: _majorCtrl,
                      careerCtrl: _careerCtrl,
                      popularMajors: _popularMajors,
                      onMajorSelect: (m) =>
                          setState(() => _majorCtrl.text = m),
                      onChanged: () => setState(() {}),
                    ),
                    _Step4Preferences(
                      selectedClimates: _selectedClimates,
                      onClimateToggle: (c) => setState(() {
                        if (_selectedClimates.contains(c)) {
                          _selectedClimates.remove(c);
                        } else {
                          _selectedClimates.add(c);
                        }
                      }),
                      workAfterGrad: _workAfterGrad,
                      onWorkToggle: (v) =>
                          setState(() => _workAfterGrad = v),
                      climates: _climates,
                    ),
                  ],
                ),
              ),
              _buildBottomBar(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme) {
    final titles = [
      'Where do you want to study?',
      'What are your scores?',
      'What do you want to study?',
      'Your preferences',
    ];
    final subtitles = [
      'Select countries & set your budget',
      'Your IELTS score & GPA',
      'Major, career goals & programs',
      'Climate & work opportunities',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          _GlassButton(
            onTap: _back,
            child: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titles[_currentPage],
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
                Text(
                  subtitles[_currentPage],
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_currentPage + 1}/$_totalPages',
            style: theme.textTheme.labelLarge?.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: List.generate(_totalPages, (i) {
          final isActive = i <= _currentPage;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 4,
              margin: EdgeInsets.only(right: i < _totalPages - 1 ? 6 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: isActive ? AppColors.primaryGradient : null,
                color: isActive ? null : Colors.grey.withOpacity(0.25),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBottomBar(ThemeData theme) {
    final isLast = _currentPage == _totalPages - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: AnimatedOpacity(
          opacity: _canProceed ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _canProceed ? _next : null,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLast ? '✨  Generate Recommendations' : 'Continue',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (!isLast) ...[
                        const SizedBox(width: 8),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 18),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Step 1: Countries + Budget ───────────────────────────────────────────────

class _Step1Countries extends StatelessWidget {
  const _Step1Countries({
    required this.selected,
    required this.onToggle,
    required this.budgetMax,
    required this.onBudgetChanged,
    required this.countries,
  });

  final Set<String> selected;
  final void Function(String) onToggle;
  final double budgetMax;
  final void Function(double) onBudgetChanged;
  final List<(String, String)> countries;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      children: [
        Text('Choose destinations',
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: countries.map((c) {
            final (flag, name) = c;
            final isSelected = selected.contains(name);
            return _SelectionChip(
              label: '$flag  $name',
              isSelected: isSelected,
              onTap: () => onToggle(name),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Annual Budget',
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(100),
              ),
              child: Text(
                '\$${budgetMax.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            thumbColor: AppColors.primary,
            inactiveTrackColor: AppColors.primary.withOpacity(0.15),
            trackHeight: 4,
          ),
          child: Slider(
            value: budgetMax,
            min: 5000,
            max: 100000,
            divisions: 19,
            onChanged: onBudgetChanged,
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('\$5K',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            Text('\$100K',
                style: theme.textTheme.labelSmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
          ],
        ),
        const SizedBox(height: 8),
        _InfoBox(
          icon: '💡',
          text:
              'Budget covers tuition + living expenses. Leave countries empty to search worldwide.',
        ),
      ],
    );
  }
}

// ─── Step 2: IELTS + GPA ─────────────────────────────────────────────────────

class _Step2Scores extends StatelessWidget {
  const _Step2Scores({
    required this.ielts,
    required this.gpa,
    required this.onIeltsChanged,
    required this.onGpaChanged,
  });

  final double ielts;
  final double gpa;
  final void Function(double) onIeltsChanged;
  final void Function(double) onGpaChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    String ieltsLabel() {
      if (ielts >= 8.0) return '🏆 Excellent';
      if (ielts >= 7.0) return '✅ Good';
      if (ielts >= 6.0) return '📘 Average';
      return '⚠️ Below average';
    }

    String gpaLabel() {
      if (gpa >= 3.7) return '🏆 Excellent';
      if (gpa >= 3.3) return '✅ Good';
      if (gpa >= 3.0) return '📘 Average';
      return '⚠️ Below average';
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      children: [
        _ScoreCard(
          title: 'IELTS Score',
          value: ielts.toStringAsFixed(1),
          label: ieltsLabel(),
          min: 4.0,
          max: 9.0,
          divisions: 10,
          sliderValue: ielts,
          onChanged: onIeltsChanged,
          color: AppColors.secondary,
          icon: '🌐',
          description:
              'Most universities require 6.0–7.0. Top universities often require 7.0+.',
        ),
        const SizedBox(height: 20),
        _ScoreCard(
          title: 'GPA',
          value: gpa.toStringAsFixed(1),
          label: gpaLabel(),
          min: 2.0,
          max: 4.0,
          divisions: 20,
          sliderValue: gpa,
          onChanged: onGpaChanged,
          color: AppColors.accentMint,
          icon: '🎓',
          description:
              'US scale (4.0). Top universities typically require 3.5+.',
        ),
        const SizedBox(height: 20),
        _InfoBox(
          icon: '📊',
          text:
              'Your scores help us calculate acceptance probability for each university accurately.',
        ),
      ],
    );
  }
}

// ─── Step 3: Major + Career ───────────────────────────────────────────────────

class _Step3Major extends StatelessWidget {
  const _Step3Major({
    required this.majorCtrl,
    required this.careerCtrl,
    required this.popularMajors,
    required this.onMajorSelect,
    required this.onChanged,
  });

  final TextEditingController majorCtrl;
  final TextEditingController careerCtrl;
  final List<String> popularMajors;
  final void Function(String) onMajorSelect;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      children: [
        Text('Desired major *',
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextField(
          controller: majorCtrl,
          onChanged: (_) => onChanged(),
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'e.g. Computer Science, Medicine...',
            prefixIcon:
                const Icon(Icons.school_outlined, color: AppColors.primary),
            filled: true,
          ),
        ),
        const SizedBox(height: 12),
        Text('Popular majors',
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: popularMajors.map((m) {
            final isSelected = majorCtrl.text == m;
            return _SelectionChip(
              label: m,
              isSelected: isSelected,
              onTap: () => onMajorSelect(m),
              small: true,
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text('Career goals',
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 8),
        TextField(
          controller: careerCtrl,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText:
                'e.g. Software engineer at a top tech company, research in AI, start a business...',
            prefixIcon: Icon(Icons.rocket_launch_outlined,
                color: AppColors.accentMint),
            alignLabelWithHint: true,
          ),
        ),
      ],
    );
  }
}

// ─── Step 4: Climate + Work ───────────────────────────────────────────────────

class _Step4Preferences extends StatelessWidget {
  const _Step4Preferences({
    required this.selectedClimates,
    required this.onClimateToggle,
    required this.workAfterGrad,
    required this.onWorkToggle,
    required this.climates,
  });

  final Set<String> selectedClimates;
  final void Function(String) onClimateToggle;
  final bool workAfterGrad;
  final void Function(bool) onWorkToggle;
  final List<(String, String)> climates;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      children: [
        Text('Preferred climate',
            style: theme.textTheme.labelLarge
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: climates.map((c) {
            final (icon, name) = c;
            final isSelected = selectedClimates.contains(name);
            return _SelectionChip(
              label: '$icon  $name',
              isSelected: isSelected,
              onTap: () => onClimateToggle(name),
            );
          }).toList(),
        ),
        const SizedBox(height: 28),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.05)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: workAfterGrad
                  ? AppColors.primary.withOpacity(0.5)
                  : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: workAfterGrad
                      ? AppColors.primaryGradient
                      : null,
                  color: workAfterGrad
                      ? null
                      : Colors.grey.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '💼',
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Work after graduation',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Prioritize countries with post-study work visas (UK, Canada, Australia)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Switch.adaptive(
                value: workAfterGrad,
                onChanged: onWorkToggle,
                activeColor: AppColors.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _InfoBox(
          icon: '🚀',
          text:
              'Ready to find your perfect university! Our AI will analyze ${10} universities tailored specifically to your profile.',
        ),
      ],
    );
  }
}

// ─── Shared Widgets ───────────────────────────────────────────────────────────

class _SelectionChip extends StatelessWidget {
  const _SelectionChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.small = false,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: small ? 12 : 14,
          vertical: small ? 6 : 8,
        ),
        decoration: BoxDecoration(
          gradient: isSelected ? AppColors.primaryGradient : null,
          color: isSelected
              ? null
              : theme.colorScheme.surface.withOpacity(0.8),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : theme.colorScheme.outline.withOpacity(0.3),
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : theme.colorScheme.onSurface,
            fontSize: small ? 12 : 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _ScoreCard extends StatelessWidget {
  const _ScoreCard({
    required this.title,
    required this.value,
    required this.label,
    required this.min,
    required this.max,
    required this.divisions,
    required this.sliderValue,
    required this.onChanged,
    required this.color,
    required this.icon,
    required this.description,
  });

  final String title, value, label, icon, description;
  final double min, max, sliderValue;
  final int divisions;
  final void Function(double) onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withOpacity(0.05)
            : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  value,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              )),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              inactiveTrackColor: color.withOpacity(0.15),
              trackHeight: 4,
            ),
            child: Slider(
              value: sliderValue,
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
          Text(
            description,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  const _InfoBox({required this.icon, required this.text});
  final String icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.onTap, required this.child});
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.7),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Center(child: child),
      ),
    );
  }
}
