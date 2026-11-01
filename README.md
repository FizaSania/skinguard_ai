# SkinGuard AI – Static Flutter Frontend (FYP)

Complete, navigable **static frontend** for SkinGuard AI, built from the Figma
design (`SkinGuard AI.pdf`). Every screen works with mock data and in-memory
state. **No backend, ML model, database or API key is required.**

> All analysis results, products and progress photos in this build are
> clearly labelled **demo data**. Nothing in the app claims a real AI analysis.

---

## 1. Running the app

```bash
cd skinguard_ai
flutter pub get
flutter run              # Android device / emulator (primary target)
flutter run -d chrome    # quick preview in a browser
flutter analyze
flutter test
```

**Demo account:** `demo@skinguard.ai` / `demo1234` (or tap **Fill demo** on the
login screen). Any new account created on Sign Up also works for the session.

Fonts (Fraunces + DM Sans) are loaded by `google_fonts` on first launch and
cached; offline the system font is used.

### Camera / gallery setup
* Uses `image_picker` behind `ImageService` (`lib/services/image_service.dart`).
* **Android:** no extra permissions needed (system camera/gallery intents).
* **iOS:** `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription`
  are already in `ios/Runner/Info.plist`.
* **Web / emulators without a camera:** "Take Photo" falls back to a dialog
  offering the bundled **sample image** (always labelled "Sample image").
  "Use sample image (demo)" is also available on the camera screen.
* The camera screen preview is a styled placeholder – there is no live
  preview or lighting detection yet (both are clearly marked).

---

## 2. Demo flow

```
Splash → Login / Sign Up → Onboarding (Profile → Skin type & habits → Allergies)
      → Dashboard (Home · Analyze · History · Profile)
Analyze → Select region + mode
   ├─ Full Face → Full-face questionnaire → Camera → Review → Analyzing → Results
   └─ Detailed Patch → Patch details p1 → p2 → Camera (one photo per region)
                      → Review (per region) → Analyzing → Results
Results → View Details / Recommendations → Products → Lifestyle → Plan & Tracker
```

* Existing user (demo account) skips onboarding. A new sign-up goes through it.
* Onboarding progress (`Profile setup · Step x of 3`) is separate from scan
  progress (`Scan setup · Step x of 3/4`).
* Answers, regions and mode are kept in `ScanProvider`, so going **Back**
  never loses data. Switching between Full Face / Patch drops only photos
  that belong to the other mode.
* Multi-region patch scans capture **one region at a time**; each photo is
  stored against its own region (`ScanImage.region`) and can be reviewed /
  retaken from the region chips on the camera screen.
* **Profile → Demo: simulate analysis failure** shows the analysis
  error/retry state.

### Screens implemented
Splash · Login · Sign Up · Forgot password · Onboarding 1 (profile) ·
Onboarding 2 (skin type & habits) · Onboarding 3 (allergies) · Dashboard ·
My Allergies · Scan selection (region + mode) · Full-face questionnaire ·
Patch details 1/2 · Patch details 2/2 · Camera (full face & patch) · Photo
review · Analyzing · Skin Analysis results · Result details · Recommended for
you · Products & ingredients · Product details · Lifestyle guide · My plan &
tracker · Compare scans · History · Profile.

---

## 3. Project structure

```
lib/
  main.dart                     entry point – creates AppServices
  app/
    app.dart                    MaterialApp + Providers
    routes.dart                 route names, arguments, onGenerateRoute
  theme/                        colours, typography, spacing, ThemeData
  core/
    constants/app_assets.dart
    utils/                      date formatting, navigation helper
    widgets/                    reusable buttons, fields, choice tiles, cards,
                                progress, badges, image view, illustrations
  models/                       user_profile, skin_scan, skin_concern,
                                product, recommendation, skincare_plan
  data/mock/                    ALL mock data (users, results, products,
                                ingredient rules, routine)
  services/                     interfaces + Mock implementations
    app_services.dart           ← single place to swap mock → real
  providers/                    UserProvider, ScanProvider, PlanProvider
  features/                     one folder per area (splash, auth, onboarding,
                                allergies, dashboard, scan, analysis,
                                recommendations, products, lifestyle,
                                planner, history, profile)
assets/images/                  logo, splash illustration, sample images
test/                           logic + widget/navigation tests
```

State management: **Provider** (`ChangeNotifier`s). Screens never call mock
data directly – they go through providers/services.

---

## 4. What currently uses mock data

| Area | Mock implementation | File |
|---|---|---|
| Login / sign-up / reset / Google | `MockAuthService` | `services/auth_service.dart` |
| Profile persistence | `MockProfileService` (no-op) | `services/profile_service.dart` |
| Scan history & upload | `MockScanService` | `services/scan_service.dart` |
| Skin analysis (ML) | `MockSkinAnalysisService` | `services/analysis_service.dart` |
| Demo findings / seeded history | `MockScanData` | `data/mock/mock_scan_data.dart` |
| Recommendations | `MockRecommendationService` | `services/recommendation_service.dart` |
| Products | `MockProducts` | `data/mock/mock_products.dart` |
| Routine & progress photos | `MockPlanService` / `MockPlan` | `services/plan_service.dart` |
| Heatmap | `DemoHeatmapOverlay` | `core/widgets/scan_image_view.dart` |
| Dermatologist booking, crop | placeholder dialogs | lifestyle / photo review screens |

Search the code for these markers to find every integration point:

```
FUTURE BACKEND INTEGRATION
FUTURE DATABASE INTEGRATION
FUTURE ML INTEGRATION
FUTURE IMAGE UPLOAD INTEGRATION / FUTURE IMAGE INTEGRATION
FUTURE HEATMAP INTEGRATION
FUTURE RECOMMENDATION INTEGRATION
```

---

## 5. Integration guide

**Main files you will modify**

1. `lib/services/app_services.dart` – replace each `Mock...()` with the real
   implementation. No screen needs to change.
2. `lib/services/auth_service.dart` – implement `AuthService` against your
   auth API / Firebase; store tokens securely; delete `mock_user_data.dart`.
3. `lib/services/profile_service.dart` – `saveProfile` → `PUT /users/{id}/profile`
   with `UserProfile.toJson()`.
4. `lib/services/scan_service.dart` – `uploadImage` (secure upload, return
   reference stored in `ScanImage.remoteReference`), `saveScan`,
   `fetchHistory`.
5. `lib/services/analysis_service.dart` – **ML model**: implement
   `SkinAnalysisService.analyze` to upload images, call the inference
   endpoint, emit `AnalysisProgress` stages and map the response to
   `ConcernFinding` (concern label, confidence, region, explanation,
   `heatmapReference`) with `isDemo: false`.
6. `lib/core/widgets/scan_image_view.dart` – replace `DemoHeatmapOverlay`
   with the real heatmap image from `ConcernFinding.heatmapReference`.
7. `lib/services/recommendation_service.dart` – call the recommendation API;
   keep allergy filtering server-side.
8. `lib/services/plan_service.dart` – persist routine completion per day and
   progress photos.
9. `lib/services/image_service.dart` / `features/scan/camera_screen.dart` –
   optional live preview with the `camera` package, real lighting checks,
   and `image_cropper` for Crop.

**Database:** everything is in memory today (`providers/`). All models have
`toJson()` and are shaped for persistence (ids, timestamps, references
instead of image bytes).

---

## 6. Limitations

* No real authentication, persistence, ML inference, heatmap, crop, lighting
  detection, push reminders or dermatologist booking – all clearly marked.
* Data resets when the app restarts or the user logs out.
* Tested with `flutter analyze` and `flutter test`; manual device testing on
  a physical Android phone is still recommended (camera intents).
