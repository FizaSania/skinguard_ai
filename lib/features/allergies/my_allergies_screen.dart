import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/buttons.dart';
import '../../core/widgets/layout.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import 'widgets/allergy_selector.dart';

/// "My Allergies" from the dashboard – review and edit allergy information.
class MyAllergiesScreen extends StatefulWidget {
  const MyAllergiesScreen({super.key});

  @override
  State<MyAllergiesScreen> createState() => _MyAllergiesScreenState();
}

class _MyAllergiesScreenState extends State<MyAllergiesScreen> {
  bool _saving = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    // FUTURE DATABASE INTEGRATION: persists allergies via ProfileService.
    await context.read<UserProvider>().saveProfile();
    if (!mounted) return;
    showSnack(context, 'Allergies saved');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      bottom: PrimaryButton(
          label: 'Save allergies', isLoading: _saving, onPressed: _save),
      children: const [
        PageHeading('My allergies',
            subtitle:
                'We use these to filter ingredients out of your recommendations.'),
        AllergySelector(),
        SizedBox(height: AppSpacing.xl),
        InfoNote(
          icon: Icons.health_and_safety_outlined,
          color: AppColors.blush,
          foreground: AppColors.clay,
          text:
              'Filtering is based on ingredient names only and cannot guarantee a product is safe for you. Always check the label and consult a professional if unsure.',
        ),
      ],
    );
  }
}
