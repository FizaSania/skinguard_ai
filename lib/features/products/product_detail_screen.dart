import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/illustrations.dart';
import '../../core/widgets/layout.dart';
import '../../core/widgets/selection.dart';
import '../../data/mock/mock_products.dart';
import '../../models/recommendation.dart';
import '../../providers/user_provider.dart';
import '../../services/recommendation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../recommendations/recommendation_loader.dart';

/// Product details with ingredient, allergy and recommendation information.
/// Sections appear only when their data is available.
// FUTURE BACKEND INTEGRATION: fetch the product by id from the catalogue
// API instead of MockProducts. Price, reasoning, stage, doctor advice,
// conflicts and pairings already come through RecommendationService.
class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({super.key, required this.productId});

  final String productId;

  @override
  Widget build(BuildContext context) {
    final product = MockProducts.byId(productId);
    if (product == null) {
      return const PageLayout(children: [
        EmptyState(
            icon: Icons.search_off,
            title: 'Product not found',
            message: 'This product is no longer available.'),
      ]);
    }

    return RecommendationLoader(builder: (context, bundle) {
      final profile = context.watch<UserProvider>().profile;
      final matches = MockRecommendationService.matchingAllergies(
          product, profile.allergies,
          reactionProduct: profile.reactionProduct);
      final recommendation = bundle.forProduct(productId);
      final doctorAdvice = bundle.doctorAdvice;
      const sectionGap = SizedBox(height: AppSpacing.xl);

      return PageLayout(
        children: [
          Center(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              decoration: BoxDecoration(
                color: Color.lerp(product.accentColor, AppColors.surface, 0.85),
                borderRadius: BorderRadius.circular(AppRadius.xl),
              ),
              child: Column(
                children: [
                  ProductBottle(color: product.accentColor, height: 130),
                  const SizedBox(height: 8),
                  Text('Illustration – product image placeholder',
                      style: AppTextStyles.small),
                ],
              ),
            ),
          ),
          sectionGap,
          Text(product.category.label.toUpperCase(),
              style: AppTextStyles.overline),
          const SizedBox(height: 4),
          Text(product.name, style: AppTextStyles.h1),
          const SizedBox(height: AppSpacing.sm),
          const DemoBadge(label: 'Demo product'),
          const SizedBox(height: AppSpacing.lg),
          Text(product.description, style: AppTextStyles.body),
          if (product.price case final price?) ...[
            const SizedBox(height: AppSpacing.md),
            _LabelledValue('Price', price),
          ],
          sectionGap,
          if (matches.isEmpty)
            const InfoNote(
              icon: Icons.verified_outlined,
              text:
                  'No ingredient in the available ingredient data matches your '
                  'selected allergies. This is not a safety guarantee.',
            )
          else
            InfoNote(
              icon: Icons.warning_amber_rounded,
              color: AppColors.dangerSoft,
              foreground: AppColors.danger,
              text:
                  'Allergy warning: this product matches ${matches.join(', ')}. '
                  'Avoid this product.',
            ),
          sectionGap,
          const SectionTitle('Key ingredients'),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final i in product.keyIngredients)
                TagChip.positive(label: i),
            ],
          ),
          sectionGap,
          const SectionTitle('Key Ingredients Only'),
          Text('${product.allIngredients.join(', ')}.',
              style: AppTextStyles.bodySecondary),
          if (recommendation != null) ...[
            sectionGap,
            const SectionTitle('Why This Product?'),
            Text(recommendation.reason, style: AppTextStyles.body),
          ],
          if (product.howToUse.isNotEmpty) ...[
            sectionGap,
            const SectionTitle('How to use'),
            Text(product.howToUse, style: AppTextStyles.body),
          ],
          sectionGap,
          const SectionTitle('Suitable for'),
          Text(
              'Concerns: ${product.suitableConcerns.join(', ')}\n'
              'Skin types: ${product.suitableSkinTypes.where((s) => s != 'Not sure').join(', ')}',
              style: AppTextStyles.bodySecondary),
          if (bundle.stage case final stage?) ...[
            sectionGap,
            const SectionTitle('Recommendation Status'),
            _LabelledValue('Recommendation Stage', stage.label),
          ],
          if (doctorAdvice != null && doctorAdvice.hasContent) ...[
            sectionGap,
            _DoctorAdviceCard(advice: doctorAdvice),
          ],
          if (recommendation != null) ...[
            sectionGap,
            const SectionTitle('Important Warnings'),
            _ConflictWarnings(conflicts: recommendation.conflicts),
            if (recommendation.pairings.isNotEmpty) ...[
              sectionGap,
              const SectionTitle('Recommended Product Combinations'),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final pairing in recommendation.pairings)
                    TagChip(label: pairing),
                ],
              ),
            ],
          ],
          sectionGap,
          Text(
            'Generic demonstration product: no actual price, store link or certification is implied.',
            style: AppTextStyles.small,
          ),
        ],
      );
    });
  }
}

class _LabelledValue extends StatelessWidget {
  const _LabelledValue(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Text.rich(TextSpan(
      text: '$label: ',
      style: AppTextStyles.label.copyWith(fontSize: 15),
      children: [TextSpan(text: value, style: AppTextStyles.body)],
    ));
  }
}

class _DoctorAdviceCard extends StatelessWidget {
  const _DoctorAdviceCard({required this.advice});

  final DoctorAdvice advice;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.blush,
      borderColor: AppColors.blushBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Doctor's Advice", style: AppTextStyles.h3),
          if (advice.message case final message?) ...[
            const SizedBox(height: 8),
            Text(message, style: AppTextStyles.body),
          ],
          if (advice.referralStatus case final referral?) ...[
            const SizedBox(height: AppSpacing.md),
            _LabelledValue('Dermatologist Referral', referral),
          ],
        ],
      ),
    );
  }
}

class _ConflictWarnings extends StatelessWidget {
  const _ConflictWarnings({required this.conflicts});

  final List<IngredientConflict> conflicts;

  @override
  Widget build(BuildContext context) {
    if (conflicts.isEmpty) {
      return const InfoNote(
        icon: Icons.check_circle_outline,
        text: 'No known ingredient conflicts found in the available '
            'ingredient data.',
      );
    }
    return Column(
      children: [
        for (final conflict in conflicts)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: InfoNote(
              icon: Icons.warning_amber_rounded,
              color: conflict.level == ConflictLevel.severe
                  ? AppColors.dangerSoft
                  : AppColors.blush,
              foreground: conflict.level == ConflictLevel.severe
                  ? AppColors.danger
                  : AppColors.clay,
              text: '${conflict.level.label}: ${conflict.message}',
            ),
          ),
      ],
    );
  }
}
