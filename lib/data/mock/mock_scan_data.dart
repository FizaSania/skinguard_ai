import '../../core/constants/app_assets.dart';
import '../../models/skin_concern.dart';
import '../../models/skin_scan.dart';

/// Predefined DEMO findings. These are not predictions – they exist only so
/// the result screens can be demonstrated before the ML model is connected.
///
/// FUTURE ML INTEGRATION: delete this file once SkinAnalysisService returns
/// real model output.
class MockScanData {
  MockScanData._();

  static const ConcernFinding fullFaceFinding = ConcernFinding(
    concern: 'Acne',
    confidence: 0.87,
    region: null,
    affectedRegions: [FaceRegion.forehead],
    acne: _moderateAcne,
    explanation:
        'The model detected visual characteristics associated with acne, such '
        'as clustered red bumps on the forehead. This is not a medical diagnosis.',
  );

  static const _optionalDoctorAdvice =
      'Acne is not severe yet. A doctor visit is optional; consult one only '
      'if it worries you or you want professional advice.';

  static const AcneAssessment _moderateAcne = AcneAssessment(
    spotCount: 12,
    severity: 'Moderate',
    stage: 'Stage 2',
    stageConfidence: 0.82,
    advice: _optionalDoctorAdvice,
  );

  static const AcneAssessment _mildAcne = AcneAssessment(
    spotCount: 5,
    severity: 'Mild',
    stage: 'Stage 1',
    stageConfidence: 0.78,
    advice: _optionalDoctorAdvice,
  );

  static const Map<FaceRegion, ConcernFinding> regionFindings = {
    FaceRegion.forehead: ConcernFinding(
      concern: 'Acne',
      confidence: 0.87,
      region: FaceRegion.forehead,
      acne: _moderateAcne,
      explanation:
          'The model detected visual characteristics associated with acne, such '
          'as clustered red bumps on the forehead. This is not a medical diagnosis.',
    ),
    FaceRegion.leftCheek: ConcernFinding(
      concern: 'Pigmentation',
      confidence: 0.74,
      region: FaceRegion.leftCheek,
      explanation:
          'The model detected areas of uneven, darker tone on the left cheek, '
          'which are associated with pigmentation. This is not a medical diagnosis.',
    ),
    FaceRegion.rightCheek: ConcernFinding(
      concern: 'Redness',
      confidence: 0.71,
      region: FaceRegion.rightCheek,
      explanation:
          'The model detected visible redness on the right cheek. This is not '
          'a medical diagnosis.',
    ),
    FaceRegion.nose: ConcernFinding(
      concern: 'Enlarged pores',
      confidence: 0.69,
      region: FaceRegion.nose,
      explanation:
          'The model detected visible, enlarged pores across the nose. This is '
          'not a medical diagnosis.',
    ),
    FaceRegion.lips: ConcernFinding(
      concern: 'Dryness',
      confidence: 0.72,
      region: FaceRegion.lips,
      explanation:
          'The model detected flaking and fine lines associated with dryness '
          'around the lips. This is not a medical diagnosis.',
    ),
    FaceRegion.chin: ConcernFinding(
      concern: 'Acne',
      confidence: 0.81,
      region: FaceRegion.chin,
      acne: _mildAcne,
      explanation:
          'The model detected raised red bumps on the chin associated with acne. '
          'This is not a medical diagnosis.',
    ),
  };

  /// Two clearly-labelled demo scans so History, Latest Results and
  /// Compare Scans have something to show on first launch.
  static List<ScanSession> seededHistory() {
    final now = DateTime.now();

    final older = ScanSession(
      id: 'demo-scan-1',
      createdAt: now.subtract(const Duration(days: 21)),
      type: ScanType.patch,
      regions: {FaceRegion.forehead},
      status: ScanStatus.completed,
      isDemoHistory: true,
    );
    older.images.add(ScanImage(
      path: AppAssets.sampleProgress[0],
      region: FaceRegion.forehead,
      sessionId: older.id,
      capturedAt: older.createdAt,
      isSample: true,
    ));
    older.result = AnalysisResult(
      scanId: older.id,
      findings: [regionFindings[FaceRegion.forehead]!],
      generatedAt: older.createdAt,
      isDemo: true,
    );

    final recent = ScanSession(
      id: 'demo-scan-2',
      createdAt: now.subtract(const Duration(days: 4)),
      type: ScanType.fullFace,
      status: ScanStatus.completed,
      isDemoHistory: true,
    );
    recent.images.add(ScanImage(
      path: AppAssets.sampleProgress[2],
      sessionId: recent.id,
      capturedAt: recent.createdAt,
      isSample: true,
    ));
    recent.result = AnalysisResult(
      scanId: recent.id,
      findings: const [fullFaceFinding],
      generatedAt: recent.createdAt,
      isDemo: true,
    );

    // Newest first.
    return [recent, older];
  }
}
