import 'analysis_service.dart';
import 'api_analysis_service.dart';
import 'api_auth_service.dart';
import 'api_client.dart';
import 'api_profile_service.dart';
import 'api_recommendation_service.dart';
import 'api_scan_service.dart';
import 'auth_service.dart';
import 'image_service.dart';
import 'plan_service.dart';
import 'profile_service.dart';
import 'recommendation_service.dart';
import 'scan_service.dart';

/// Single place where service implementations are chosen.
class AppServices {
  AppServices({
    ApiClient? apiClient,
    AuthService? auth,
    ProfileService? profile,
    ScanService? scan,
    SkinAnalysisService? analysis,
    ImageService? image,
    RecommendationService? recommendations,
    PlanService? plan,
  }) : this._init(
          apiClient ?? ApiClient(),
          auth: auth,
          profile: profile,
          scan: scan,
          analysis: analysis,
          image: image,
          recommendations: recommendations,
          plan: plan,
        );

  AppServices._init(
    this.apiClient, {
    AuthService? auth,
    ProfileService? profile,
    ScanService? scan,
    SkinAnalysisService? analysis,
    ImageService? image,
    RecommendationService? recommendations,
    PlanService? plan,
  })  : auth = auth ?? ApiAuthService(apiClient),
        profile = profile ?? ApiProfileService(apiClient),
        scan = scan ?? ApiScanService(apiClient),
        analysis = analysis ?? ApiAnalysisService(apiClient),
        image = image ?? DeviceImageService(),
        recommendations =
            recommendations ?? ApiRecommendationService(apiClient),
        plan = plan ?? MockPlanService();

  final ApiClient apiClient;
  final AuthService auth;
  final ProfileService profile;
  final ScanService scan;
  final SkinAnalysisService analysis;
  final ImageService image;
  final RecommendationService recommendations;
  final PlanService plan;
}