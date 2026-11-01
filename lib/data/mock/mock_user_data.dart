import '../../models/user_profile.dart';

/// Demo account available on the login screen.
///
/// These are fake, frontend-only credentials for demonstrating the UI flow.
/// FUTURE BACKEND INTEGRATION: remove this file once real authentication
/// is connected – never ship hardcoded credentials.
class MockUserData {
  MockUserData._();

  static const String demoEmail = 'demo@skinguard.ai';
  static const String demoPassword = 'demo1234';

  static UserProfile demoProfile() => UserProfile(
        id: 'demo-user',
        fullName: 'Ayesha Khan',
        email: demoEmail,
        phone: '+92 300 0000000',
        age: 24,
        gender: Gender.female,
        location: 'Lahore, Pakistan',
        skinType: SkinType.oily,
        oilinessLevel: 4,
        habits: {DailyHabit.poorSleep, DailyHabit.sunExposure},
        allergies: ['Fragrance', 'Salicylic Acid'],
        onboardingComplete: true,
      );
}
