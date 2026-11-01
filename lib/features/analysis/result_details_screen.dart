import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/layout.dart';
import '../../models/skin_scan.dart';
import '../../providers/scan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// Expanded explanation of a result: every finding, what was submitted,
/// and next steps.
class ResultDetailsScreen extends StatelessWidget {
  const ResultDetailsScreen({super.key, this.scanId});

  final String? scanId;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<ScanProvider>().sessionById(scanId);
    final result = session?.result;
    if (session == null || result == null) {
      return const PageLayout(children: [
        EmptyState(
            icon: Icons.insights_outlined,
            title: 'Result not found',
            message: 'This scan has no result yet.'),
      ]);
    }

    return PageLayout(
      children: [
        Row(
          children: [
            Expanded(child: Text('Result details', style: AppTextStyles.h1)),
            if (result.isDemo) const DemoBadge(label: 'Demo result'),
          ],
        ),
        const SizedBox(height: 4),
        Text(
            '${session.type?.label ?? 'Scan'} · ${session.regionSummary} · ${Formatters.dateTime(result.generatedAt)}',
            style: AppTextStyles.small),
        const SizedBox(height: AppSpacing.xl),
        if (result.isDemo) ...[
          const InfoNote(
            icon: Icons.science_outlined,
            color: AppColors.blush,
            foreground: AppColors.clay,
            text:
                'These values are predefined demo data. No AI model analysed your photo in this build.',
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
        const SectionTitle('Findings'),
        for (final f in result.findings)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(f.concern, style: AppTextStyles.h3)),
                      Text('${f.confidencePercent}%',
                          style: AppTextStyles.h3
                              .copyWith(color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Region: ${f.regionLabel}', style: AppTextStyles.small),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    child: LinearProgressIndicator(
                      value: f.confidence,
                      minHeight: 6,
                      color: AppColors.primary,
                      backgroundColor: AppColors.surfaceMuted,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(f.explanation, style: AppTextStyles.body),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        const SectionTitle('Understanding confidence'),
        Text(
          'Confidence shows how strongly the image matches patterns the model '
          'has learned for a concern. It is not the probability that you have a '
          'condition, and it is not a medical diagnosis.',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionTitle('What you told us'),
        AppCard(child: _AnswersSummary(session: session)),
        const SizedBox(height: AppSpacing.xl),
        const SectionTitle('Next steps'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _NextStep(Icons.recommend_outlined, 'Recommended for you',
                  AppRoutes.recommendations),
              const Divider(height: 1),
              _NextStep(Icons.spa_outlined, 'Products & ingredients',
                  AppRoutes.products),
              const Divider(height: 1),
              _NextStep(Icons.self_improvement_outlined, 'Lifestyle guide',
                  AppRoutes.lifestyle),
              const Divider(height: 1),
              _NextStep(Icons.checklist_rounded, 'My plan & tracker',
                  AppRoutes.planner),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const InfoNote(
          icon: Icons.medical_services_outlined,
          text:
              'SkinGuard AI is not a medical device. If a patch changes quickly, bleeds, '
              'hurts or worries you, consult a dermatologist.',
        ),
      ],
    );
  }
}

class _AnswersSummary extends StatelessWidget {
  const _AnswersSummary({required this.session});

  final ScanSession session;

  @override
  Widget build(BuildContext context) {
    final rows = <(String, String)>[];
    if (session.type == ScanType.fullFace) {
      final a = session.fullFaceAnswers;
      rows.addAll([
        ('Goal', a.goals.map((g) => g.label).join(', ')),
        ('Sensitivity', _yesNo(a.generalSensitivity)),
        ('Daily sunscreen', _yesNo(a.dailySunscreen)),
        ('Routine rating',
            a.routineSatisfaction == 0 ? '—' : '${a.routineSatisfaction} / 5'),
        ('Other concerns', a.otherConcerns),
      ]);
    } else {
      final a = session.patchAnswers;
      rows.addAll([
        ('Regions', session.regionSummary),
        ('Description', a.description),
        ('Symptoms', a.symptoms.map((s) => s.label).join(', ')),
        ('Duration', a.duration?.label ?? ''),
        ('Treatments', a.treatments.map((t) => t.label).join(', ')),
        ('Product', [a.suspectedProduct?.label, a.productName]
            .whereType<String>()
            .where((s) => s.trim().isNotEmpty)
            .join(' – ')),
        ('Worse at', a.worseTimes.map((w) => w.label).join(', ')),
        ('Comment', a.finalComment),
      ]);
    }

    if (session.isDemoHistory) {
      return Text('Questionnaire answers are not stored for demo history entries.',
          style: AppTextStyles.bodySecondary);
    }

    return Column(
      children: [
        for (final (label, value) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                    width: 120,
                    child: Text(label, style: AppTextStyles.bodySecondary)),
                Expanded(
                    child: Text(value.trim().isEmpty ? '—' : value,
                        style: AppTextStyles.body)),
              ],
            ),
          ),
      ],
    );
  }

  static String _yesNo(bool? v) => v == null ? '—' : (v ? 'Yes' : 'No');
}

class _NextStep extends StatelessWidget {
  const _NextStep(this.icon, this.label, this.route);

  final IconData icon;
  final String label;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: AppTextStyles.body),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}
