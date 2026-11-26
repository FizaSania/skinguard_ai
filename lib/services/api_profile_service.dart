import '../models/user_profile.dart';
import 'api_client.dart';
import 'profile_service.dart';

/// Persists onboarding skin type and allergies to FastAPI POST /questionnaire.
class ApiProfileService implements ProfileService {
  ApiProfileService(this._client);

  final ApiClient _client;

  @override
  Future<void> saveProfile(UserProfile profile) async {
    final skinType =
        (profile.skinType == null || profile.skinType == SkinType.notSure)
            ? 'normal'
            : profile.skinType!.name.toLowerCase();

    final oilinessSelfReport = profile.ratesDryness
        ? 'dryness_level_${profile.drynessLevel}'
        : 'oiliness_level_${profile.oilinessLevel}';

    final allergies = <String>[
      for (final a in profile.allergies)
        if (a != kProductReactionAllergy && a.trim().isNotEmpty) a.trim(),
      if (profile.hasProductReaction &&
          profile.reactionProduct.trim().isNotEmpty)
        profile.reactionProduct.trim(),
    ];

    await _client.postJson('/questionnaire', {
      'oiliness_self_report': oilinessSelfReport,
      'skin_type': skinType,
      'allergies': allergies,
      'current_routine': <String>[],
    });
  }
}