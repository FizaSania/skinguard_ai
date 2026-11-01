import '../models/user_profile.dart';

/// Persists the user profile (onboarding answers, allergies, preferences).
abstract class ProfileService {
  Future<void> saveProfile(UserProfile profile);
}

/// No-op implementation: the profile only lives in memory (UserProvider).
///
/// FUTURE DATABASE INTEGRATION:
/// Persist this profile using the backend/database, e.g.
/// `PUT /users/{id}/profile` with `profile.toJson()`.
class MockProfileService implements ProfileService {
  @override
  Future<void> saveProfile(UserProfile profile) async {
    await Future.delayed(const Duration(milliseconds: 250));
  }
}
