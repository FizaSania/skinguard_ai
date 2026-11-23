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
  int? _oilinessBeforeDry;
  bool _showReactionError = false;

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
    _showReactionError = false;
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
    final p = profile;
    if (type == SkinType.dry && !p.ratesDryness) {
      // A dry skin type means "not oily"; the old rating returns if the
      // user switches back.
      _oilinessBeforeDry = p.oilinessLevel;
      p.oilinessLevel = 1;
    } else if (type != SkinType.dry && p.ratesDryness) {
      p.oilinessLevel = _oilinessBeforeDry ?? 3;
    }
    p.skinType = type;
    notifyListeners();
  }

  /// Stores the slider value on the scale matching the selected skin type.
  void setSkinRating(int level) {
    final p = profile;
    final value = level.clamp(1, 5);
    if (p.ratesDryness) {
      p.drynessLevel = value;
    } else {
      p.oilinessLevel = value;
    }
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
    if (!profile.hasProductReaction) _clearReactionProduct();
    notifyListeners();
  }

  void clearAllergies() {
    profile.allergies.clear();
    _clearReactionProduct();
    notifyListeners();
  }

  bool get showReactionProductError =>
      _showReactionError && (_user?.isReactionProductMissing ?? false);

  void setReactionProduct(String text) {
    profile.reactionProduct = text;
    notifyListeners();
  }

  /// Returns true when the user may leave the allergy step. Otherwise the
  /// "which product" field shows its validation error.
  bool validateAllergies() {
    final p = profile;
    _showReactionError = p.isReactionProductMissing;
    if (!_showReactionError) p.reactionProduct = p.reactionProduct.trim();
    notifyListeners();
    return !_showReactionError;
  }

  void _clearReactionProduct() {
    profile.reactionProduct = '';
    _showReactionError = false;
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
