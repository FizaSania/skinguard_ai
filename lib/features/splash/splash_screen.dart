import 'package:flutter/material.dart';

import '../../app/routes.dart';
import '../../core/constants/app_assets.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/buttons.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  static const _background = Color(0xFF4D6B2A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.page),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(AppAssets.logo,
                    height: 70, semanticLabel: 'SkinGuard logo'),
              ),
              Expanded(
                child: Image.asset(
                  AppAssets.splashIllustration,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const ShieldLogo(size: 30, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('SkinGuard AI',
                        style: AppTextStyles.title.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text('Your AI Skin Health Assistant.',
                  style: AppTextStyles.body
                      .copyWith(color: Colors.white.withValues(alpha: 0.85))),
              const SizedBox(height: 6),
              Text(
                'Understand your skin, build a routine, track your progress.',
                textAlign: TextAlign.center,
                style: AppTextStyles.small
                    .copyWith(color: Colors.white.withValues(alpha: 0.7)),
              ),
              const SizedBox(height: AppSpacing.xl + 4),
              PrimaryButton(
                label: 'Get Started',
                color: AppColors.splashButton,
                onPressed: () => Navigator.pushNamed(context, AppRoutes.login),
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
