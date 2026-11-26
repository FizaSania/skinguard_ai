import '../../app/routes.dart';

/// Switches for features that are built but reserved for FYP-2.
///
/// No feature code has been removed: set a flag to `true` (or call
/// `FeatureFlags.setAll(true)`) and its screen, link and content return.
class FeatureFlags {
  FeatureFlags._();

// Dashboard · Explore Skincare / bottom navigation
  static bool recommendations = true;
  static bool planner = false;
  static bool lifestyle = false;
  static bool history = true;

  // Skin Analysis page
  static bool heatmap = false;
  static bool whyThisResult = true;

  // Result Details page: finding explanations and confidence values
  static bool resultInsights = true;

  static void setAll(bool enabled) {
    recommendations = enabled;
    planner = enabled;
    lifestyle = enabled;
    history = enabled;
    heatmap = enabled;
    whyThisResult = enabled;
    resultInsights = enabled;
  }

  /// False for routes whose feature is currently "Coming Soon". The router
  /// uses this as a safety net so a hidden page cannot be opened by any link.
  static bool isRouteEnabled(String? route) => switch (route) {
        AppRoutes.recommendations => recommendations,
        AppRoutes.planner || AppRoutes.compareScans => planner,
        AppRoutes.lifestyle => lifestyle,
        _ => true,
      };
}
