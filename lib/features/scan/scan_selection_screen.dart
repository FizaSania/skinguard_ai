import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/layout.dart';
import '../../core/widgets/selection.dart';
import '../../models/skin_scan.dart';
import '../../providers/scan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import 'widgets/face_region_selector.dart';
import 'widgets/scan_progress.dart';

/// Region + analysis-mode selection ("Select patch area" + crucial question).
class ScanSelectionScreen extends StatefulWidget {
  const ScanSelectionScreen({super.key});

  @override
  State<ScanSelectionScreen> createState() => _ScanSelectionScreenState();
}

class _ScanSelectionScreenState extends State<ScanSelectionScreen> {
  String? _error;

  void _next() {
    final session = context.read<ScanProvider>().current;
    if (session.type == null) {
      setState(() => _error =
          'Choose Full Face or Detailed Patch to continue.');
      return;
    }
    if (session.type == ScanType.patch && session.regions.isEmpty) {
      setState(() => _error =
          'Select at least one face region for a patch assessment.');
      return;
    }
    setState(() => _error = null);
    Navigator.pushNamed(
      context,
      session.type == ScanType.fullFace
          ? AppRoutes.fullFaceQuestionnaire
          : AppRoutes.patchDetails1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scans = context.watch<ScanProvider>();
    final session = scans.current;
    final isFullFace = session.type == ScanType.fullFace;

    return PageLayout(
      bottom: PrimaryButton(label: 'Next', onPressed: _next),
      children: [
        ScanStepProgress(step: 1, type: session.type),
        const PageHeading('Select patch area',
            subtitle: 'Choose the part of your face you want to scan.'),
        FaceRegionSelector(
          selected: session.regions,
          enabled: !isFullFace,
          onToggle: (r) {
            scans.toggleRegion(r);
            setState(() => _error = null);
          },
        ),
        const SizedBox(height: AppSpacing.xl),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final region in FaceRegion.values)
              PillChip(
                label: region.label,
                selected: session.regions.contains(region),
                onTap: isFullFace
                    ? null
                    : () {
                        scans.toggleRegion(region);
                        setState(() => _error = null);
                      },
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: Text(
                isFullFace
                    ? 'Region selection is not needed for a full face analysis.'
                    : session.regions.isEmpty
                        ? 'No regions selected'
                        : 'Selected: ${session.regionSummary}',
                style: AppTextStyles.small,
              ),
            ),
            if (session.regions.isNotEmpty && !isFullFace)
              TextButton.icon(
                onPressed: scans.clearRegions,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reset'),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _CrucialQuestion(
          selected: session.type,
          onSelect: (type) {
            scans.setType(type);
            setState(() => _error = null);
          },
        ),
        if (_error != null) ...[
          const SizedBox(height: AppSpacing.md),
          InfoNote(
            text: _error!,
            icon: Icons.error_outline,
            color: AppColors.dangerSoft,
            foreground: AppColors.danger,
          ),
        ],
      ],
    );
  }
}

class _CrucialQuestion extends StatelessWidget {
  const _CrucialQuestion({required this.selected, required this.onSelect});

  final ScanType? selected;
  final ValueChanged<ScanType> onSelect;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.blush,
      borderColor: AppColors.blushBorder,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('CRUCIAL QUESTION',
              style: AppTextStyles.overline.copyWith(color: AppColors.clay)),
          const SizedBox(height: 6),
          Text(
            'For accurate analysis, are you here for a Full Face Analysis or a Patch Region Assessment?',
            style: AppTextStyles.title.copyWith(height: 1.35),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _ModeCard(
                  icon: Icons.sentiment_satisfied_alt_outlined,
                  label: 'Full Face',
                  selected: selected == ScanType.fullFace,
                  onTap: () => onSelect(ScanType.fullFace),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _ModeCard(
                  icon: Icons.center_focus_strong_outlined,
                  label: 'Detailed Patch',
                  selected: selected == ScanType.patch,
                  onTap: () => onSelect(ScanType.patch),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? Colors.white : AppColors.blushLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: selected ? AppColors.primary : AppColors.blushBorder,
            width: selected ? 2 : 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
            child: Column(
              children: [
                Icon(icon, color: AppColors.primary, size: 30),
                const SizedBox(height: 10),
                Text(label,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.label.copyWith(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
