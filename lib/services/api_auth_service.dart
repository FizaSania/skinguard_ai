import '../models/user_profile.dart';
import 'api_client.dart';
import 'auth_service.dart';

/// Live FastAPI implementation of [AuthService].
class ApiAuthService implements AuthService {
  ApiAuthService(this._client);

  final ApiClient _client;

  @override
  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    try {
      final tokenData = await _client.postJson(
        '/auth/login',
        {
          'email': email.trim().toLowerCase(),
          'password': password,
        },
        auth: false,
      ) as Map<String, dynamic>;

      final token = tokenData['access_token'] as String?;
      if (token == null || token.isEmpty) {
        throw const AuthException('Server did not return an access token.');
      }
      await _client.saveToken(token);

      final me = await _client.getJson('/auth/me') as Map<String, dynamic>;
      final profile = UserProfile(
        id: me['id'].toString(),
        fullName: (me['name'] as String?) ?? '',
        email: (me['email'] as String?) ?? email.trim().toLowerCase(),
      );

      await _hydrateFromLatestQuestionnaire(profile);
      return profile;
    } on AuthException {
      rethrow;
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<UserProfile> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    try {
      final created = await _client.postJson(
        '/auth/register',
        {
          'name': fullName.trim(),
          'email': cleanEmail,
          'password': password,
        },
        auth: false,
      ) as Map<String, dynamic>;

      // Obtain JWT immediately so subsequent onboarding / scan calls are authenticated.
      final tokenData = await _client.postJson(
        '/auth/login',
        {
          'email': cleanEmail,
          'password': password,
        },
        auth: false,
      ) as Map<String, dynamic>;

      final token = tokenData['access_token'] as String?;
      if (token != null && token.isNotEmpty) {
        await _client.saveToken(token);
      }

      return UserProfile(
        id: created['id'].toString(),
        fullName: (created['name'] as String?) ?? fullName.trim(),
        email: (created['email'] as String?) ?? cleanEmail,
        phone: phone.trim(),
        onboardingComplete: false,
      );
    } on ApiException catch (e) {
      throw AuthException(e.message);
    }
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    throw const AuthException(
      'Password reset is not enabled yet in this FYP-1 build.',
    );
  }

  @override
  Future<UserProfile> signInWithGoogle() async {
    throw const AuthException(
      'Google sign-in is not connected yet in this FYP-1 build.',
    );
  }

  @override
  Future<void> logout() async {
    await _client.clearToken();
  }

  Future<void> _hydrateFromLatestQuestionnaire(UserProfile profile) async {
    try {
      final q = await _client.getJson('/questionnaire/latest')
          as Map<String, dynamic>;

      final rawSkinType = (q['skin_type'] as String?)?.trim().toLowerCase();
      if (rawSkinType != null && rawSkinType.isNotEmpty) {
        profile.skinType = _parseSkinType(rawSkinType);
      }

      final rawOiliness =
          (q['oiliness_self_report'] as String?)?.trim().toLowerCase() ?? '';
      final levelMatch = RegExp(r'(\d)').firstMatch(rawOiliness);
      if (levelMatch != null) {
        final parsed = int.tryParse(levelMatch.group(1)!)?.clamp(1, 5);
        if (parsed != null) {
          if (rawOiliness.startsWith('dryness')) {
            profile.drynessLevel = parsed;
          } else {
            profile.oilinessLevel = parsed;
          }
        }
      }

      final rawAllergies = q['allergies'];
      if (rawAllergies is List) {
        profile.allergies.clear();
        for (final item in rawAllergies) {
          final text = item.toString().trim();
          if (text.isEmpty) continue;
          final normalized = text.replaceAll('_', ' ');
          final matched = kPredefinedAllergies.firstWhere(
            (a) => a.toLowerCase() == normalized.toLowerCase(),
            orElse: () => normalized,
          );
          if (!profile.allergies.contains(matched)) {
            profile.allergies.add(matched);
          }
        }
      }

      profile.onboardingComplete = true;
    } on ApiException catch (e) {
      // 404 simply means the user has not submitted onboarding yet.
      if (e.statusCode != 404) rethrow;
    }
  }

  SkinType _parseSkinType(String value) => switch (value) {
        'oily' => SkinType.oily,
        'dry' => SkinType.dry,
        'combination' => SkinType.combination,
        'normal' => SkinType.normal,
        'sensitive' => SkinType.sensitive,
        _ => SkinType.notSure,
      };
}