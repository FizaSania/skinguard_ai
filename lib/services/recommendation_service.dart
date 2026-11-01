import '../data/mock/mock_products.dart';
import '../data/mock/mock_recommendations.dart';
import '../models/product.dart';
import '../models/recommendation.dart';
import '../models/skin_concern.dart';
import '../models/user_profile.dart';

abstract class RecommendationService {
  Future<RecommendationBundle> getRecommendations({
    required UserProfile profile,
    AnalysisResult? result,
  });
}

/// Builds demo recommendations from the mock catalogue using the latest
/// (demo) result, the skin type and the selected allergies.
///
/// FUTURE RECOMMENDATION INTEGRATION:
/// Replace mock recommendations with backend-generated recommendations,
/// e.g. `GET /recommendations?scanId=...`. Keep this logic out of widgets.
class MockRecommendationService implements RecommendationService {
  @override
  Future<RecommendationBundle> getRecommendations({
    required UserProfile profile,
    AnalysisResult? result,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return build(profile: profile, result: result);
  }

  /// Synchronous core, also used by unit tests.
  RecommendationBundle build({
    required UserProfile profile,
    AnalysisResult? result,
  }) {
    final primary = result?.primary;
    final concerns = <String>[
      if (primary != null) primary.concern,
      ...?result?.concerns.where((c) => c != primary?.concern),
    ];

    final avoid = avoidTermsFor(profile.allergies);
    final skinType = profile.skinType?.label;

    final excluded = <Product>[];
    final eligible = <Product>[];
    for (final product in MockProducts.all) {
      if (_containsAvoided(product, profile.allergies)) {
        excluded.add(product);
        continue;
      }
      final concernMatch = concerns.isEmpty ||
          product.suitableConcerns.any(concerns.contains);
      final skinMatch =
          skinType == null || product.suitableSkinTypes.contains(skinType);
      if (concernMatch && skinMatch) eligible.add(product);
    }
    eligible.sort((a, b) => a.category.index.compareTo(b.category.index));

    final recommendations = [
      for (final product in eligible)
        Recommendation(
          concern: _matchingConcern(product, concerns) ?? 'General care',
          product: product,
          reason: _reasonFor(product, concerns, skinType),
        ),
    ];

    final lookFor = <String>{
      for (final c in concerns)
        ...?MockRecommendationData.ingredientsToLookFor[c],
      if (concerns.isEmpty) ...MockRecommendationData.defaultLookFor,
    }..removeWhere((i) =>
        avoid.any((a) => a.toLowerCase() == i.toLowerCase()));

    return RecommendationBundle(
      primaryConcern: primary?.concern ?? 'General care',
      recommendations: recommendations,
      ingredientsToLookFor: lookFor.toList(),
      ingredientsToAvoid: avoid,
      excludedProducts: excluded,
      isDemo: true,
    );
  }

  /// Ingredient-related allergies (predefined) plus any custom allergies,
  /// listed exactly as the user typed them.
  static List<String> avoidTermsFor(List<String> allergies) => [
        for (final allergy in allergies)
          if (!MockRecommendationData.nonIngredientAllergies.contains(allergy))
            allergy,
      ];

  static bool _containsAvoided(Product product, List<String> allergies) =>
      matchingAllergies(product, allergies).isNotEmpty;

  /// The user's allergies that match an ingredient name in [product].
  static List<String> matchingAllergies(
      Product product, List<String> allergies) {
    final ingredients =
        product.allIngredients.map((i) => i.toLowerCase()).toList();
    final matches = <String>[];
    for (final allergy in allergies) {
      if (MockRecommendationData.nonIngredientAllergies.contains(allergy)) {
        continue;
      }
      final terms = MockRecommendationData.allergyIngredientTerms[allergy] ??
          [allergy];
      final hit = terms.any((term) {
        final t = term.toLowerCase().trim();
        return t.isNotEmpty && ingredients.any((i) => i.contains(t));
      });
      if (hit) matches.add(allergy);
    }
    return matches;
  }

  static String? _matchingConcern(Product product, List<String> concerns) {
    for (final c in concerns) {
      if (product.suitableConcerns.contains(c)) return c;
    }
    return null;
  }

  static String _reasonFor(
      Product product, List<String> concerns, String? skinType) {
    final concern = _matchingConcern(product, concerns);
    if (concern == null) {
      return 'A gentle everyday option suited to your skin profile.';
    }
    final skin = skinType == null ? '' : ' and your ${skinType.toLowerCase()} skin type';
    return 'Recommended because it matches your detected concern '
        '(${concern.toLowerCase()})$skin, plus your questionnaire responses.';
  }
}
