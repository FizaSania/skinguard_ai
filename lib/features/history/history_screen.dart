import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/layout.dart';
import '../../core/widgets/scan_image_view.dart';
import '../../models/skin_scan.dart';
import '../../providers/scan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// Past scans (bottom-nav "History" tab).
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.onStartAnalysis});

  final VoidCallback onStartAnalysis;

  @override
  Widget build(BuildContext context) {
    final scans = context.watch<ScanProvider>();
    final history = scans.history;

    return Scaffold(
      appBar: const SgAppBar(showBack: false),
      body: SafeArea(
        top: false,
        child: !scans.historyLoaded
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, 8, AppSpacing.page, AppSpacing.xl),
                children: [
                  const PageHeading('Scan history',
                      subtitle: 'Your previous skin analyses.'),
                  if (history.isEmpty)
                    EmptyState(
                      icon: Icons.history_rounded,
                      title: 'No scans yet',
                      message:
                          'Your completed skin analyses will appear here.',
                      actionLabel: 'Start Skin Analysis',
                      onAction: onStartAnalysis,
                    )
                  else
                    for (final scan in history)
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: _HistoryTile(scan: scan),
                      ),
                ],
              ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.scan});

  final ScanSession scan;

  @override
  Widget build(BuildContext context) {
    final primary = scan.result?.primary;
    final image = scan.images.isEmpty ? null : scan.images.first;

    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.results, arguments: scan.id),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            height: 72,
            child: image == null
                ? Container(
                    decoration: BoxDecoration(
                      color: AppColors.skin,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(Icons.image_outlined,
                        color: AppColors.skinBorder),
                  )
                : ScanImageView(
                    path: image.path,
                    isSample: image.isSample,
                    quarterTurns: image.quarterTurns,
                    radius: AppRadius.md,
                    showSampleLabel: false,
                  ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(primary?.concern ?? 'No result',
                          style: AppTextStyles.h3),
                    ),
                    if (scan.result?.isDemo ?? false)
                      const DemoBadge(label: 'Demo'),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${scan.type?.label ?? 'Scan'} · ${scan.regionSummary}',
                    style: AppTextStyles.small,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(
                  [
                    Formatters.date(scan.createdAt),
                    if (primary != null) '${primary.confidencePercent}% confidence',
                  ].join(' · '),
                  style: AppTextStyles.small,
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }
}
