import 'package:flutter/material.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';
import 'package:globaledu_ai/core/widgets/buttons/gradient_button.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Subscription'),
        leading: IconButton(icon: const Icon(Icons.close_rounded), onPressed: () => Navigator.of(context).pop()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
        child: Column(
          children: [
            const SizedBox(height: AppSpacing.xl),
            // Header
            Container(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              decoration: BoxDecoration(gradient: AppColors.goldGradient, shape: BoxShape.circle),
              child: const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 48),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Unlock Premium', style: context.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.sm),
            Text('Get unlimited access to all features', style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.xxxl),

            // Plans
            _PlanCard(
              title: 'Pro',
              price: '\$9.99',
              period: '/month',
              features: ['Unlimited AI chats', '10 document reviews/mo', 'Application tracker', 'Priority support'],
              isRecommended: false,
              gradient: AppColors.secondaryGradient,
              onSelect: () {},
            ),
            const SizedBox(height: AppSpacing.lg),
            _PlanCard(
              title: 'Premium',
              price: '\$19.99',
              period: '/month',
              features: ['Everything in Pro', 'Unlimited document reviews', 'AI visa interview prep', '1-on-1 advisor matching', 'Scholarship matcher', 'Priority email support'],
              isRecommended: true,
              gradient: AppColors.goldGradient,
              onSelect: () {},
            ),
            const SizedBox(height: AppSpacing.xxl),

            // Restore
            TextButton(onPressed: () {}, child: const Text('Restore Purchases')),
            const SizedBox(height: AppSpacing.xl),
            Text('Cancel anytime. Billed monthly.', style: context.textTheme.bodySmall?.copyWith(color: context.colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.huge),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.title, required this.price, required this.period, required this.features, required this.isRecommended, required this.gradient, required this.onSelect});
  final String title;
  final String price;
  final String period;
  final List<String> features;
  final bool isRecommended;
  final Gradient gradient;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: isRecommended ? Border.all(color: AppColors.goldGradient.colors.first, width: 2) : null,
      ),
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                  if (isRecommended)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(AppSpacing.radiusRound)),
                      child: const Text('Best Value', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(price, style: context.textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w700)),
                  Text(period, style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.onSurfaceVariant)),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              const SizedBox(height: AppSpacing.md),
              ...features.map((f) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Row(children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 18),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(f, style: context.textTheme.bodyMedium)),
                ]),
              )),
              const SizedBox(height: AppSpacing.lg),
              GradientButton(text: 'Choose $title', gradient: gradient, onPressed: onSelect),
            ],
          ),
        ),
      ),
    );
  }
}
