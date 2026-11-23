import 'product.dart';

/// How strongly products are advised for the latest result.
enum RecommendationStage {
  notNeeded('Not Needed'),
  optional('Optional'),
  recommended('Recommended'),
  urgent('Urgent');

  const RecommendationStage(this.label);
  final String label;
}

enum ConflictLevel {
  mild('Mild conflict'),
  moderate('Moderate conflict'),
  severe('Severe conflict');

  const ConflictLevel(this.label);
  final String label;
}

/// A warning about a product ingredient for this user's profile.
class IngredientConflict {
  const IngredientConflict({required this.level, required this.message});

  final ConflictLevel level;
  final String message;
}

/// Doctor message and referral status from the recommendation engine.
class DoctorAdvice {
  const DoctorAdvice({this.message, this.referralStatus});

  final String? message;
  final String? referralStatus;

  bool get hasContent => message != null || referralStatus != null;
}

/// A product recommendation together with the reasoning shown to the user.
class Recommendation {
  const Recommendation({
    required this.concern,
    required this.product,
    required this.reason,
    this.conflicts = const [],
    this.pairings = const [],
  });

  final String concern;
  final Product product;
  final String reason;
  final List<IngredientConflict> conflicts;

  /// e.g. "Cleanser + Moisturizer".
  final List<String> pairings;
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
    this.stage,
    this.doctorAdvice,
  });

  final String primaryConcern;

  /// One product for Not Needed / Optional, three for Recommended / Urgent.
  final List<Recommendation> recommendations;
  final List<String> ingredientsToLookFor;

  /// Derived from the user's selected allergies.
  final List<String> ingredientsToAvoid;

  /// Products hidden because they list an ingredient matching an allergy.
  final List<Product> excludedProducts;

  final bool isDemo;
  final RecommendationStage? stage;
  final DoctorAdvice? doctorAdvice;

  bool get isEmpty => recommendations.isEmpty;

  Recommendation? forProduct(String productId) {
    for (final r in recommendations) {
      if (r.product.id == productId) return r;
    }
    return null;
  }
}
