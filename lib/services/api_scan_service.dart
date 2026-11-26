import '../models/skin_concern.dart';
import '../models/skin_scan.dart';
import 'api_analysis_service.dart';
import 'api_client.dart';
import 'scan_service.dart';

/// Live FastAPI implementation of [ScanService] backed by GET /scans.
class ApiScanService implements ScanService {
  ApiScanService(this._client);

  final ApiClient _client;

  @override
  Future<List<ScanSession>> fetchHistory() async {
    final token = await _client.getToken();
    if (token == null || token.isEmpty) return [];

    try {
      final rawList = await _client.getJson('/scans');
      if (rawList is! List) return [];

      final sessions = <ScanSession>[];
      for (final item in rawList) {
        if (item is! Map) continue;
        final map = Map<String, dynamic>.from(item);

        // Skip scans rejected by the CV quality check so history only shows valid analyses.
        if (map['quality_check_passed'] == false) continue;

        final id = map['id']?.toString() ?? '';
        if (id.isEmpty) continue;

        final createdAt = DateTime.tryParse(map['created_at']?.toString() ?? '') ??
            DateTime.now();
        final region = ApiAnalysisService.apiToRegion(
          map['patch_region'] as String?,
        );
        final scanType = region == null ? ScanType.fullFace : ScanType.patch;

        final session = ScanSession(
          id: id,
          createdAt: createdAt,
          type: scanType,
          regions: region == null ? null : {region},
          status: ScanStatus.completed,
          isDemoHistory: false,
        );

        final finding = ApiAnalysisService.parseFindingFromScanJson(map);
        session.result = AnalysisResult(
          scanId: id,
          findings: [finding],
          generatedAt: createdAt,
          isDemo: false,
        );

        sessions.add(session);
      }

      return sessions;
    } on ApiException {
      return [];
    }
  }

  @override
  Future<void> saveScan(ScanSession session) async {
    // Already persisted in PostgreSQL during POST /scans in ApiAnalysisService.
  }

  @override
  Future<String> uploadImage(ScanImage image) async {
    return image.remoteReference ?? image.path;
  }
}