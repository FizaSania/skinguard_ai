import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/skin_concern.dart';
import '../models/skin_scan.dart';
import 'analysis_service.dart';
import 'api_client.dart';

typedef JsonMap = Map<String, dynamic>;

/// Live FastAPI implementation of [SkinAnalysisService] backed by POST /scans.
class ApiAnalysisService implements SkinAnalysisService {
  ApiAnalysisService(this._client);

  final ApiClient _client;

  @override
  Stream<AnalysisProgress> analyze(ScanSession session) async* {
    if (session.images.isEmpty) {
      throw const AnalysisException(
        'Please capture or upload at least one photo before running analysis.',
      );
    }

    yield const AnalysisProgress(AnalysisStage.detecting);

    final findings = <ConcernFinding>[];
    String? primaryServerScanId;
    String? modelVersion;

    final hasRedFlags = session.type == ScanType.patch &&
        (session.patchAnswers.symptoms.contains(PatchSymptom.pain) ||
            session.patchAnswers.symptoms.contains(PatchSymptom.swelling));

    for (var i = 0; i < session.images.length; i++) {
      final scanImage = session.images[i];
      final bytes = await _readImageBytes(scanImage);
      final patchRegion = _regionToApi(scanImage.region);
      final filename = 'scan_$patchRegion.jpg';

      if (i == 0) {
        yield const AnalysisProgress(AnalysisStage.analyzing);
      }

      JsonMap response;
      try {
        final raw = await _client.postMultipart(
          '/scans',
          fileBytes: bytes,
          filename: filename,
          fileField: 'image',
          fields: {
            'patch_region': patchRegion,
            'red_flags': hasRedFlags ? 'true' : 'false',
          },
        );
        response = Map<String, dynamic>.from(raw as Map);
      } on ApiException catch (e) {
        throw AnalysisException(e.message);
      }

      final qc = response['quality_check'] as Map<String, dynamic>?;
      final passed = qc?['passed'] == true;
      if (!passed) {
        final reason = qc?['reason']?.toString();
        throw AnalysisException(_friendlyQualityReason(reason));
      }

      final serverScanId = response['scan_id']?.toString() ?? session.id;
      primaryServerScanId ??= serverScanId;
      modelVersion ??= response['model_version']?.toString();

      // Cache full payload under both server scan_id and local session.id
      _client.scanCache[serverScanId] = response;
      _client.scanCache[session.id] = response;
      scanImage.remoteReference = 'scan://$serverScanId';

      findings.add(parseFindingFromScanJson(
        response,
        regionOverride: scanImage.region,
      ));
    }

    yield const AnalysisProgress(AnalysisStage.generating);

    yield AnalysisProgress(
      AnalysisStage.generating,
      result: AnalysisResult(
        scanId: primaryServerScanId ?? session.id,
        findings: findings,
        generatedAt: DateTime.now(),
        isDemo: false,
        modelVersion: modelVersion,
      ),
    );
  }

  Future<List<int>> _readImageBytes(ScanImage image) async {
    try {
      if (image.isSample) {
        final data = await rootBundle.load(image.path);
        return data.buffer.asUint8List();
      }
      final bytes = await XFile(image.path).readAsBytes();
      if (bytes.isEmpty) {
        throw const AnalysisException('Selected image file is empty.');
      }
      return bytes;
    } on AnalysisException {
      rethrow;
    } catch (_) {
      throw const AnalysisException(
        'Could not read the selected photo. Please pick or capture it again.',
      );
    }
  }

  static String _regionToApi(FaceRegion? region) => switch (region) {
        null => 'full_face',
        FaceRegion.forehead => 'forehead',
        FaceRegion.leftCheek => 'left_cheek',
        FaceRegion.rightCheek => 'right_cheek',
        FaceRegion.nose => 'nose',
        FaceRegion.lips => 'lips',
        FaceRegion.chin => 'chin',
      };

  static FaceRegion? apiToRegion(String? value) =>
      switch (value?.trim().toLowerCase()) {
        'forehead' => FaceRegion.forehead,
        'left_cheek' => FaceRegion.leftCheek,
        'right_cheek' => FaceRegion.rightCheek,
        'nose' => FaceRegion.nose,
        'lips' => FaceRegion.lips,
        'chin' => FaceRegion.chin,
        _ => null,
      };

  static ConcernFinding parseFindingFromScanJson(
    Map<String, dynamic> data, {
    FaceRegion? regionOverride,
  }) {
    final rawConcern = (data['concern'] as String?)?.trim() ?? '';
    final displayConcern = formatConcernLabel(rawConcern);
    final rawConf = (data['confidence'] as num?)?.toDouble() ?? 0.0;
    final normalizedConf =
        (rawConf > 1.0 ? rawConf / 100.0 : rawConf).clamp(0.0, 1.0);

    final stageNum = (data['stage'] as num?)?.toInt();
    final stageLabel = (data['stage_label'] as String?)?.trim();
    final lesionCount = (data['lesion_count'] as num?)?.toInt();
    final message = (data['message'] as String?)?.trim();
    final referral = (data['referral'] as String?)?.trim();

    final isAcne = rawConcern.toLowerCase() == 'acne';
    final acne = isAcne
        ? AcneAssessment(
            spotCount: lesionCount,
            severity: _severityLabel(stageNum, stageLabel),
            stage: stageNum != null
                ? 'Stage $stageNum'
                : (stageLabel != null && stageLabel.isNotEmpty
                    ? stageLabel
                    : null),
            stageConfidence: normalizedConf,
            advice: (message != null && message.isNotEmpty) ? message : null,
          )
        : null;

    final explanation = (message != null && message.isNotEmpty)
        ? message
        : _defaultExplanation(displayConcern, referral);

    return ConcernFinding(
      concern: displayConcern,
      confidence: normalizedConf,
      region: regionOverride ?? apiToRegion(data['patch_region'] as String?),
      explanation: explanation,
      acne: acne,
    );
  }

  static String formatConcernLabel(String raw) {
    final cleaned = raw.trim().toLowerCase();
    return switch (cleaned) {
      '' || 'clear' || 'none' => 'Clear Skin',
      'acne' => 'Acne',
      'redness' => 'Redness',
      'pigmentation' => 'Pigmentation',
      'hyperpigmentation' => 'Hyperpigmentation',
      'uncertain' => 'Uncertain',
      _ => cleaned
          .split('_')
          .where((w) => w.isNotEmpty)
          .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' '),
    };
  }

  static String? _severityLabel(int? stage, String? stageLabel) {
    if (stageLabel != null && stageLabel.isNotEmpty) {
      final lower = stageLabel.toLowerCase();
      if (lower.contains('severe')) return 'Severe';
      if (lower.contains('moderate')) return 'Moderate';
      if (lower.contains('mild')) return 'Mild';
    }
    return switch (stage) {
      1 => 'Mild',
      2 => 'Moderate',
      3 || 4 => 'Severe',
      _ => null,
    };
  }

  static String _defaultExplanation(String concern, String? referral) {
    if (concern == 'Clear Skin') {
      return 'No significant active skin concern was detected in this scan.';
    }
    if (referral != null && referral.isNotEmpty) {
      return 'Detected $concern. Dermatologist referral status: $referral.';
    }
    return 'SkinGuard AI detected signs of $concern in your uploaded photo.';
  }

  static String _friendlyQualityReason(String? reason) {
    final code = (reason ?? '').trim().toLowerCase();
    if (code.contains('blur')) {
      return 'Your photo is too blurry. Hold the camera steady in good light and try again.';
    }
    if (code.contains('dark') || code.contains('low_light')) {
      return 'The lighting is too dark. Move to a well-lit area facing natural light and retake.';
    }
    if (code.contains('bright') || code.contains('overexposed')) {
      return 'The photo is overexposed. Avoid harsh direct glare and retake.';
    }
    if (code.contains('face') || code.contains('skin')) {
      return 'Could not clearly detect your face/skin area. Center your face in frame and retake.';
    }
    if (code.contains('unreadable')) {
      return 'The uploaded image could not be read. Please choose a valid JPG or PNG photo.';
    }
    return code.isEmpty
        ? 'Photo quality check failed. Please retake a clear, well-lit photo.'
        : 'Photo quality check failed (${code.replaceAll('_', ' ')}). Please retake in clear lighting.';
  }
}