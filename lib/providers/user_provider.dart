import 'package:flutter/foundation.dart';

import '../models/user_profile.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

/// Holds the signed-in user and their profile (onboarding answers,
/// allergies). In-memory only for the static frontend.
class UserProvider extends ChangeNotifier {
  UserProvider(this._auth, this._profileService);

  final AuthService _auth;
  final ProfileService _profileService;

  UserProfile? _user;

  UserProfile? get user => _user;
  bool get isLoggedIn => _user != null;

  /// Convenience accessor for screens that are only reachable when logged in.
  UserProfile get profile => _user!;

  // ---------------------------------------------------------------- auth

  Future<UserProfile> login(String email, String password) async {
    _user = await _auth.login(email: email, password: password);
    notifyListeners();
    return _user!;
  }

  Future<UserProfile> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    _user = await _auth.register(
        fullName: fullName, email: email, phone: phone, password: password);
    notifyListeners();
    return _user!;
  }

  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordReset(email);

  Future<UserProfile> signInWithGoogle() => _auth.signInWithGoogle();

  Future<void> logout() async {
    await _auth.logout();
    _user = null;
    notifyListeners();
  }

  // ------------------------------------------------------ profile edits

  void updateBasics({int? age, Gender? gender, String? location}) {
    final u = profile;
    if (age != null) u.age = age;
    if (gender != null) u.gender = gender;
    if (location != null) u.location = location;
    notifyListeners();
  }

  void setSkinType(SkinType type) {
    profile.skinType = type;
    notifyListeners();
  }

  void setOiliness(int level) {
    profile.oilinessLevel = level.clamp(1, 5);
    notifyListeners();
  }

  void toggleHabit(DailyHabit habit) {
    final habits = profile.habits;
    habits.contains(habit) ? habits.remove(habit) : habits.add(habit);
    notifyListeners();
  }

  // ----------------------------------------------------------- allergies

  bool hasAllergy(String allergy) => profile.allergies
      .any((a) => a.toLowerCase() == allergy.trim().toLowerCase());

  void toggleAllergy(String allergy) {
    hasAllergy(allergy) ? removeAllergy(allergy) : _addAllergy(allergy);
  }

  /// Adds a typed allergy exactly as entered (trimmed). Returns false when
  /// the text is empty or already selected.
  bool addCustomAllergy(String text) {
    final value = text.trim();
    if (value.isEmpty || hasAllergy(value)) return false;
    // Re-use the predefined spelling if the user typed a known allergy.
    final known = kPredefinedAllergies.firstWhere(
        (a) => a.toLowerCase() == value.toLowerCase(),
        orElse: () => value);
    _addAllergy(known);
    return true;
  }

  void removeAllergy(String allergy) {
    profile.allergies.removeWhere(
        (a) => a.toLowerCase() == allergy.trim().toLowerCase());
    notifyListeners();
  }

  void clearAllergies() {
    profile.allergies.clear();
    notifyListeners();
  }

  void _addAllergy(String allergy) {
    profile.allergies.add(allergy);
    notifyListeners();
  }

  // --------------------------------------------------------- persistence

  Future<void> saveProfile() => _profileService.saveProfile(profile);

  Future<void> completeOnboarding() async {
    profile.onboardingComplete = true;
    // FUTURE DATABASE INTEGRATION: the profile is sent to the backend here.
    await saveProfile();
    notifyListeners();
  }
}
