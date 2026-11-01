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

class FullFaceQuestionnaireScreen extends StatefulWidget {
  const FullFaceQuestionnaireScreen({super.key});

  @override
  State<FullFaceQuestionnaireScreen> createState() =>
      _FullFaceQuestionnaireScreenState();
}

class _FullFaceQuestionnaireScreenState
    extends State<FullFaceQuestionnaireScreen> {
  bool _submitted = false;

  void _next() {
    final answers = context.read<ScanProvider>().current.fullFaceAnswers;
    setState(() => _submitted = true);
    if (!answers.isComplete) {
      showSnack(context, 'Please answer the highlighted questions.');
      return;
    }
    Navigator.pushNamed(context, AppRoutes.camera);
  }

  Widget _error(bool show, String text) => show && _submitted
      ? Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Text(text,
              style: AppTextStyles.small.copyWith(color: AppColors.danger)),
        )
      : const SizedBox.shrink();

  @override
  Widget build(BuildContext context) {
    final scans = context.watch<ScanProvider>();
    final a = scans.current.fullFaceAnswers;
    const gap = SizedBox(height: AppSpacing.xl + 4);

    return PageLayout(
      bottom: PrimaryButton(label: 'Next', onPressed: _next),
      children: [
        const ScanStepProgress(step: 2, type: ScanType.fullFace),
        const PageHeading('Full face details',
            subtitle: 'A few questions about your whole face.',
            leading: FaceAvatar()),
        const SectionTitle('What is your primary skincare goal?'),
        ChoiceGrid<SkincareGoal>(
          options: SkincareGoal.values,
          labelOf: (g) => g.label,
          isSelected: a.goals.contains,
          onTap: (g) {
            a.goals
              ..clear()
              ..add(g);
            scans.answersChanged();
          },
        ),
        _error(a.goals.isEmpty, 'Choose your primary goal.'),
        gap,
        const SectionTitle('Do you experience general sensitivity?'),
        _YesNo(
          value: a.generalSensitivity,
          onChanged: (v) {
            a.generalSensitivity = v;
            scans.answersChanged();
          },
        ),
        _error(a.generalSensitivity == null, 'Please choose Yes or No.'),
        gap,
        const SectionTitle('Do you wear daily sunscreen?'),
        _YesNo(
          value: a.dailySunscreen,
          onChanged: (v) {
            a.dailySunscreen = v;
            scans.answersChanged();
          },
        ),
        _error(a.dailySunscreen == null, 'Please choose Yes or No.'),
        gap,
        const SectionTitle('Rate your satisfaction with your current routine'),
        StarRating(
          value: a.routineSatisfaction,
          onChanged: (v) {
            a.routineSatisfaction = v;
            scans.answersChanged();
          },
        ),
        _error(a.routineSatisfaction == 0, 'Tap a star to rate.'),
        gap,
        AppTextField(
          label: 'Any other overall face concerns?',
          labelSuffix: '(optional)',
          hint: 'Tell us anything else we should know',
          initialValue: a.otherConcerns,
          maxLines: 4,
          minLines: 3,
          maxLength: 500,
          onChanged: (v) => a.otherConcerns = v,
        ),
      ],
    );
  }
}

class _YesNo extends StatelessWidget {
  const _YesNo({required this.value, required this.onChanged});

  final bool? value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return ChoiceGrid<bool>(
      options: const [true, false],
      labelOf: (v) => v ? 'Yes' : 'No',
      isSelected: (v) => value == v,
      onTap: onChanged,
    );
  }
}

/// 1–5 star rating control.
class StarRating extends StatelessWidget {
  const StarRating({super.key, required this.value, required this.onChanged});

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 1; i <= 5; i++)
          IconButton(
            tooltip: '$i star${i > 1 ? 's' : ''}',
            iconSize: 34,
            onPressed: () => onChanged(i),
            icon: Icon(
              i <= value ? Icons.star_rounded : Icons.star_outline_rounded,
              color: i <= value ? AppColors.star : AppColors.skinBorder,
            ),
          ),
      ],
    );
  }
}
