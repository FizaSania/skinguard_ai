import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/layout.dart';
import '../../data/mock/mock_user_data.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import 'widgets/auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      // FUTURE BACKEND INTEGRATION: UserProvider → AuthService.login.
      final user = await context
          .read<UserProvider>()
          .login(_email.text.trim(), _password.text);
      if (!mounted) return;
      // Existing users go straight to the dashboard; others finish onboarding.
      Navigator.pushNamedAndRemoveUntil(
        context,
        user.onboardingComplete
            ? AppRoutes.shell
            : AppRoutes.onboardingProfile,
        (route) => false,
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _useDemoAccount() {
    _email.text = MockUserData.demoEmail;
    _password.text = MockUserData.demoPassword;
    setState(() => _error = null);
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHeader(isLogin: true),
                if (_error != null) AuthErrorBanner(_error!),
                AppTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _email,
                  fieldKey: const Key('login_email'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: Validators.email,
                ),
                const SizedBox(height: AppSpacing.lg + 4),
                AppTextField(
                  label: 'Password',
                  hint: 'Enter your password',
                  controller: _password,
                  fieldKey: const Key('login_password'),
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  validator: (v) => Validators.required(v, 'Password'),
                  onSubmitted: (_) => _submit(),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(
                        context, AppRoutes.forgotPassword,
                        arguments: _email.text.trim()),
                    child: Text('Forgot password?',
                        style: AppTextStyles.label
                            .copyWith(color: AppColors.primary)),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                PrimaryButton(
                    label: 'Log In', isLoading: _loading, onPressed: _submit),
                const GoogleSignInSection(),
                const SizedBox(height: AppSpacing.xl),
                _DemoAccountCard(onUse: _useDemoAccount),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DemoAccountCard extends StatelessWidget {
  const _DemoAccountCard({required this.onUse});

  final VoidCallback onUse;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          const Icon(Icons.science_outlined, color: AppColors.clay),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Demo build: no real authentication. Use the demo account or sign up with any details.',
              style: AppTextStyles.small,
            ),
          ),
          TextButton(onPressed: onUse, child: const Text('Fill demo')),
        ],
      ),
    );
  }
}
