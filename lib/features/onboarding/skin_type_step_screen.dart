import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/layout.dart';
import '../../core/widgets/selection.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// Onboarding step 2 of 3 – skin type, oiliness and daily habits.
class SkinTypeStepScreen extends StatefulWidget {
  const SkinTypeStepScreen({super.key, required this.args});

  final OnboardingArgs args;

  @override
  State<SkinTypeStepScreen> createState() => _SkinTypeStepScreenState();
}

class _SkinTypeStepScreenState extends State<SkinTypeStepScreen> {
  bool _showError = false;

  void _next() {
    if (context.read<UserProvider>().profile.skinType == null) {
      setState(() => _showError = true);
      return;
    }
    Navigator.pushNamed(context, AppRoutes.onboardingAllergies,
        arguments: widget.args);
  }

  @override
  Widget build(BuildContext context) {
    final users = context.watch<UserProvider>();
    final profile = users.profile;

    return PageLayout(
      bottom: PrimaryButton(label: 'Next', onPressed: _next),
      children: [
        const StepProgress(step: 2, total: 3, caption: 'Profile setup'),
        const PageHeading('Skin type & habits'),
        const SectionTitle('What is your skin type?'),
        ChoiceGrid<SkinType>(
          options: SkinType.values,
          labelOf: (t) => t.label,
          isSelected: (t) => profile.skinType == t,
          onTap: (t) {
            users.setSkinType(t);
            setState(() => _showError = false);
          },
        ),
        if (_showError)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text('Please choose your skin type (or "Not sure").',
                style: AppTextStyles.small.copyWith(color: AppColors.danger)),
          ),
        const SizedBox(height: AppSpacing.xl + 4),
        SectionTitle(
          'How oily does your skin usually feel?',
          trailing: Text('${profile.oilinessLevel}',
              style: AppTextStyles.h3.copyWith(color: AppColors.primary)),
        ),
        Slider(
          value: profile.oilinessLevel.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          label: '${profile.oilinessLevel}',
          onChanged: (v) => users.setOiliness(v.round()),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('1 · Not oily', style: AppTextStyles.small),
              Text('5 · Very oily', style: AppTextStyles.small),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl + 4),
        const SectionTitle('Daily habits',
            subtitle: 'Select any that apply (optional).'),
        for (final habit in DailyHabit.values)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: ChoiceTile(
              label: habit.label,
              multiSelect: true,
              selected: profile.habits.contains(habit),
              onTap: () => users.toggleHabit(habit),
            ),
          ),
      ],
    );
  }
}
