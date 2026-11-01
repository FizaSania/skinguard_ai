/// Static ingredient knowledge used by the mock recommendation service.
///
/// FUTURE RECOMMENDATION INTEGRATION: this logic moves to the backend
/// recommendation engine.
class MockRecommendationData {
  MockRecommendationData._();

  static const Map<String, List<String>> ingredientsToLookFor = {
    'Acne': ['Niacinamide', 'Zinc PCA', 'Hyaluronic acid', 'Azelaic acid'],
    'Hyperpigmentation': ['Niacinamide', 'Azelaic acid', 'Vitamin C'],
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
    'Salicylic Acid': ['Salicylic Acid'],
    'Essential oils': ['Essential oils'],
  };

  static const List<String> nonIngredientAllergies = [
    'Dust allergy',
    'Pet fur allergy',
    'Pollen allergy',
    'Food allergy',
    'Skincare product reaction',
  ];
}
