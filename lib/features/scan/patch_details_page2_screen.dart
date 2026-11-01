import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/layout.dart';
import '../../core/widgets/selection.dart';
import '../../models/skin_scan.dart';
import '../../providers/scan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import 'widgets/scan_progress.dart';

/// Patch details – page 2 of 2 (triggers and timing).
class PatchDetailsPage2Screen extends StatefulWidget {
  const PatchDetailsPage2Screen({super.key});

  @override
  State<PatchDetailsPage2Screen> createState() =>
      _PatchDetailsPage2ScreenState();
}

class _PatchDetailsPage2ScreenState extends State<PatchDetailsPage2Screen> {
  bool _submitted = false;

  void _next() {
    final a = context.read<ScanProvider>().current.patchAnswers;
    setState(() => _submitted = true);
    if (!a.isPage2Complete) {
      showSnack(context, 'Please tell us whether a product was involved.');
      return;
    }
    Navigator.pushNamed(context, AppRoutes.camera);
  }

  @override
  Widget build(BuildContext context) {
    final scans = context.watch<ScanProvider>();
    final a = scans.current.patchAnswers;
    const gap = SizedBox(height: AppSpacing.xl + 4);

    return PageLayout(
      bottom: PrimaryButton(label: 'Next', onPressed: _next),
      children: [
        const ScanStepProgress(step: 3, type: ScanType.patch),
        const PageHeading('Patch details',
            subtitle: 'Page 2 of 2 · Triggers and timing.'),
        const SectionTitle(
            'Did this patch appear after using a specific product?'),
        // FUTURE BACKEND INTEGRATION: turn this into a search against the
        // product catalogue API with suggestions.
        AppTextField(
          label: 'Search product',
          labelSuffix: '(optional)',
          hint: 'e.g. face wash',
          initialValue: a.productName,
          maxLength: 80,
          textInputAction: TextInputAction.done,
          onChanged: (v) => a.productName = v,
        ),
        const SizedBox(height: AppSpacing.md),
        ChoiceGrid<SuspectedProduct>(
          options: SuspectedProduct.values,
          labelOf: (p) => p.label,
          isSelected: (p) => a.suspectedProduct == p,
          onTap: (p) {
            a.suspectedProduct = p;
            scans.answersChanged();
          },
        ),
        if (_submitted && a.suspectedProduct == null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('Choose an option (or "No product").',
                style: AppTextStyles.small.copyWith(color: AppColors.danger)),
          ),
        gap,
        const SectionTitle('Does it get worse at certain times?',
            subtitle: 'Select all that apply (optional).'),
        ChoiceGrid<WorseTime>(
          options: WorseTime.values,
          labelOf: (w) => w.label,
          multiSelect: true,
          isSelected: a.worseTimes.contains,
          onTap: (w) {
            a.worseTimes.contains(w)
                ? a.worseTimes.remove(w)
                : a.worseTimes.add(w);
            scans.answersChanged();
          },
        ),
        gap,
        AppTextField(
          label: 'Final comment',
          labelSuffix: '(optional)',
          hint: 'Anything else about this patch?',
          initialValue: a.finalComment,
          maxLines: 4,
          minLines: 3,
          maxLength: 500,
          onChanged: (v) => a.finalComment = v,
        ),
      ],
    );
  }
}
