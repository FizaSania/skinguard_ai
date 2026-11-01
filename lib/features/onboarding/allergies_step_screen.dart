import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/layout.dart';
import '../../providers/user_provider.dart';
import '../allergies/widgets/allergy_selector.dart';

/// Onboarding step 3 of 3 – known allergies.
class AllergiesStepScreen extends StatefulWidget {
  const AllergiesStepScreen({super.key, required this.args});

  final OnboardingArgs args;

  @override
  State<AllergiesStepScreen> createState() => _AllergiesStepScreenState();
}

class _AllergiesStepScreenState extends State<AllergiesStepScreen> {
  bool _saving = false;

  Future<void> _finish() async {
    setState(() => _saving = true);
    // FUTURE DATABASE INTEGRATION: completeOnboarding() saves the profile
    // through ProfileService.
    await context.read<UserProvider>().completeOnboarding();
    if (!mounted) return;
    if (widget.args.editing) {
      showSnack(context, 'Skin profile updated');
      Navigator.popUntil(
          context, (route) => route.settings.name == AppRoutes.shell);
    } else {
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.shell, (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      bottom: PrimaryButton(
          label: widget.args.editing ? 'Save' : 'Finish',
          isLoading: _saving,
          onPressed: _finish),
      children: const [
        StepProgress(step: 3, total: 3, caption: 'Profile setup'),
        PageHeading('Allergies',
            subtitle:
                'Do you have any known allergies? We will avoid these in your recommendations.'),
        AllergySelector(),
      ],
    );
  }
}
