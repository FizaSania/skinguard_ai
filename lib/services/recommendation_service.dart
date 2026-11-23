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

    final avoid = avoidTermsFor(profile.allergies,
        reactionProduct: profile.reactionProduct);
    final skinType = profile.skinType?.label;

    final excluded = <Product>[];
    final eligible = <Product>[];
    for (final product in MockProducts.all) {
      if (matchingAllergies(product, profile.allergies,
              reactionProduct: profile.reactionProduct)
          .isNotEmpty) {
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

    final stage = _stageFor(result);
    final selected = eligible.take(_productCountFor(stage)).toList();

    final recommendations = [
      for (final product in selected)
        Recommendation(
          concern: _matchingConcern(product, concerns) ?? 'General care',
          product: product,
          reason: _reasonFor(product, concerns, skinType),
          conflicts: _conflictsFor(product, profile.skinType),
          pairings: _pairingsFor(product, selected),
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
      stage: stage,
      doctorAdvice: _doctorAdviceFor(stage, result),
    );
  }

  /// Ingredient-related allergies (predefined) plus any custom allergies,
  /// listed exactly as the user typed them.
  static List<String> avoidTermsFor(List<String> allergies,
          {String reactionProduct = ''}) =>
      [
        for (final allergy in allergies)
          if (!MockRecommendationData.nonIngredientAllergies.contains(allergy))
            allergy,
        if (reactionProduct.trim().isNotEmpty) reactionProduct.trim(),
      ];

  /// The user's allergies (and reaction product) that match [product].
  static List<String> matchingAllergies(Product product, List<String> allergies,
      {String reactionProduct = ''}) {
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
    if (_matchesReactionProduct(product, ingredients, reactionProduct)) {
      matches.add(reactionProduct.trim());
    }
    return matches;
  }

  /// The typed text may be a product name or an ingredient. Names need a
  /// full match so that "oil" does not hide "Oil-Free Gel Moisturizer".
  static bool _matchesReactionProduct(
      Product product, List<String> ingredients, String reactionProduct) {
    final term = reactionProduct.trim().toLowerCase();
    if (term.isEmpty) return false;
    if (term.contains(product.name.toLowerCase())) return true;
    return ingredients.any((i) => i == term || (term.length >= 3 && i.contains(term)));
  }

  static RecommendationStage _stageFor(AnalysisResult? result) {
    if (result == null || result.findings.isEmpty) {
      return RecommendationStage.notNeeded;
    }
    final stages = result.findings.map((f) => switch (f.kind) {
          ConcernKind.acne => switch (f.acne?.severity?.toLowerCase()) {
              'severe' => RecommendationStage.urgent,
              'moderate' => RecommendationStage.recommended,
              _ => RecommendationStage.optional,
            },
          ConcernKind.redness ||
          ConcernKind.pigmentation =>
            RecommendationStage.recommended,
          ConcernKind.other => RecommendationStage.optional,
        });
    return stages.reduce((a, b) => a.index >= b.index ? a : b);
  }

  static int _productCountFor(RecommendationStage stage) => switch (stage) {
        RecommendationStage.notNeeded || RecommendationStage.optional => 1,
        RecommendationStage.recommended || RecommendationStage.urgent => 3,
      };

  static DoctorAdvice? _doctorAdviceFor(
      RecommendationStage stage, AnalysisResult? result) {
    final needsDoctor = result?.findings.any((f) =>
            f.kind == ConcernKind.redness ||
            f.kind == ConcernKind.pigmentation) ??
        false;
    return switch (stage) {
      RecommendationStage.notNeeded => null,
      RecommendationStage.optional => const DoctorAdvice(
          message: 'A dermatologist visit is optional. Consider one if the '
              'concern worries you.',
          referralStatus: 'Optional',
        ),
      RecommendationStage.recommended => DoctorAdvice(
          message: 'Consider consulting a dermatologist for professional '
              'skin assessment.',
          referralStatus: needsDoctor ? 'Recommended' : 'Optional',
        ),
      RecommendationStage.urgent => const DoctorAdvice(
          message: 'Please consult a dermatologist soon for a professional '
              'skin assessment.',
          referralStatus: 'Recommended',
        ),
    };
  }

  static List<IngredientConflict> _conflictsFor(
      Product product, SkinType? skinType) {
    final ingredients =
        product.allIngredients.map((i) => i.toLowerCase()).toSet();
    return [
      for (final rule in MockRecommendationData.conflicts)
        if (rule.skinType == skinType &&
            ingredients.contains(rule.ingredient.toLowerCase()))
          IngredientConflict(level: rule.level, message: rule.message),
    ];
  }

  /// Combinations of [product] with the other products selected for the user.
  static List<String> _pairingsFor(Product product, List<Product> selected) {
    final pairings = <String>{};
    for (final other in selected) {
      if (other.category == product.category) continue;
      final pair = [product.category, other.category]
        ..sort((a, b) => a.index.compareTo(b.index));
      pairings.add('${pair.first.label} + ${pair.last.label}');
    }
    return pairings.toList();
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
      return 'This ${product.category.label.toLowerCase()} is selected based '
          'on your skin profile.';
    }
    final skin = skinType == null || skinType == 'Not sure'
        ? ''
        : ' and ${skinType.toLowerCase()} skin type';
    return 'This ${product.category.label.toLowerCase()} is selected based on '
        'your ${concern.toLowerCase()} concern$skin.';
  }
}
