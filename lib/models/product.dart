import 'package:flutter/material.dart';

enum ProductCategory {
  cleanser('Cleanser'),
  moisturizer('Moisturizer'),
  sunscreen('Sunscreen'),
  serum('Serum'),
  treatment('Treatment');

  const ProductCategory(this.label);
  final String label;
}

/// A demonstration product. These are generic, illustrative products – not
/// real brands – and carry no prices, store links or certifications.
class Product {
  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.keyIngredients,
    required this.allIngredients,
    required this.reason,
    required this.description,
    required this.suitableConcerns,
    required this.suitableSkinTypes,
    required this.accentColor,
    this.howToUse = '',
  });

  final String id;
  final String name;
  final ProductCategory category;
  final List<String> keyIngredients;

  /// Used for allergy filtering. Matching is a simple case-insensitive
  /// text comparison and is NOT a safety guarantee.
  final List<String> allIngredients;

  final String reason; // "Why this?"
  final String description;
  final Set<String> suitableConcerns;
  final Set<String> suitableSkinTypes;
  final String howToUse;

  /// Colour used for the illustrative bottle placeholder.
  final Color accentColor;

  // FUTURE BACKEND INTEGRATION: add imageUrl and fetch real product images
  // from the product catalogue API.
}
