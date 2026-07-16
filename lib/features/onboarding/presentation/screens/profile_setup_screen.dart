import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:globaledu_ai/core/config/app_config.dart';
import 'package:globaledu_ai/core/router/route_names.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/widgets/buttons/gradient_button.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  final _pageController = PageController();
  int _currentStep = 0;
  static const _totalSteps = 3;

  // Step 1: Country selection
  final List<String> _selectedCountries = [];

  // Step 2: Education level
  String? _selectedEducation;

  // Step 3: Fields of interest
  final List<String> _selectedFields = [];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep++);
    } else {
      _completeSetup();
    }
  }

  void _completeSetup() {
    // TODO: Save profile to Firestore
    context.go(RouteNames.shellPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile Setup (${_currentStep + 1}/$_totalSteps)'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeOutCubic,
                  );
                  setState(() => _currentStep--);
                },
              )
            : null,
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentStep + 1) / _totalSteps,
            backgroundColor: context.colorScheme.outline.withOpacity(0.2),
          ),

          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _CountryStep(
                  selected: _selectedCountries,
                  onChanged: (countries) {
                    setState(() {
                      _selectedCountries.clear();
                      _selectedCountries.addAll(countries);
                    });
                  },
                ),
                _EducationStep(
                  selected: _selectedEducation,
                  onChanged: (level) {
                    setState(() => _selectedEducation = level);
                  },
                ),
                _InterestsStep(
                  selected: _selectedFields,
                  onChanged: (fields) {
                    setState(() {
                      _selectedFields.clear();
                      _selectedFields.addAll(fields);
                    });
                  },
                ),
              ],
            ),
          ),

          // Next button
          Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
            child: GradientButton(
              text: _currentStep == _totalSteps - 1
                  ? 'Complete Setup'
                  : 'Continue',
              onPressed: _canContinue ? _nextStep : null,
            ),
          ),
          SizedBox(height: context.bottomPadding + AppSpacing.md),
        ],
      ),
    );
  }

  bool get _canContinue {
    switch (_currentStep) {
      case 0:
        return _selectedCountries.isNotEmpty;
      case 1:
        return _selectedEducation != null;
      case 2:
        return _selectedFields.isNotEmpty;
      default:
        return false;
    }
  }
}

class _CountryStep extends StatelessWidget {
  const _CountryStep({required this.selected, required this.onChanged});

  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text('Where do you want to study?',
              style: context.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('Select up to 5 countries',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              )),
          const SizedBox(height: AppSpacing.xxl),
          Expanded(
            child: ListView(
              children: AppConfig.supportedCountries.map((country) {
                final isSelected = selected.contains(country);
                return ListTile(
                  title: Text(country),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : const Icon(Icons.circle_outlined),
                  onTap: () {
                    final updated = List<String>.from(selected);
                    if (isSelected) {
                      updated.remove(country);
                    } else if (updated.length < 5) {
                      updated.add(country);
                    }
                    onChanged(updated);
                  },
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _EducationStep extends StatelessWidget {
  const _EducationStep({required this.selected, required this.onChanged});

  final String? selected;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text('What level are you pursuing?',
              style: context.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.xxl),
          ...AppConfig.educationLevels.map((level) {
            final isSelected = selected == level;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: ListTile(
                title: Text(level),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
                tileColor: isSelected
                    ? AppColors.primary.withOpacity(0.08)
                    : context.colorScheme.surfaceContainerHighest,
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: AppColors.primary)
                    : null,
                onTap: () => onChanged(level),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _InterestsStep extends StatelessWidget {
  const _InterestsStep({required this.selected, required this.onChanged});

  final List<String> selected;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpacing.xl),
          Text('What are you interested in?',
              style: context.textTheme.headlineMedium),
          const SizedBox(height: AppSpacing.sm),
          Text('Select your fields of study',
              style: context.textTheme.bodyMedium?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              )),
          const SizedBox(height: AppSpacing.xxl),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: AppConfig.studyFields.map((field) {
                  final isSelected = selected.contains(field);
                  return FilterChip(
                    label: Text(field),
                    selected: isSelected,
                    onSelected: (_) {
                      final updated = List<String>.from(selected);
                      if (isSelected) {
                        updated.remove(field);
                      } else {
                        updated.add(field);
                      }
                      onChanged(updated);
                    },
                    selectedColor: AppColors.primarySurface,
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
