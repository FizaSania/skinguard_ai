import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/illustrations.dart';
import '../../core/widgets/layout.dart';
import '../../core/widgets/selection.dart';
import '../../data/mock/mock_products.dart';
import '../../providers/user_provider.dart';
import '../../services/recommendation_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// Product details with ingredient and allergy information.
// FUTURE BACKEND INTEGRATION: fetch the product by id from the catalogue
// API instead of MockProducts.
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
    final allergies = context.watch<UserProvider>().profile.allergies;
    final matches =
        MockRecommendationService.matchingAllergies(product, allergies);

    return PageLayout(
      children: [
        Center(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
            decoration: BoxDecoration(
              color: Color.lerp(product.accentColor, Colors.white, 0.85),
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
        const SizedBox(height: AppSpacing.xl),
        Text(product.category.label.toUpperCase(),
            style: AppTextStyles.overline),
        const SizedBox(height: 4),
        Text(product.name, style: AppTextStyles.h1),
        const SizedBox(height: AppSpacing.sm),
        const DemoBadge(label: 'Demo product'),
        const SizedBox(height: AppSpacing.lg),
        Text(product.description, style: AppTextStyles.body),
        const SizedBox(height: AppSpacing.xl),
        if (matches.isEmpty)
          const InfoNote(
            icon: Icons.verified_outlined,
            text:
                'No ingredient in this demo list matches your selected allergies. '
                'This is not a safety guarantee.',
          )
        else
          InfoNote(
            icon: Icons.warning_amber_rounded,
            color: AppColors.dangerSoft,
            foreground: AppColors.danger,
            text:
                'Allergy warning: contains an ingredient matching ${matches.join(', ')}. '
                'Avoid this product.',
          ),
        const SizedBox(height: AppSpacing.xl),
        const SectionTitle('Key ingredients'),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final i in product.keyIngredients) TagChip.positive(label: i),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionTitle('Full ingredient list (demo)'),
        Text(product.allIngredients.join(', '),
            style: AppTextStyles.bodySecondary),
        const SizedBox(height: AppSpacing.xl),
        const SectionTitle('Why this?'),
        Text(product.reason, style: AppTextStyles.body),
        if (product.howToUse.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xl),
          const SectionTitle('How to use'),
          Text(product.howToUse, style: AppTextStyles.body),
        ],
        const SizedBox(height: AppSpacing.xl),
        const SectionTitle('Suitable for'),
        Text(
            'Concerns: ${product.suitableConcerns.join(', ')}\n'
            'Skin types: ${product.suitableSkinTypes.where((s) => s != 'Not sure').join(', ')}',
            style: AppTextStyles.bodySecondary),
        const SizedBox(height: AppSpacing.xl),
        Text(
          'Generic demonstration product: no price, store link or certification is implied.',
          style: AppTextStyles.small,
        ),
      ],
    );
  }
}
