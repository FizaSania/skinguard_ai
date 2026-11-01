import 'product.dart';

/// A product recommendation together with the reasoning shown to the user.
class Recommendation {
  const Recommendation({
    required this.concern,
    required this.product,
    required this.reason,
  });

  final String concern;
  final Product product;
  final String reason;
}

/// Everything the "Recommended for you" and "Products & ingredients"
/// screens need.
class RecommendationBundle {
  const RecommendationBundle({
    required this.primaryConcern,
    required this.recommendations,
    required this.ingredientsToLookFor,
    required this.ingredientsToAvoid,
    required this.excludedProducts,
    required this.isDemo,
  });

  final String primaryConcern;
  final List<Recommendation> recommendations;
  final List<String> ingredientsToLookFor;

  /// Derived from the user's selected allergies.
  final List<String> ingredientsToAvoid;

  /// Products hidden because they list an ingredient matching an allergy.
  final List<Product> excludedProducts;

  final bool isDemo;

  bool get isEmpty => recommendations.isEmpty;
}
