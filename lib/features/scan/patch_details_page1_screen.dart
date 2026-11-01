import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/illustrations.dart';
import '../../core/widgets/layout.dart';
import '../../core/widgets/selection.dart';
import '../../models/skin_scan.dart';
import '../../providers/scan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import 'widgets/scan_progress.dart';

/// Patch details – page 1 of 2 (description, symptoms, duration, treatments).
class PatchDetailsPage1Screen extends StatefulWidget {
  const PatchDetailsPage1Screen({super.key});

  @override
  State<PatchDetailsPage1Screen> createState() =>
      _PatchDetailsPage1ScreenState();
}

class _PatchDetailsPage1ScreenState extends State<PatchDetailsPage1Screen> {
  bool _submitted = false;

  void _next() {
    final a = context.read<ScanProvider>().current.patchAnswers;
    setState(() => _submitted = true);
    if (!a.isPage1Complete) {
      showSnack(context, 'Please answer the highlighted questions.');
      return;
    }
    Navigator.pushNamed(context, AppRoutes.patchDetails2);
  }

  @override
  Widget build(BuildContext context) {
    final scans = context.watch<ScanProvider>();
    final session = scans.current;
    final a = session.patchAnswers;
    const gap = SizedBox(height: AppSpacing.xl + 4);

    Widget error(bool show, String text) => show && _submitted
        ? Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(text,
                style: AppTextStyles.small.copyWith(color: AppColors.danger)),
          )
        : const SizedBox.shrink();

    return PageLayout(
      bottom: PrimaryButton(label: 'Next', onPressed: _next),
      children: [
        const ScanStepProgress(step: 2, type: ScanType.patch),
        const PageHeading('Patch details',
            subtitle: 'Page 1 of 2 · Tell us about the patch you want to scan.'),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final r in session.orderedRegions)
              TagChip(label: r.label, icon: Icons.place_outlined),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        AppTextField(
          label: 'Describe the patch',
          labelSuffix: '(optional)',
          hint: 'Size, colour, texture, where exactly it is',
          initialValue: a.description,
          maxLines: 4,
          minLines: 3,
          maxLength: 500,
          onChanged: (v) => a.description = v,
        ),
        gap,
        const SectionTitle('Guide for lighting and focus'),
        AppCard(
          child: Row(
            children: [
              const LightingGuideIllustration(),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final tip in const [
                      'Use soft, even light, such as facing a window.',
                      'Hold the camera 20–30 cm from the patch.',
                      'Remove makeup and turn off beauty filters.',
                    ])
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Text('•  $tip', style: AppTextStyles.small
                            .copyWith(color: AppColors.textPrimary)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        gap,
        const SectionTitle('Symptoms', subtitle: 'Select all that apply.'),
        ChoiceGrid<PatchSymptom>(
          options: PatchSymptom.values,
          labelOf: (s) => s.label,
          multiSelect: true,
          isSelected: a.symptoms.contains,
          onTap: (s) {
            a.symptoms.contains(s) ? a.symptoms.remove(s) : a.symptoms.add(s);
            scans.answersChanged();
          },
        ),
        error(a.symptoms.isEmpty, 'Select at least one symptom.'),
        gap,
        const SectionTitle('How long have you had it?'),
        ChoiceGrid<PatchDuration>(
          options: PatchDuration.values,
          labelOf: (d) => d.label,
          isSelected: (d) => a.duration == d,
          onTap: (d) {
            a.duration = d;
            scans.answersChanged();
          },
        ),
        error(a.duration == null, 'Choose how long you have had it.'),
        gap,
        const SectionTitle('Previous treatments for this patch',
            subtitle: 'Select all that apply.'),
        ChoiceGrid<PreviousTreatment>(
          options: PreviousTreatment.values,
          labelOf: (t) => t.label,
          multiSelect: true,
          isSelected: a.treatments.contains,
          onTap: (t) {
            // "None" is exclusive with the other options.
            if (t == PreviousTreatment.none) {
              final wasSelected = a.treatments.contains(t);
              a.treatments.clear();
              if (!wasSelected) a.treatments.add(t);
            } else {
              a.treatments.remove(PreviousTreatment.none);
              a.treatments.contains(t)
                  ? a.treatments.remove(t)
                  : a.treatments.add(t);
            }
            scans.answersChanged();
          },
        ),
      ],
    );
  }
}
