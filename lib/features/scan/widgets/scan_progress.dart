import 'package:flutter/material.dart';

import '../../../core/widgets/layout.dart';
import '../../../models/skin_scan.dart';

/// Scan-setup progress, kept separate from onboarding progress.
///
/// Full face: 1 Region & mode → 2 Questionnaire → 3 Photo.
/// Patch:     1 Region & mode → 2 Details p1 → 3 Details p2 → 4 Photos.
class ScanStepProgress extends StatelessWidget {
  const ScanStepProgress({super.key, required this.step, required this.type});

  final int step;
  final ScanType? type;

  static int totalFor(ScanType? type) => type == ScanType.patch ? 4 : 3;

  @override
  Widget build(BuildContext context) {
    return StepProgress(
      step: step,
      total: totalFor(type),
      caption: switch (type) {
        ScanType.patch => 'Scan setup · Patch assessment',
        ScanType.fullFace => 'Scan setup · Full face analysis',
        null => 'Scan setup',
      },
    );
  }
}
