import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/layout.dart';
import '../../core/widgets/scan_image_view.dart';
import '../../core/widgets/selection.dart';
import '../../models/skin_concern.dart';
import '../../providers/scan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// Skin Analysis result for one scan (latest scan when [scanId] is null).
/// All values come from the scan's [AnalysisResult] – never from widgets.
class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, this.scanId});

  final String? scanId;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  int _view = 0; // 0 = original, 1 = heatmap
  int _findingIndex = 0;

  void _newScan() {
    context.read<ScanProvider>().startNewScan();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.scanSelection,
      (route) => route.settings.name == AppRoutes.shell,
    );
  }

  void _close() {
    // Results opened right after an analysis sit directly above the shell.
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final scans = context.watch<ScanProvider>();
    final session = scans.sessionById(widget.scanId);
    final result = session?.result;

    if (session == null || result == null || result.findings.isEmpty) {
      return PageLayout(children: [
        const PageHeading('Skin Analysis'),
        EmptyState(
          icon: Icons.insights_outlined,
          title: 'No results yet',
          message: scans.historyLoaded
              ? 'Run a skin analysis to see your results here.'
              : 'Loading your results…',
          actionLabel: 'Start Skin Analysis',
          onAction: _newScan,
        ),
      ]);
    }

    final findings = result.findings;
    final finding = findings[_findingIndex.clamp(0, findings.length - 1)];
    final image = session.imageFor(finding.region) ??
        (session.images.isEmpty ? null : session.images.first);

    return PageLayout(
      onBack: _close,
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(
            label: 'View Details',
            onPressed: () => Navigator.pushNamed(
                context, AppRoutes.resultDetails,
                arguments: session.id),
          ),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(label: 'New Scan', onPressed: _newScan),
        ],
      ),
      children: [
        Row(
          children: [
            Expanded(child: Text('Skin Analysis', style: AppTextStyles.h1)),
            if (result.isDemo) const DemoBadge(label: 'Demo result'),
          ],
        ),
        const SizedBox(height: 4),
        Text(
            '${session.type?.label ?? 'Scan'} · ${Formatters.dateTime(session.createdAt)}',
            style: AppTextStyles.small),
        const SizedBox(height: AppSpacing.lg),
        if (findings.length > 1) ...[
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: findings.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => PillChip(
                label: findings[i].regionLabel,
                selected: i == _findingIndex,
                onTap: () => setState(() => _findingIndex = i),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        AspectRatio(
          aspectRatio: 1.15,
          child: image == null
              ? Container(
                  decoration: BoxDecoration(
                    color: AppColors.skin,
                    borderRadius: BorderRadius.circular(AppRadius.lg),
                  ),
                )
              : ScanImageView(
                  path: image.path,
                  isSample: image.isSample,
                  quarterTurns: image.quarterTurns,
                  overlay: _view == 1 ? const DemoHeatmapOverlay() : null,
                ),
        ),
        const SizedBox(height: AppSpacing.md),
        SegmentedToggle(
          labels: const ['Original', 'Heatmap'],
          selectedIndex: _view,
          onChanged: (i) => setState(() => _view = i),
        ),
        const SizedBox(height: AppSpacing.lg),
        ResultStats(finding: finding),
        const SizedBox(height: AppSpacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Why this result?', style: AppTextStyles.title),
              const SizedBox(height: 8),
              Text(finding.explanation, style: AppTextStyles.body),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const ConsultDermatologistLink(),
      ],
    );
  }
}

/// Concern / Confidence / Region boxes + confidence bar.
class ResultStats extends StatelessWidget {
  const ResultStats({super.key, required this.finding});

  final ConcernFinding finding;

  @override
  Widget build(BuildContext context) {
    Widget box(String label, String value, {bool serif = false}) => AppCard(
          padding: const EdgeInsets.all(AppSpacing.md + 2),
          child: SizedBox(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(label, style: AppTextStyles.small),
                ),
                const SizedBox(height: 6),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(value,
                      style: serif
                          ? AppTextStyles.h2.copyWith(fontSize: 24)
                          : AppTextStyles.title.copyWith(fontSize: 18)),
                ),
              ],
            ),
          ),
        );

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                  flex: 5,
                  child: box('Concern\ndetected', finding.concern, serif: true)),
              const SizedBox(width: 10),
              Expanded(
                  flex: 4,
                  child: box('Confidence\n', '${finding.confidencePercent}%',
                      serif: true)),
              const SizedBox(width: 10),
              Expanded(
                  flex: 5, child: box('Region\n', finding.regionLabel)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: LinearProgressIndicator(
            value: finding.confidence,
            minHeight: 8,
            color: AppColors.primary,
            backgroundColor: AppColors.surfaceMuted,
          ),
        ),
      ],
    );
  }
}

/// "Want a professional opinion? Consult a dermatologist" link.
class ConsultDermatologistLink extends StatelessWidget {
  const ConsultDermatologistLink({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, AppRoutes.lifestyle),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Text(
          'Want a professional opinion? Consult a dermatologist',
          style: AppTextStyles.label.copyWith(
              color: AppColors.primary, decoration: TextDecoration.underline),
        ),
      ),
    );
  }
}
