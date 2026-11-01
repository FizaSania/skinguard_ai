enum Gender {
  female('Female'),
  male('Male'),
  nonBinary('Non-binary'),
  preferNotToSay('Prefer not to say');

  const Gender(this.label);
  final String label;
}

enum SkinType {
  oily('Oily'),
  dry('Dry'),
  combination('Combination'),
  normal('Normal'),
  sensitive('Sensitive'),
  notSure('Not sure');

  const SkinType(this.label);
  final String label;
}

enum DailyHabit {
  poorSleep('Poor sleep quality'),
  highStress('High stress levels'),
  smoking('Smoking'),
  sunExposure('Frequent sun exposure');

  const DailyHabit(this.label);
  final String label;
}

/// Predefined allergy options shown during onboarding (Step 3).
///
/// Custom allergies typed by the user are stored as plain strings exactly as
/// entered – they are never classified or mapped to other allergies.
const List<String> kPredefinedAllergies = [
  'Fragrance',
  'Dust allergy',
  'Pet fur allergy',
  'Salicylic Acid',
  'Pollen allergy',
  'Food allergy',
  'Essential oils',
  'Skincare product reaction',
];

/// Everything we know about the user. Kept as a plain model with
/// `toJson` so it can be persisted later.
//
// FUTURE DATABASE INTEGRATION:
// Persist this profile using the backend/database (see ProfileService).
class UserProfile {
  UserProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone = '',
    this.age = 30,
    this.gender,
    this.location = '',
    this.skinType,
    this.oilinessLevel = 3,
    Set<DailyHabit>? habits,
    List<String>? allergies,
    this.onboardingComplete = false,
  })  : habits = habits ?? <DailyHabit>{},
        allergies = allergies ?? <String>[];

  final String id;
  String fullName;
  String email;
  String phone;

  // Step 1 – profile
  int age;
  Gender? gender;
  String location;

  // Step 2 – skin type & habits
  SkinType? skinType;
  int oilinessLevel; // 1 (not oily) – 5 (very oily)
  final Set<DailyHabit> habits;

  // Step 3 – allergies (predefined labels and/or custom text)
  final List<String> allergies;

  bool onboardingComplete;

  String get firstName {
    final trimmed = fullName.trim();
    if (trimmed.isEmpty) return '';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  bool isCustomAllergy(String allergy) =>
      !kPredefinedAllergies.contains(allergy);

  Map<String, dynamic> toJson() => {
        'id': id,
        'fullName': fullName,
        'email': email,
        'phone': phone,
        'age': age,
        'gender': gender?.name,
        'location': location,
        'skinType': skinType?.name,
        'oilinessLevel': oilinessLevel,
        'habits': habits.map((h) => h.name).toList(),
        'allergies': allergies,
        'onboardingComplete': onboardingComplete,
      };
}
