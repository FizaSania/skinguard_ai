import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/layout.dart';
import '../../providers/user_provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import 'widgets/auth_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      // FUTURE BACKEND INTEGRATION: creates the account via AuthService.
      await context.read<UserProvider>().register(
            fullName: _name.text,
            email: _email.text,
            phone: _phone.text,
            password: _password.text,
          );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
          context, AppRoutes.onboardingProfile, (route) => false);
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const gap = SizedBox(height: AppSpacing.lg + 4);
    return PageLayout(
      children: [
        Form(
          key: _formKey,
          child: AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthHeader(isLogin: false),
                if (_error != null) AuthErrorBanner(_error!),
                AppTextField(
                  label: 'Full name',
                  hint: 'Your name',
                  controller: _name,
                  fieldKey: const Key('signup_name'),
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  validator: Validators.fullName,
                ),
                gap,
                AppTextField(
                  label: 'Email',
                  hint: 'you@example.com',
                  controller: _email,
                  fieldKey: const Key('signup_email'),
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.email],
                  validator: Validators.email,
                ),
                gap,
                AppTextField(
                  label: 'Phone',
                  hint: 'Phone number',
                  controller: _phone,
                  fieldKey: const Key('signup_phone'),
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.telephoneNumber],
                  validator: Validators.phone,
                ),
                gap,
                AppTextField(
                  label: 'Password',
                  hint: 'Create a password',
                  controller: _password,
                  fieldKey: const Key('signup_password'),
                  isPassword: true,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  validator: Validators.password,
                  onSubmitted: (_) => _submit(),
                ),
                const SizedBox(height: AppSpacing.xl),
                PrimaryButton(
                    label: 'Create Account',
                    isLoading: _loading,
                    onPressed: _submit),
                const GoogleSignInSection(),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
