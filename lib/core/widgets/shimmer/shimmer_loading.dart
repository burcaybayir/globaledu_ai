import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';

class ShimmerLoading extends StatelessWidget {
  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppSpacing.radiusSm,
          ),
        ),
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key, this.height = 120});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ShimmerLoading(
                  width: 48,
                  height: 48,
                  borderRadius: AppSpacing.radiusMd,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerLoading(
                        width: double.infinity,
                        height: 16,
                        borderRadius: AppSpacing.radiusSm,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ShimmerLoading(
                        width: 150,
                        height: 12,
                        borderRadius: AppSpacing.radiusSm,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            ShimmerLoading(
              width: double.infinity,
              height: 12,
              borderRadius: AppSpacing.radiusSm,
            ),
            const SizedBox(height: AppSpacing.sm),
            ShimmerLoading(
              width: 200,
              height: 12,
              borderRadius: AppSpacing.radiusSm,
            ),
          ],
        ),
      ),
    );
  }
}
