import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:globaledu_ai/core/router/route_names.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';
import 'package:globaledu_ai/core/utils/debouncer.dart';

class UniversitySearchScreen extends StatefulWidget {
  const UniversitySearchScreen({super.key});

  @override
  State<UniversitySearchScreen> createState() => _UniversitySearchScreenState();
}

class _UniversitySearchScreenState extends State<UniversitySearchScreen> {
  final _searchController = TextEditingController();
  final _debouncer = Debouncer(duration: const Duration(milliseconds: 500));
  String _selectedCountry = 'All';
  String _selectedLevel = 'All';

  static const _mockUniversities = [
    _UniversityData('Massachusetts Institute of Technology', 'United States', 'Cambridge, MA', 1, 'assets/images/mit.png'),
    _UniversityData('University of Oxford', 'United Kingdom', 'Oxford, England', 3, 'assets/images/oxford.png'),
    _UniversityData('ETH Zurich', 'Switzerland', 'Zurich', 7, 'assets/images/eth.png'),
    _UniversityData('Technical University of Munich', 'Germany', 'Munich', 30, 'assets/images/tum.png'),
    _UniversityData('University of Toronto', 'Canada', 'Toronto, ON', 18, 'assets/images/uoft.png'),
    _UniversityData('University of Melbourne', 'Australia', 'Melbourne', 14, 'assets/images/melb.png'),
    _UniversityData('Delft University of Technology', 'Netherlands', 'Delft', 47, 'assets/images/tudelft.png'),
    _UniversityData('Seoul National University', 'South Korea', 'Seoul', 29, 'assets/images/snu.png'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _debouncer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Search Header
          SliverAppBar(
            floating: true,
            snap: true,
            expandedHeight: 130,
            flexibleSpace: FlexibleSpaceBar(
              background: Padding(
                padding: EdgeInsets.only(
                  top: context.topPadding + AppSpacing.huge,
                  left: AppSpacing.pagePaddingHorizontal,
                  right: AppSpacing.pagePaddingHorizontal,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Universities',
                        style: context.textTheme.headlineLarge),
                    const SizedBox(height: AppSpacing.md),
                    TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search universities, programs...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.tune_rounded),
                          onPressed: _showFilters,
                        ),
                      ),
                      onChanged: (value) {
                        _debouncer.call(() => setState(() {}));
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Filter chips
          SliverToBoxAdapter(
            child: SizedBox(
              height: 50,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePaddingHorizontal,
                ),
                children: [
                  _FilterChip(
                    label: _selectedCountry,
                    icon: Icons.public_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _FilterChip(
                    label: _selectedLevel,
                    icon: Icons.school_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _FilterChip(
                    label: 'Compare',
                    icon: Icons.compare_arrows_rounded,
                    isAction: true,
                    onTap: () {},
                  ),
                ],
              ),
            ),
          ),

          // Results count
          SliverPadding(
            padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
            sliver: SliverToBoxAdapter(
              child: Text(
                '${_mockUniversities.length} universities found',
                style: context.textTheme.bodySmall?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),

          // University list
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePaddingHorizontal,
            ),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final uni = _mockUniversities[index];
                  return _UniversityCard(
                    data: uni,
                    onTap: () => context.pushNamed(
                      RouteNames.universityDetail,
                      pathParameters: {'id': 'uni_$index'},
                    ),
                  );
                },
                childCount: _mockUniversities.length,
              ),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.huge),
          ),
        ],
      ),
    );
  }

  void _showFilters() {
    context.showAppBottomSheet(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppSpacing.radiusXxl),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Filters', style: context.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xxl),
            Text('Coming soon...', style: context.textTheme.bodyMedium),
            const SizedBox(height: AppSpacing.xxxl),
          ],
        ),
      ),
    );
  }
}

class _UniversityData {
  const _UniversityData(
    this.name,
    this.country,
    this.city,
    this.ranking,
    this.imageAsset,
  );
  final String name;
  final String country;
  final String city;
  final int ranking;
  final String imageAsset;
}

class _UniversityCard extends StatelessWidget {
  const _UniversityCard({required this.data, required this.onTap});
  final _UniversityData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Row(
            children: [
              // University icon/logo placeholder
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: context.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(Icons.school_rounded,
                    color: context.colorScheme.primary),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.name,
                      style: context.textTheme.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: AppSpacing.xxs),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 14,
                            color: context.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 4),
                        Text(
                          '${data.city}, ${data.country}',
                          style: context.textTheme.bodySmall?.copyWith(
                            color: context.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Ranking badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.goldGradient.colors.first.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
                ),
                child: Text(
                  '#${data.ranking}',
                  style: TextStyle(
                    color: AppColors.goldGradient.colors.first,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.icon,
    required this.onTap,
    this.isAction = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool isAction;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isAction
              ? AppColors.primary.withOpacity(0.1)
              : context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusRound),
          border: isAction
              ? Border.all(color: AppColors.primary.withOpacity(0.3))
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 16,
                color: isAction
                    ? AppColors.primary
                    : context.colorScheme.onSurfaceVariant),
            const SizedBox(width: AppSpacing.xs),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isAction
                    ? AppColors.primary
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
