import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/config/feature_flags.dart';
import '../../core/utils/navigation.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/illustrations.dart';
import '../../core/widgets/layout.dart';
import '../../models/recommendation.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import '../recommendations/recommendation_loader.dart';

class ProductsScreen extends StatelessWidget {
  const ProductsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RecommendationLoader(builder: (context, bundle) {
      final profile = context.watch<UserProvider>().profile;
      final skin = profile.skinType?.label.toLowerCase();
      final concern = bundle.primaryConcern == 'General care'
          ? null
          : '${bundle.primaryConcern.toLowerCase()}-prone';
      final picked = [
        ?concern,
        if (skin != null && skin != 'not sure') '$skin skin',
      ].join(', ');

      return PageLayout(
        bottom: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            PrimaryButton(
              label: 'Next: Lifestyle Guide',
              comingSoon: !FeatureFlags.lifestyle,
              onPressed: () =>
                  Navigator.pushNamed(context, AppRoutes.lifestyle),
            ),
            TextButton(
              onPressed: () => backToResults(context),
              child: const Text('Back to Results'),
            ),
          ],
        ),
        children: [
          Text('Products & ingredients', style: AppTextStyles.h1),
          const SizedBox(height: 6),
          Text(
            picked.isEmpty
                ? 'Picked to be free of the ingredients you avoid.'
                : 'Picked for $picked, and free of the ingredients you avoid.',
            style: AppTextStyles.bodySecondary,
          ),
          if (bundle.isDemo) ...[
            const SizedBox(height: AppSpacing.sm),
            const DemoBadge(label: 'Demo products – not real brands'),
          ],
          const SizedBox(height: AppSpacing.xl),
          if (bundle.isEmpty)
            EmptyState(
              icon: Icons.spa_outlined,
              title: bundle.stage == RecommendationStage.urgent
                  ? 'Consult a Dermatologist'
                  : 'No products to show',
              message: bundle.doctorAdvice?.message ??
                  'No products were recommended for your current scan and profile.',
            )
          else
            for (final rec in bundle.recommendations)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: ProductCard(rec: rec),
              ),
          InfoNote(
            icon: Icons.health_and_safety_outlined,
            color: AppColors.blush,
            foreground: AppColors.clay,
            text: bundle.isDemo
                ? 'Product information is demonstration content. Verify ingredients on the actual '
                    'label – sensitivities vary from person to person.'
                : 'Always verify ingredients on the actual product label and patch-test new '
                    'products – sensitivities vary from person to person.',
          ),
        ],
      );
    });
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.rec});

  final Recommendation rec;

  @override
  Widget build(BuildContext context) {
    final p = rec.product;
    return AppCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.productDetail,
          arguments: p.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (p.imageUrl != null)
                SizedBox(
                  width: 68,
                  height: 76,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    child: Image.network(
                      p.imageUrl!,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) =>
                          ProductBottle(color: p.accentColor, height: 76),
                    ),
                  ),
                )
              else
                ProductBottle(color: p.accentColor, height: 76),
              const SizedBox(width: AppSpacing.lg + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.category.label.toUpperCase(),
                        style: AppTextStyles.overline),
                    const SizedBox(height: 2),
                    Text(p.name, style: AppTextStyles.h3.copyWith(fontSize: 20)),
                    if (p.price case final price?) ...[
                      const SizedBox(height: 4),
                      Text(
                        price,
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.primary),
                      ),
                    ],
                    if (p.keyIngredients.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text.rich(TextSpan(
                        text: 'Key ingredients: ',
                        style: AppTextStyles.label,
                        children: [
                          TextSpan(
                              text: p.keyIngredients.join(', '),
                              style: AppTextStyles.body),
                        ],
                      )),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Text('Why this?', style: AppTextStyles.label.copyWith(fontSize: 15)),
          const SizedBox(height: 4),
          Text(p.reason, style: AppTextStyles.body),
          const SizedBox(height: AppSpacing.sm),
          Align(
            alignment: Alignment.centerRight,
            child: Text('View details →',
                style:
                    AppTextStyles.label.copyWith(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}