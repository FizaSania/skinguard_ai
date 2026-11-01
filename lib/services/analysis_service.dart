import '../data/mock/mock_scan_data.dart';
import '../models/skin_concern.dart';
import '../models/skin_scan.dart';

class AnalysisException implements Exception {
  const AnalysisException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// ML analysis boundary. The UI only depends on this interface – demo
/// predictions are never hardcoded inside widgets.
abstract class SkinAnalysisService {
  /// Emits one [AnalysisProgress] per stage; the last event carries the
  /// [AnalysisResult]. Errors are emitted as [AnalysisException].
  Stream<AnalysisProgress> analyze(ScanSession session);
}

/// Returns predefined DEMO results after a short simulated delay.
/// No image is inspected and no inference happens.
///
/// FUTURE ML INTEGRATION:
/// Replace this mock analysis service with the actual skin analysis
/// endpoint, e.g.
///   1. upload each `session.images` (ScanService.uploadImage)
///   2. POST /analysis { scanId, type, regions, answers, imageRefs }
///   3. poll / listen for stage updates and map them to [AnalysisStage]
///   4. map the response to [ConcernFinding]s (label, confidence, region,
///      explanation, heatmap URL) and return an [AnalysisResult] with
///      `isDemo: false`.
class MockSkinAnalysisService implements SkinAnalysisService {
  MockSkinAnalysisService({this.stageDelay = const Duration(milliseconds: 1100)});

  final Duration stageDelay;

  /// Demo option (Profile → Demo options) to preview the error state.
  bool simulateFailure = false;

  @override
  Stream<AnalysisProgress> analyze(ScanSession session) async* {
    for (final stage in AnalysisStage.values) {
      yield AnalysisProgress(stage);
      await Future.delayed(stageDelay);
      if (simulateFailure && stage == AnalysisStage.analyzing) {
        throw const AnalysisException(
            'We could not analyse your photo. Check your connection and try again.');
      }
    }

    yield AnalysisProgress(
      AnalysisStage.generating,
      result: AnalysisResult(
        scanId: session.id,
        findings: _demoFindingsFor(session),
        generatedAt: DateTime.now(),
        isDemo: true,
      ),
    );
  }

  /// Only returns findings for the areas that were actually captured.
  List<ConcernFinding> _demoFindingsFor(ScanSession session) {
    if (session.type == ScanType.fullFace) {
      return const [MockScanData.fullFaceFinding];
    }
    return [
      for (final region in session.orderedRegions)
        if (session.imageFor(region) != null)
          MockScanData.regionFindings[region]!,
    ];
  }
}
