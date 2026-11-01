import 'skin_concern.dart';

enum ScanType {
  fullFace('Full Face'),
  patch('Detailed Patch');

  const ScanType(this.label);
  final String label;
}

enum FaceRegion {
  forehead('Forehead', 'Forehead'),
  leftCheek('Left Cheek', 'L Cheek'),
  rightCheek('Right Cheek', 'R Cheek'),
  nose('Nose', 'Nose'),
  lips('Lips', 'Lips'),
  chin('Chin', 'Chin');

  const FaceRegion(this.label, this.shortLabel);
  final String label;
  final String shortLabel;
}

enum ScanStatus { draft, capturing, analyzing, completed, failed }

enum SkincareGoal {
  hydration('Hydration'),
  brightening('Brightening'),
  antiAging('Anti-aging'),
  texture('Texture'),
  acnePrevention('Acne prevention');

  const SkincareGoal(this.label);
  final String label;
}

enum PatchSymptom {
  redness('Redness'),
  itching('Itching'),
  scaling('Scaling'),
  swelling('Swelling'),
  bumps('Bumps'),
  pain('Pain');

  const PatchSymptom(this.label);
  final String label;
}

enum PatchDuration {
  underOneWeek('Under 1 week'),
  oneToFourWeeks('1–4 weeks'),
  oneToThreeMonths('1–3 months'),
  overThreeMonths('Over 3 months');

  const PatchDuration(this.label);
  final String label;
}

enum PreviousTreatment {
  none('None'),
  storeBought('Store-bought'),
  prescription('Prescription'),
  homeRemedies('Home remedies');

  const PreviousTreatment(this.label);
  final String label;
}

enum SuspectedProduct {
  faceWash('Face wash'),
  moisturizer('Moisturizer'),
  sunscreen('Sunscreen'),
  makeup('Makeup'),
  noProduct('No product'),
  other('Other');

  const SuspectedProduct(this.label);
  final String label;
}

enum WorseTime {
  morning('Morning'),
  night('Night'),
  afterSun('After sun'),
  afterProducts('After products');

  const WorseTime(this.label);
  final String label;
}

/// Answers from the "Full face details" questionnaire.
class FullFaceAnswers {
  final Set<SkincareGoal> goals = {};
  bool? generalSensitivity;
  bool? dailySunscreen;
  int routineSatisfaction = 0; // 0 = not rated, 1–5 stars
  String otherConcerns = '';

  bool get isComplete =>
      goals.isNotEmpty &&
      generalSensitivity != null &&
      dailySunscreen != null &&
      routineSatisfaction > 0;

  Map<String, dynamic> toJson() => {
        'goals': goals.map((g) => g.name).toList(),
        'generalSensitivity': generalSensitivity,
        'dailySunscreen': dailySunscreen,
        'routineSatisfaction': routineSatisfaction,
        'otherConcerns': otherConcerns,
      };
}

/// Answers from both "Patch details" pages.
class PatchAnswers {
  // Page 1
  String description = '';
  final Set<PatchSymptom> symptoms = {};
  PatchDuration? duration;
  final Set<PreviousTreatment> treatments = {};

  // Page 2
  SuspectedProduct? suspectedProduct;
  String productName = ''; // optional free text ("Search product")
  final Set<WorseTime> worseTimes = {};
  String finalComment = '';

  bool get isPage1Complete => symptoms.isNotEmpty && duration != null;

  bool get isPage2Complete => suspectedProduct != null;

  Map<String, dynamic> toJson() => {
        'description': description,
        'symptoms': symptoms.map((s) => s.name).toList(),
        'duration': duration?.name,
        'treatments': treatments.map((t) => t.name).toList(),
        'suspectedProduct': suspectedProduct?.name,
        'productName': productName,
        'worseTimes': worseTimes.map((w) => w.name).toList(),
        'finalComment': finalComment,
      };
}

/// A single captured / uploaded photo belonging to a scan session.
///
/// Only a reference (file path or asset path) is stored – never the image
/// bytes – so the model stays light and can be persisted later.
class ScanImage {
  ScanImage({
    required this.path,
    required this.sessionId,
    required this.capturedAt,
    this.region,
    this.isSample = false,
    this.quarterTurns = 0,
  });

  /// Device file path, web blob URL, or asset path when [isSample] is true.
  final String path;

  /// Null for a full-face image.
  final FaceRegion? region;

  // FUTURE BACKEND INTEGRATION: replace the local session id with the id
  // returned by the scan API when the session is created server-side.
  final String sessionId;

  final DateTime capturedAt;

  /// True when the bundled demo image was used instead of a real photo.
  final bool isSample;

  /// Rotation applied on the review screen (0–3 quarter turns).
  int quarterTurns;

  // FUTURE IMAGE UPLOAD INTEGRATION: populated with the storage URL / id
  // after the image has been uploaded securely.
  String? remoteReference;

  String get targetLabel => region?.label ?? 'Full Face';

  Map<String, dynamic> toJson() => {
        'path': path,
        'region': region?.name,
        'sessionId': sessionId,
        'capturedAt': capturedAt.toIso8601String(),
        'isSample': isSample,
        'quarterTurns': quarterTurns,
        'remoteReference': remoteReference,
      };
}

/// One complete scan: type, regions, questionnaire answers, images and
/// (once analysed) the result.
class ScanSession {
  ScanSession({
    required this.id,
    required this.createdAt,
    this.type,
    Set<FaceRegion>? regions,
    this.status = ScanStatus.draft,
    this.isDemoHistory = false,
  }) : regions = regions ?? <FaceRegion>{};

  final String id;
  final DateTime createdAt;
  ScanType? type;
  final Set<FaceRegion> regions;
  final FullFaceAnswers fullFaceAnswers = FullFaceAnswers();
  final PatchAnswers patchAnswers = PatchAnswers();
  final List<ScanImage> images = [];
  ScanStatus status;
  AnalysisResult? result;

  /// Seeded entries shown in History for demonstration.
  final bool isDemoHistory;

  /// Regions in a stable order (the order they appear on the face map).
  List<FaceRegion> get orderedRegions =>
      FaceRegion.values.where(regions.contains).toList();

  /// Capture targets: a single null target for full face, otherwise one
  /// per selected region.
  List<FaceRegion?> get captureTargets =>
      type == ScanType.patch ? orderedRegions : const [null];

  ScanImage? imageFor(FaceRegion? region) {
    for (final image in images) {
      if (image.region == region) return image;
    }
    return null;
  }

  bool get allImagesCaptured =>
      type != null && captureTargets.every((t) => imageFor(t) != null);

  String get regionSummary => type == ScanType.fullFace
      ? 'Full Face'
      : orderedRegions.map((r) => r.label).join(', ');

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'type': type?.name,
        'regions': orderedRegions.map((r) => r.name).toList(),
        'fullFaceAnswers':
            type == ScanType.fullFace ? fullFaceAnswers.toJson() : null,
        'patchAnswers': type == ScanType.patch ? patchAnswers.toJson() : null,
        'images': images.map((i) => i.toJson()).toList(),
        'status': status.name,
      };
}
