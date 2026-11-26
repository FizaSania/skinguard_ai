import 'package:flutter/material.dart';

import '../data/mock/mock_recommendations.dart';
import '../models/product.dart';
import '../models/recommendation.dart';
import '../models/skin_concern.dart';
import '../models/user_profile.dart';
import 'api_analysis_service.dart';
import 'api_client.dart';
import 'recommendation_service.dart';

typedef _JsonMap = Map<String, dynamic>;

/// Live FastAPI implementation of [RecommendationService].
class ApiRecommendationService implements RecommendationService {
  ApiRecommendationService(this._client);

  final ApiClient _client;

  @override
  Future<RecommendationBundle> getRecommendations({
    required UserProfile profile,
    AnalysisResult? result,
  }) async {
    final avoid = MockRecommendationService.avoidTermsFor(
      profile.allergies,
      reactionProduct: profile.reactionProduct,
    );

    if (result == null) {
      return RecommendationBundle(
        primaryConcern: 'General care',
        recommendations: const [],
        ingredientsToLookFor: MockRecommendationData.defaultLookFor,
        ingredientsToAvoid: avoid,
        excludedProducts: const [],
        isDemo: false,
      );
    }

    final scanData = await _loadScanPayload(result.scanId);
    if (scanData == null) {
      return RecommendationBundle(
        primaryConcern: result.primary?.concern ?? 'General care',
        recommendations: const [],
        ingredientsToLookFor: _lookForFor(result.primary?.concern, avoid),
        ingredientsToAvoid: avoid,
        excludedProducts: const [],
        isDemo: false,
      );
    }

    final primaryConcern = ApiAnalysisService.formatConcernLabel(
      (scanData['concern'] as String?) ?? result.primary?.concern ?? '',
    );
    final rawReferral = (scanData['referral'] as String?)?.trim();
    final rawMessage = (scanData['message'] as String?)?.trim();
    final stage = _mapStage(rawReferral);

    final rawRecs = <_JsonMap>[];
    final recList = scanData['recommendations'];
    if (recList is List && recList.isNotEmpty) {
      for (final item in recList) {
        if (item is Map) rawRecs.add(_JsonMap.from(item));
      }
    } else if (scanData['recommendation'] is Map) {
      rawRecs.add(_JsonMap.from(scanData['recommendation'] as Map));
    }

    final products = <Product>[];
    final recommendations = <Recommendation>[];

    for (var i = 0; i < rawRecs.length; i++) {
      final block = rawRecs[i];
      final rawProd = block['product'] is Map
          ? _JsonMap.from(block['product'] as Map)
          : _JsonMap();

      final categoryStr = (block['category'] as String?) ?? 'treatment';
      final category = _parseCategory(categoryStr);
      final reasoningList = (block['reasoning'] is List)
          ? (block['reasoning'] as List)
              .map((r) => _formatReasoningLine(r.toString()))
              .where((r) => r.isNotEmpty)
              .toList()
          : <String>[];

      final reasonText = reasoningList.isNotEmpty
          ? reasoningList.join('\n')
          : 'Recommended for $primaryConcern based on your skin profile.';

      final priceNum = (rawProd['price'] as num?)?.toDouble() ?? 0.0;
      final formattedPrice =
          priceNum > 0 ? 'PKR ${priceNum.toStringAsFixed(0)}' : null;
      final prodId = rawProd['id']?.toString() ?? 'rec_$i';
      final prodName = (rawProd['name'] as String?)?.trim().isNotEmpty == true
          ? (rawProd['name'] as String).trim()
          : categoryStr.replaceAll('_', ' ').toUpperCase();

      final product = Product(
        id: prodId,
        name: prodName,
        category: category,
        keyIngredients: const [],
        allIngredients: const [],
        reason: reasonText,
        description:
            'Matched by SkinGuard AI (${categoryStr.replaceAll('_', ' ')}) for your $primaryConcern scan.',
        suitableConcerns: {primaryConcern},
        suitableSkinTypes: {
          if (profile.skinType != null)
            profile.skinType!.label
          else
            'All skin types',
        },
        accentColor: _accentForCategory(category),
        price: formattedPrice,
        imageUrl: _client.resolveUrl(rawProd['image_url'] as String?),
      );

      products.add(product);
      recommendations.add(
        Recommendation(
          concern: primaryConcern,
          product: product,
          reason: reasonText,
        ),
      );
    }

    final pairedRecs = [
      for (final rec in recommendations)
        Recommendation(
          concern: rec.concern,
          product: rec.product,
          reason: rec.reason,
          pairings: _pairingsFor(rec.product, products),
        ),
    ];

    final doctorAdvice = _buildDoctorAdvice(rawReferral, rawMessage);

    return RecommendationBundle(
      primaryConcern: primaryConcern,
      recommendations: pairedRecs,
      ingredientsToLookFor: _lookForFor(primaryConcern, avoid),
      ingredientsToAvoid: avoid,
      excludedProducts: const [],
      isDemo: false,
      stage: stage,
      doctorAdvice: doctorAdvice,
    );
  }

  Future<_JsonMap?> _loadScanPayload(String scanId) async {
    final cached = _client.scanCache[scanId];
    if (cached != null) return cached;

    final numericId = int.tryParse(scanId);
    if (numericId == null) return null;

    try {
      final raw = await _client.getJson('/scans/$numericId');
      if (raw is Map) {
        final map = _JsonMap.from(raw);
        _client.scanCache[scanId] = map;
        return map;
      }
    } on ApiException {
      return null;
    }
    return null;
  }

  static RecommendationStage _mapStage(String? referral) {
    final r = (referral ?? '').trim().toLowerCase();
    if (r.contains('urgent') || r.contains('doctor')) {
      return RecommendationStage.urgent;
    }
    if (r.contains('recommend')) return RecommendationStage.recommended;
    if (r.contains('optional')) return RecommendationStage.optional;
    return RecommendationStage.notNeeded;
  }

  static DoctorAdvice? _buildDoctorAdvice(String? referral, String? message) {
    final hasMsg = message != null && message.isNotEmpty;
    final hasRef = referral != null && referral.isNotEmpty;
    if (!hasMsg && !hasRef) return null;

    final formattedRef = hasRef
        ? referral
            .replaceAll('_', ' ')
            .split(' ')
            .where((w) => w.isNotEmpty)
            .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' ')
        : null;

    return DoctorAdvice(
      message: hasMsg ? message : null,
      referralStatus: formattedRef,
    );
  }

  static ProductCategory _parseCategory(String raw) {
    final c = raw.toLowerCase();
    if (c.contains('cleanser') || c.contains('wash')) {
      return ProductCategory.cleanser;
    }
    if (c.contains('moistur') || c.contains('cream') || c.contains('lotion')) {
      return ProductCategory.moisturizer;
    }
    if (c.contains('sunscreen') || c.contains('spf')) {
      return ProductCategory.sunscreen;
    }
    if (c.contains('serum')) return ProductCategory.serum;
    return ProductCategory.treatment;
  }

  static Color _accentForCategory(ProductCategory category) =>
      switch (category) {
        ProductCategory.cleanser => const Color(0xFF4D6B2A),
        ProductCategory.moisturizer => const Color(0xFF3E6B7E),
        ProductCategory.sunscreen => const Color(0xFFC48B2B),
        ProductCategory.serum => const Color(0xFF8B5E83),
        ProductCategory.treatment => const Color(0xFF9C5149),
      };

  static String _formatReasoningLine(String line) {
    final cleaned = line.trim().replaceAll('_', ' ');
    if (cleaned.isEmpty) return '';
    final colonIndex = cleaned.indexOf(':');
    if (colonIndex > 0) {
        final rawKey = cleaned.substring(0, colonIndex).trim();
        final rawVal = cleaned.substring(colonIndex + 1).trim();
        final key = rawKey.isEmpty
            ? ''
            : '${rawKey[0].toUpperCase()}${rawKey.substring(1)}';
        final val = rawVal.isEmpty
            ? ''
            : '${rawVal[0].toUpperCase()}${rawVal.substring(1)}';
        return '• $key: $val';
    }
    return '• ${cleaned[0].toUpperCase()}${cleaned.substring(1)}';
}

  static List<String> _lookForFor(String? concern, List<String> avoid) {
    final base = MockRecommendationData.ingredientsToLookFor[concern] ??
        MockRecommendationData.defaultLookFor;
    return base
        .where((i) => !avoid.any((a) => a.toLowerCase() == i.toLowerCase()))
        .toList();
  }

  static List<String> _pairingsFor(Product product, List<Product> all) {
    final pairings = <String>{};
    for (final other in all) {
      if (other.category == product.category) continue;
      final pair = [product.category, other.category]
        ..sort((a, b) => a.index.compareTo(b.index));
      pairings.add('${pair.first.label} + ${pair.last.label}');
    }
    return pairings.toList();
  }
}