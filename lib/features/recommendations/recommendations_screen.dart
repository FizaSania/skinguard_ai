import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/utils/navigation.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/layout.dart';
import '../../core/widgets/selection.dart';
import '../../models/recommendation.dart';
import '../../providers/scan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import 'recommendation_loader.dart';

class RecommendationsScreen extends StatelessWidget {
  const RecommendationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RecommendationLoader(builder: (context, bundle) {
      final hasResult = context.watch<ScanProvider>().latestResult != null;
      final top = bundle.isEmpty ? null : bundle.recommendations.first;

      return PageLayout(
        bottom: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              label: 'View Product',
              onPressed: top == null
                  ? null
                  : () => Navigator.pushNamed(context, AppRoutes.productDetail,
                      arguments: top.product.id),
            ),
            const SizedBox(height: AppSpacing.md),
            SecondaryButton(
              label: 'Back to Results',
              onPressed: () => backToResults(context),
            ),
          ],
        ),
        children: [
          Row(
            children: [
              Expanded(
                  child: Text('Recommended for you', style: AppTextStyles.h1)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          if (bundle.isDemo) const DemoBadge(),
          const SizedBox(height: AppSpacing.lg),
          if (!hasResult) ...[
            const InfoNote(
                text:
                    'No scan result yet – these are general suggestions based on your skin profile.'),
            const SizedBox(height: AppSpacing.lg),
          ],
          if (top == null)
            const EmptyState(
              icon: Icons.spa_outlined,
              title: 'No matching products',
              message:
                  'Every demo product conflicts with your allergies or skin profile.',
            )
          else
            _RecommendationCard(rec: top),
          const SizedBox(height: AppSpacing.xl),
          const SectionTitle('Ingredients to look for'),
          if (bundle.ingredientsToLookFor.isEmpty)
            Text('—', style: AppTextStyles.bodySecondary)
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final i in bundle.ingredientsToLookFor)
                  TagChip.positive(label: i),
              ],
            ),
          const SizedBox(height: AppSpacing.xl),
          const SectionTitle('Ingredients to avoid',
              subtitle: 'Based on the allergies you selected.'),
          if (bundle.ingredientsToAvoid.isEmpty)
            Text('No ingredient allergies selected.',
                style: AppTextStyles.bodySecondary)
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final i in bundle.ingredientsToAvoid)
                  TagChip.negative(label: i),
              ],
            ),
          if (bundle.excludedProducts.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              '${bundle.excludedProducts.length} product(s) hidden because their '
              'ingredient list matches one of your allergies.',
              style: AppTextStyles.small,
            ),
          ],
          if (bundle.recommendations.length > 1) ...[
            const SizedBox(height: AppSpacing.xl),
            const SectionTitle('More suggestions'),
            for (final rec in bundle.recommendations.skip(1))
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: AppCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                  onTap: () => Navigator.pushNamed(
                      context, AppRoutes.productDetail,
                      arguments: rec.product.id),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(rec.product.category.label.toUpperCase(),
                                style: AppTextStyles.overline),
                            Text(rec.product.name, style: AppTextStyles.title),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
          ],
          const SizedBox(height: AppSpacing.xl),
          const InfoNote(
            icon: Icons.health_and_safety_outlined,
            color: AppColors.blush,
            foreground: AppColors.clay,
            text:
                'Demo recommendations. Allergy filtering compares ingredient names only and does not '
                'guarantee a product is safe for you – always check the full label and patch-test new products.',
          ),
        ],
      );
    });
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({required this.rec});

  final Recommendation rec;

  @override
  Widget build(BuildContext context) {
    Widget field(String label, String value, {bool serif = false}) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: AppTextStyles.small),
            const SizedBox(height: 2),
            Text(value,
                style: serif
                    ? AppTextStyles.h3.copyWith(fontSize: 20)
                    : AppTextStyles.title.copyWith(fontSize: 19)),
          ],
        );

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 36,
            runSpacing: 12,
            children: [
              field('Concern', rec.concern),
              field('Category', rec.product.category.label),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          field('Product', rec.product.name, serif: true),
          const SizedBox(height: AppSpacing.lg),
          Text('Why this?', style: AppTextStyles.label.copyWith(fontSize: 16)),
          const SizedBox(height: 6),
          Text(rec.reason, style: AppTextStyles.body),
        ],
      ),
    );
  }
}
