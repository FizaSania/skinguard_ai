import 'analysis_service.dart';
import 'auth_service.dart';
import 'image_service.dart';
import 'plan_service.dart';
import 'profile_service.dart';
import 'recommendation_service.dart';
import 'scan_service.dart';

/// Single place where service implementations are chosen.
///
/// FUTURE BACKEND / ML / DATABASE INTEGRATION:
/// Swap each `Mock...` class for its real implementation here – no screen
/// needs to change.
class AppServices {
  AppServices({
    AuthService? auth,
    ProfileService? profile,
    ScanService? scan,
    SkinAnalysisService? analysis,
    ImageService? image,
    RecommendationService? recommendations,
    PlanService? plan,
  })  : auth = auth ?? MockAuthService(),
        profile = profile ?? MockProfileService(),
        scan = scan ?? MockScanService(),
        analysis = analysis ?? MockSkinAnalysisService(),
        image = image ?? DeviceImageService(),
        recommendations = recommendations ?? MockRecommendationService(),
        plan = plan ?? MockPlanService();

  final AuthService auth;
  final ProfileService profile;
  final ScanService scan;
  final SkinAnalysisService analysis;
  final ImageService image;
  final RecommendationService recommendations;
  final PlanService plan;
}
