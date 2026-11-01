import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/layout.dart';
import '../../../core/widgets/selection.dart';
import '../../../providers/user_provider.dart';
import '../../../services/auth_service.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';
import '../../../theme/app_theme.dart';

/// "Welcome" heading + Log In / Sign Up switcher shared by both screens.
class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.isLogin});

  final bool isLogin;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Welcome', style: AppTextStyles.display),
        const SizedBox(height: 8),
        Text('Log in or create an account to start your skin analysis.',
            style: AppTextStyles.bodySecondary.copyWith(fontSize: 16)),
        const SizedBox(height: AppSpacing.xl),
        SegmentedToggle(
          labels: const ['Log In', 'Sign Up'],
          selectedIndex: isLogin ? 0 : 1,
          onChanged: (i) {
            if ((i == 0) == isLogin) return;
            Navigator.pushReplacementNamed(
                context, i == 0 ? AppRoutes.login : AppRoutes.signup);
          },
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

/// "or" divider followed by the Google button (UI placeholder).
class GoogleSignInSection extends StatelessWidget {
  const GoogleSignInSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('or', style: AppTextStyles.bodySecondary),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        SecondaryButton(
          label: 'Continue with Google',
          icon: Icons.g_mobiledata_rounded,
          onPressed: () async {
            try {
              await context.read<UserProvider>().signInWithGoogle();
            } on AuthException catch (e) {
              if (!context.mounted) return;
              showPlaceholderDialog(context,
                  title: 'Google sign-in',
                  message:
                      '${e.message}\n\nPlease log in with email, or use the demo account.');
            }
          },
        ),
      ],
    );
  }
}

/// Inline error banner for auth failures.
class AuthErrorBanner extends StatelessWidget {
  const AuthErrorBanner(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: InfoNote(
        text: message,
        icon: Icons.error_outline,
        color: AppColors.dangerSoft,
        foreground: AppColors.danger,
      ),
    );
  }
}
