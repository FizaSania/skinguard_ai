import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/layout.dart';
import '../../core/widgets/scan_image_view.dart';
import '../../models/skin_scan.dart';
import '../../providers/scan_provider.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// Side-by-side comparison of two scans chosen by the user.
///
/// This is a visual comparison only – no change is measured.
// FUTURE ML INTEGRATION: a backend endpoint could align both images and
// return a measured change score per concern.
class CompareScansScreen extends StatefulWidget {
  const CompareScansScreen({super.key});

  @override
  State<CompareScansScreen> createState() => _CompareScansScreenState();
}

class _CompareScansScreenState extends State<CompareScansScreen> {
  String? _beforeId;
  String? _afterId;

  @override
  Widget build(BuildContext context) {
    final scans = context.watch<ScanProvider>();
    final history = scans.history.where((s) => s.result != null).toList();

    if (history.length < 2) {
      return PageLayout(children: [
        const PageHeading('Compare scans'),
        EmptyState(
          icon: Icons.compare_outlined,
          title: 'Not enough scans',
          message: 'You need at least two completed scans to compare.',
          actionLabel: 'Start Skin Analysis',
          onAction: () {
            scans.startNewScan();
            Navigator.pushNamed(context, AppRoutes.scanSelection);
          },
        ),
      ]);
    }

    // History is newest first.
    final before = history.firstWhere((s) => s.id == _beforeId,
        orElse: () => history.last);
    final after = history.firstWhere((s) => s.id == _afterId,
        orElse: () => history.first);

    return PageLayout(
      children: [
        const PageHeading('Compare scans',
            subtitle: 'Pick two scans to view side by side.'),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: _ScanColumn(
                label: 'Before',
                scan: before,
                options: history,
                onChanged: (id) => setState(() => _beforeId = id),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ScanColumn(
                label: 'After',
                scan: after,
                options: history,
                onChanged: (id) => setState(() => _afterId = id),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        const InfoNote(
          text:
              'Visual comparison only. Differences in lighting, angle or camera can change how skin looks – '
              'no automatic change measurement is made in this build.',
        ),
      ],
    );
  }
}

class _ScanColumn extends StatelessWidget {
  const _ScanColumn({
    required this.label,
    required this.scan,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final ScanSession scan;
  final List<ScanSession> options;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final image = scan.images.isEmpty ? null : scan.images.first;
    final primary = scan.result?.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.overline),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: scan.id,
          isExpanded: true,
          decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10)),
          items: [
            for (final s in options)
              DropdownMenuItem(
                value: s.id,
                child: Text(Formatters.date(s.createdAt),
                    overflow: TextOverflow.ellipsis),
              ),
          ],
          onChanged: onChanged,
        ),
        const SizedBox(height: AppSpacing.md),
        AspectRatio(
          aspectRatio: 0.85,
          child: image == null
              ? const SizedBox()
              : ScanImageView(
                  path: image.path,
                  isSample: image.isSample,
                  quarterTurns: image.quarterTurns),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(primary?.concern ?? '—', style: AppTextStyles.h3),
        if (primary != null)
          Text('${primary.confidencePercent}% · ${primary.regionLabel}',
              style: AppTextStyles.small),
        if (scan.result?.isDemo ?? false)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: const DemoBadge(label: 'Demo'),
          ),
      ],
    );
  }
}
