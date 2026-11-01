import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/layout.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

class LifestyleScreen extends StatelessWidget {
  const LifestyleScreen({super.key});

  static const _tips = [
    (Icons.bedtime_outlined, 'Sleep',
        'Aim for 7–9 hours a night and wash your pillowcase weekly.'),
    (Icons.water_drop_outlined, 'Hydration',
        'Drink water through the day, not only when you feel thirsty.'),
    (Icons.eco_outlined, 'Food',
        'Favour whole foods, and keep a note of anything that seems to trigger breakouts.'),
    (Icons.waves_outlined, 'Stress',
        'Take short walks, stretch, or pause for a few slow breaths each day.'),
    (Icons.wb_sunny_outlined, 'Sun and touch',
        'Wear sunscreen every day and avoid picking or squeezing blemishes.'),
  ];

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      bottom: PrimaryButton(
        label: 'Next: My Plan',
        onPressed: () => Navigator.pushNamed(context, AppRoutes.planner),
      ),
      children: [
        const PageHeading('Lifestyle & holistic guide',
            subtitle:
                'Everyday habits that can support your skin. This is general wellness guidance, not medical advice.'),
        for (final (icon, title, text) in _tips)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md + 2),
            child: AppCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: AppColors.primarySoft,
                    child: Icon(icon, color: AppColors.primary),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppTextStyles.title),
                        const SizedBox(height: 4),
                        Text(text, style: AppTextStyles.body),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        AppCard(
          color: AppColors.blush,
          borderColor: AppColors.blushBorder,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Consult a Dermatologist', style: AppTextStyles.h3),
              const SizedBox(height: 8),
              Text(
                'For concerns requiring professional evaluation, you can consult a dermatologist.',
                style: AppTextStyles.body,
              ),
              const SizedBox(height: AppSpacing.lg),
              PrimaryButton(
                label: 'Find / Book Dermatologist',
                color: AppColors.brown,
                height: 50,
                // FUTURE BACKEND INTEGRATION: open a verified dermatologist
                // directory / booking provider. No listings are invented here.
                onPressed: () => showPlaceholderDialog(
                  context,
                  title: 'Find a dermatologist',
                  message:
                      'Dermatologist search and booking are not connected in this demo build. '
                      'Please contact a licensed dermatologist or your local clinic directly.',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
