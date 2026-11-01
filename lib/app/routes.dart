import 'package:flutter/material.dart';

import '../features/allergies/my_allergies_screen.dart';
import '../features/analysis/analyzing_screen.dart';
import '../features/analysis/result_details_screen.dart';
import '../features/analysis/results_screen.dart';
import '../features/auth/forgot_password_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/signup_screen.dart';
import '../features/dashboard/main_shell.dart';
import '../features/lifestyle/lifestyle_screen.dart';
import '../features/onboarding/allergies_step_screen.dart';
import '../features/onboarding/profile_step_screen.dart';
import '../features/onboarding/skin_type_step_screen.dart';
import '../features/planner/compare_scans_screen.dart';
import '../features/planner/planner_screen.dart';
import '../features/products/product_detail_screen.dart';
import '../features/products/products_screen.dart';
import '../features/recommendations/recommendations_screen.dart';
import '../features/scan/camera_screen.dart';
import '../features/scan/full_face_questionnaire_screen.dart';
import '../features/scan/patch_details_page1_screen.dart';
import '../features/scan/patch_details_page2_screen.dart';
import '../features/scan/photo_review_screen.dart';
import '../features/scan/scan_selection_screen.dart';
import '../features/splash/splash_screen.dart';
import '../models/skin_scan.dart';

/// All route names in one place.
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';

  static const onboardingProfile = '/onboarding/profile';
  static const onboardingSkin = '/onboarding/skin';
  static const onboardingAllergies = '/onboarding/allergies';

  static const shell = '/home';
  static const myAllergies = '/allergies';

  static const scanSelection = '/scan';
  static const fullFaceQuestionnaire = '/scan/full-face';
  static const patchDetails1 = '/scan/patch-1';
  static const patchDetails2 = '/scan/patch-2';
  static const camera = '/scan/camera';
  static const photoReview = '/scan/review';
  static const analyzing = '/scan/analyzing';

  static const results = '/results';
  static const resultDetails = '/results/details';

  static const recommendations = '/recommendations';
  static const products = '/products';
  static const productDetail = '/products/detail';
  static const lifestyle = '/lifestyle';
  static const planner = '/planner';
  static const compareScans = '/planner/compare';
}

/// Arguments for onboarding screens. `editing` is true when re-opened from
/// the Profile tab, so finishing returns to the app instead of restarting.
class OnboardingArgs {
  const OnboardingArgs({this.editing = false});
  final bool editing;
}

/// Which capture target a review screen shows (null region = full face).
class ReviewArgs {
  const ReviewArgs(this.region);
  final FaceRegion? region;
}

class AppRouter {
  AppRouter._();

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final onboarding =
        args is OnboardingArgs ? args : const OnboardingArgs();

    Widget page;
    switch (settings.name) {
      case AppRoutes.splash:
        page = const SplashScreen();
      case AppRoutes.login:
        page = const LoginScreen();
      case AppRoutes.signup:
        page = const SignUpScreen();
      case AppRoutes.forgotPassword:
        page = ForgotPasswordScreen(initialEmail: args as String?);
      case AppRoutes.onboardingProfile:
        page = ProfileStepScreen(args: onboarding);
      case AppRoutes.onboardingSkin:
        page = SkinTypeStepScreen(args: onboarding);
      case AppRoutes.onboardingAllergies:
        page = AllergiesStepScreen(args: onboarding);
      case AppRoutes.shell:
        page = MainShell(initialTab: args is int ? args : 0);
      case AppRoutes.myAllergies:
        page = const MyAllergiesScreen();
      case AppRoutes.scanSelection:
        page = const ScanSelectionScreen();
      case AppRoutes.fullFaceQuestionnaire:
        page = const FullFaceQuestionnaireScreen();
      case AppRoutes.patchDetails1:
        page = const PatchDetailsPage1Screen();
      case AppRoutes.patchDetails2:
        page = const PatchDetailsPage2Screen();
      case AppRoutes.camera:
        page = const CameraScreen();
      case AppRoutes.photoReview:
        page = PhotoReviewScreen(
            region: args is ReviewArgs ? args.region : null);
      case AppRoutes.analyzing:
        page = const AnalyzingScreen();
      case AppRoutes.results:
        page = ResultsScreen(scanId: args as String?);
      case AppRoutes.resultDetails:
        page = ResultDetailsScreen(scanId: args as String?);
      case AppRoutes.recommendations:
        page = const RecommendationsScreen();
      case AppRoutes.products:
        page = const ProductsScreen();
      case AppRoutes.productDetail:
        page = ProductDetailScreen(productId: args as String);
      case AppRoutes.lifestyle:
        page = const LifestyleScreen();
      case AppRoutes.planner:
        page = const PlannerScreen();
      case AppRoutes.compareScans:
        page = const CompareScansScreen();
      default:
        page = const _UnknownRouteScreen();
    }
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('Page not found')),
      );
}
