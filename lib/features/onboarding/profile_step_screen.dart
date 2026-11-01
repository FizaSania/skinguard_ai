import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/layout.dart';
import '../../models/user_profile.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// Onboarding step 1 of 3 – age, gender, location.
class ProfileStepScreen extends StatefulWidget {
  const ProfileStepScreen({super.key, required this.args});

  final OnboardingArgs args;

  @override
  State<ProfileStepScreen> createState() => _ProfileStepScreenState();
}

class _ProfileStepScreenState extends State<ProfileStepScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _location;

  @override
  void initState() {
    super.initState();
    _location = TextEditingController(
        text: context.read<UserProvider>().profile.location);
  }

  @override
  void dispose() {
    _location.dispose();
    super.dispose();
  }

  void _next() {
    if (!_formKey.currentState!.validate()) return;
    context.read<UserProvider>().updateBasics(location: _location.text.trim());
    Navigator.pushNamed(context, AppRoutes.onboardingSkin,
        arguments: widget.args);
  }

  @override
  Widget build(BuildContext context) {
    final users = context.watch<UserProvider>();
    final profile = users.profile;

    return PageLayout(
      bottom: PrimaryButton(label: 'Next', onPressed: _next),
      children: [
        const StepProgress(step: 1, total: 3, caption: 'Profile setup'),
        const PageHeading('Help us profile you',
            subtitle: 'A few basics help us tailor your results.'),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Expanded(child: FieldLabel('Age')),
                  Text('${profile.age}',
                      style: AppTextStyles.h2.copyWith(
                          color: AppColors.primary, fontSize: 28)),
                ],
              ),
              Slider(
                value: profile.age.toDouble(),
                min: 18,
                max: 90,
                divisions: 72,
                label: '${profile.age}',
                onChanged: (v) => users.updateBasics(age: v.round()),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('18', style: AppTextStyles.small),
                    Text('90', style: AppTextStyles.small),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const FieldLabel('Gender'),
              const SizedBox(height: AppSpacing.sm),
              DropdownButtonFormField<Gender>(
                initialValue: profile.gender,
                hint: const Text('Select gender'),
                borderRadius: BorderRadius.circular(AppRadius.md),
                dropdownColor: AppColors.surface,
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
                style: AppTextStyles.body,
                items: [
                  for (final g in Gender.values)
                    DropdownMenuItem(value: g, child: Text(g.label)),
                ],
                validator: (v) => v == null ? 'Please select an option' : null,
                onChanged: (g) => users.updateBasics(gender: g),
              ),
              const SizedBox(height: AppSpacing.xl),
              AppTextField(
                label: 'Location',
                labelSuffix: '(optional)',
                hint: 'City or country',
                controller: _location,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Used only to account for environmental factors such as climate and UV exposure.',
                style: AppTextStyles.small,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
