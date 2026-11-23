import 'package:flutter/material.dart';

import '../../../core/widgets/coming_soon.dart';
import '../../../core/widgets/layout.dart';
import '../../../models/skin_concern.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';

/// Concern-specific section of the Skin Analysis page. Values come from the
/// [ConcernFinding]; rows without data are not shown.
class ConcernInsights extends StatelessWidget {
  const ConcernInsights({super.key, required this.finding});

  final ConcernFinding finding;

  @override
  Widget build(BuildContext context) {
    final Widget? content = switch (finding.kind) {
      ConcernKind.acne => _acneContent(finding.acne),
      ConcernKind.redness ||
      ConcernKind.pigmentation =>
        _DoctorReferralContent(concern: finding.concern),
      ConcernKind.other => null,
    };
    if (content == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: content,
    );
  }

  Widget? _acneContent(AcneAssessment? acne) {
    if (acne == null) return null;
    final stageConfidence = acne.stageConfidence;
    final rows = <(String, String)>[
      if (acne.spotCount case final spots?) ('Spots counted', '$spots'),
      if (acne.severity case final severity?) ('Severity', severity),
      if (acne.stage case final stage?) ('Stage', stage),
      if (stageConfidence != null)
        ('Stage confidence', '${(stageConfidence * 100).round()}%'),
    ];
    final advice = acne.advice;
    if (rows.isEmpty && advice == null) return null;

    return Column(
      children: [
        if (rows.isNotEmpty)
          AppCard(
            child: Column(
              children: [
                for (final (label, value) in rows) _InsightRow(label, value),
              ],
            ),
          ),
        if (advice != null) ...[
          if (rows.isNotEmpty) const SizedBox(height: AppSpacing.md),
          InfoNote(icon: Icons.medical_services_outlined, text: advice),
        ],
      ],
    );
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Expanded(child: Text(label, style: AppTextStyles.bodySecondary)),
          Text(value, style: AppTextStyles.title),
        ],
      ),
    );
  }
}

class _DoctorReferralContent extends StatelessWidget {
  const _DoctorReferralContent({required this.concern});

  final String concern;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$concern has been detected.', style: AppTextStyles.title),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text('Detailed analysis',
                        style: AppTextStyles.bodySecondary),
                  ),
                  const ComingSoonTag(),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        InfoNote(
          icon: Icons.medical_services_outlined,
          color: AppColors.blush,
          foreground: AppColors.clay,
          text: 'Since ${concern.toLowerCase()} is detected, please visit a '
              'doctor for professional details.',
        ),
      ],
    );
  }
}
