import '../../models/recommendation.dart';
import '../../models/user_profile.dart';

/// Static ingredient knowledge used by the mock recommendation service.
///
/// FUTURE RECOMMENDATION INTEGRATION: this logic moves to the backend
/// recommendation engine.
class MockRecommendationData {
  MockRecommendationData._();

  static const Map<String, List<String>> ingredientsToLookFor = {
    'Acne': ['Niacinamide', 'Zinc PCA', 'Hyaluronic acid', 'Azelaic acid'],
    'Pigmentation': ['Niacinamide', 'Azelaic acid', 'Vitamin C'],
    'Redness': ['Niacinamide', 'Azelaic acid', 'Ceramides'],
    'Enlarged pores': ['Niacinamide', 'Zinc PCA', 'Clay'],
    'Dryness': ['Ceramides', 'Hyaluronic acid', 'Glycerin'],
  };

  static const List<String> defaultLookFor = [
    'Hyaluronic acid',
    'Glycerin',
    'Broad-spectrum UV filters',
  ];

  /// Predefined allergies that correspond to cosmetic ingredients, mapped to
  /// the ingredient names searched for in product ingredient lists.
  ///
  /// Allergies like "Dust allergy" or "Pollen allergy" are environmental and
  /// therefore not used to filter products. Custom (typed) allergies are used
  /// verbatim as an ingredient search term – they are never reinterpreted.
  static const Map<String, List<String>> allergyIngredientTerms = {
    'Fragrance': ['Fragrance', 'Parfum'],
    'Essential oils': ['Essential oils'],
  };

  /// Demo ingredient / skin-type conflict rules.
  static const List<
      ({
        String ingredient,
        SkinType skinType,
        ConflictLevel level,
        String message,
      })> conflicts = [
    (
      ingredient: 'Azelaic acid',
      skinType: SkinType.sensitive,
      level: ConflictLevel.moderate,
      message: 'Azelaic acid can sting sensitive skin. Patch-test it first '
          'and introduce it slowly.',
    ),
    (
      ingredient: 'Niacinamide',
      skinType: SkinType.sensitive,
      level: ConflictLevel.mild,
      message: 'Niacinamide can cause mild flushing on some sensitive skin.',
    ),
    (
      ingredient: 'Salicylic Acid',
      skinType: SkinType.dry,
      level: ConflictLevel.moderate,
      message: 'Salicylic acid can increase dryness. Use it sparingly.',
    ),
  ];

  static const List<String> nonIngredientAllergies = [
    'Dust allergy',
    'Pet fur allergy',
    'Pollen allergy',
    'Food allergy',
    'Skincare product reaction',
  ];
}
