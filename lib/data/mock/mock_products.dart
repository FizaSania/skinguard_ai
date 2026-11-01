import 'package:flutter/material.dart';

import '../../models/product.dart';

/// Demonstration product catalogue. Generic names only – no real brands,
/// prices, store links or certifications.
///
/// FUTURE BACKEND INTEGRATION: replace with the product catalogue API.
class MockProducts {
  MockProducts._();

  static const List<Product> all = [
    Product(
      id: 'gentle-gel-cleanser',
      name: 'Gentle Gel Cleanser',
      category: ProductCategory.cleanser,
      keyIngredients: ['Zinc PCA', 'Glycerin'],
      allIngredients: ['Water', 'Glycerin', 'Zinc PCA', 'Coco-Glucoside'],
      reason:
          'Cleans without stripping, and matches your acne concern. Fragrance-free.',
      description:
          'A low-foaming gel cleanser intended for oily and acne-prone skin.',
      howToUse:
          'Massage onto damp skin morning and evening, then rinse with lukewarm water.',
      suitableConcerns: {'Acne', 'Enlarged pores'},
      suitableSkinTypes: {'Oily', 'Combination', 'Normal', 'Not sure'},
      accentColor: Color(0xFF4D6B2A),
    ),
    Product(
      id: 'oil-free-gel-moisturizer',
      name: 'Oil-Free Gel Moisturizer',
      category: ProductCategory.moisturizer,
      keyIngredients: ['Niacinamide', 'Hyaluronic acid'],
      allIngredients: ['Water', 'Niacinamide', 'Hyaluronic acid', 'Glycerin'],
      reason:
          'A lightweight formula that suits oily skin and supports the skin barrier.',
      description:
          'A water-light gel moisturiser that hydrates without feeling heavy.',
      howToUse: 'Apply a pea-sized amount after cleansing.',
      suitableConcerns: {'Acne', 'Enlarged pores', 'Hyperpigmentation', 'Dryness'},
      suitableSkinTypes: {'Oily', 'Combination', 'Normal', 'Sensitive', 'Not sure'},
      accentColor: Color(0xFFC0764A),
    ),
    Product(
      id: 'fragrance-free-spf50',
      name: 'Fragrance-Free SPF 50 Sunscreen',
      category: ProductCategory.sunscreen,
      keyIngredients: ['Broad-spectrum UV filters'],
      allIngredients: ['Broad-spectrum UV filters', 'Glycerin', 'Silica'],
      reason:
          'Daily protection that avoids fragrance, which you listed as an allergy.',
      description: 'A broad-spectrum daily sunscreen with no added fragrance.',
      howToUse:
          'Apply generously as the last step of your morning routine and reapply every 2 hours outdoors.',
      suitableConcerns: {'Acne', 'Hyperpigmentation', 'Enlarged pores', 'Dryness'},
      suitableSkinTypes: {'Oily', 'Dry', 'Combination', 'Normal', 'Sensitive', 'Not sure'},
      accentColor: Color(0xFFB8902E),
    ),
    Product(
      id: 'bha-clarifying-toner',
      name: 'BHA Clarifying Toner',
      category: ProductCategory.treatment,
      keyIngredients: ['Salicylic Acid', 'Witch hazel'],
      allIngredients: ['Water', 'Salicylic Acid', 'Witch hazel', 'Fragrance'],
      reason: 'Exfoliates inside pores to help with breakouts.',
      description: 'A leave-on exfoliating toner for congested skin.',
      howToUse: 'Use 2–3 evenings a week after cleansing.',
      suitableConcerns: {'Acne', 'Enlarged pores'},
      suitableSkinTypes: {'Oily', 'Combination'},
      accentColor: Color(0xFF6E8B9A),
    ),
    Product(
      id: 'azelaic-acid-serum',
      name: 'Azelaic Acid Serum',
      category: ProductCategory.serum,
      keyIngredients: ['Azelaic acid', 'Niacinamide'],
      allIngredients: ['Water', 'Azelaic acid', 'Niacinamide', 'Glycerin'],
      reason: 'Targets uneven tone and visible redness from past breakouts.',
      description: 'A gentle serum aimed at uneven tone and post-blemish marks.',
      howToUse: 'Apply a thin layer in the evening before moisturiser.',
      suitableConcerns: {'Hyperpigmentation', 'Acne'},
      suitableSkinTypes: {'Oily', 'Combination', 'Normal', 'Not sure'},
      accentColor: Color(0xFF8C6BAA),
    ),
    Product(
      id: 'ceramide-lip-balm',
      name: 'Ceramide Repair Balm',
      category: ProductCategory.moisturizer,
      keyIngredients: ['Ceramides', 'Shea butter'],
      allIngredients: ['Ceramides', 'Shea butter', 'Essential oils'],
      reason: 'Seals in moisture for dry, flaky areas.',
      description: 'A rich balm for very dry patches and lips.',
      howToUse: 'Apply to dry areas as needed.',
      suitableConcerns: {'Dryness'},
      suitableSkinTypes: {'Dry', 'Normal', 'Sensitive', 'Combination', 'Not sure'},
      accentColor: Color(0xFFB66A6A),
    ),
  ];

  static Product? byId(String id) {
    for (final p in all) {
      if (p.id == id) return p;
    }
    return null;
  }
}
