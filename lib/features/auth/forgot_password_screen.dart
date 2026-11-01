import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/buttons.dart';
import '../../core/widgets/form_fields.dart';
import '../../core/widgets/layout.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';

/// Mock password reset. No email is actually sent.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key, this.initialEmail});

  final String? initialEmail;

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _email = TextEditingController(text: widget.initialEmail);
  bool _loading = false;
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    // FUTURE BACKEND INTEGRATION: triggers the real reset-email endpoint.
    await context.read<UserProvider>().sendPasswordReset(_email.text.trim());
    if (!mounted) return;
    setState(() {
      _loading = false;
      _sent = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PageLayout(
      bottom: _sent
          ? PrimaryButton(
              label: 'Back to Log In', onPressed: () => Navigator.pop(context))
          : PrimaryButton(
              label: 'Send reset link',
              isLoading: _loading,
              onPressed: _submit),
      children: [
        const PageHeading('Reset password',
            subtitle:
                'Enter the email you signed up with and we will send you a link to reset your password.'),
        if (_sent)
          const InfoNote(
            icon: Icons.mark_email_read_outlined,
            text:
                'If an account exists for this email, a reset link has been sent. '
                '(Demo build: no email is actually sent.)',
          )
        else
          Form(
            key: _formKey,
            child: AppTextField(
              label: 'Email',
              hint: 'you@example.com',
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              validator: Validators.email,
              onSubmitted: (_) => _submit(),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
        if (!_sent)
          const InfoNote(
            icon: Icons.science_outlined,
            color: AppColors.blush,
            foreground: AppColors.clay,
            text: 'Password reset is simulated in this demo build.',
          ),
      ],
    );
  }
}
