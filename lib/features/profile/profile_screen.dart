import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/layout.dart';
import '../../core/widgets/selection.dart';
import '../../providers/plan_provider.dart';
import '../../providers/scan_provider.dart';
import '../../providers/user_provider.dart';
import '../../services/analysis_service.dart';
import '../../services/app_services.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// Profile tab: account info, skin profile, allergies, settings, logout.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Local-only setting.
  // FUTURE BACKEND INTEGRATION: store notification preference server-side
  // and register for push notifications (e.g. Firebase Cloud Messaging).
  bool _reminders = true;

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text(
            'Your demo data is kept in memory only and will be cleared.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Log out')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final scans = context.read<ScanProvider>();
    final plan = context.read<PlanProvider>();
    await context.read<UserProvider>().logout();
    scans.clearAll();
    plan.clear();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
        context, AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserProvider>().user;
    if (user == null) return const SizedBox.shrink();
    final analysis = context.read<AppServices>().analysis;

    final initials = user.fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .map((p) => p[0].toUpperCase())
        .join();

    return Scaffold(
      appBar: const SgAppBar(showBack: false),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, 8, AppSpacing.page, AppSpacing.xl),
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.primarySoft,
                  child: Text(initials.isEmpty ? '?' : initials,
                      style: AppTextStyles.h2
                          .copyWith(color: AppColors.primary)),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName, style: AppTextStyles.h2),
                      Text(user.email, style: AppTextStyles.bodySecondary),
                      if (user.phone.isNotEmpty)
                        Text(user.phone, style: AppTextStyles.small),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xl),
            _SectionCard(
              title: 'Skin profile',
              actionLabel: 'Edit',
              onAction: () => Navigator.pushNamed(
                  context, AppRoutes.onboardingProfile,
                  arguments: const OnboardingArgs(editing: true)),
              children: [
                _InfoRow('Age', '${user.age}'),
                _InfoRow('Gender', user.gender?.label ?? 'Not set'),
                _InfoRow('Location',
                    user.location.isEmpty ? 'Not set' : user.location),
                _InfoRow('Skin type', user.skinType?.label ?? 'Not set'),
                _InfoRow('Oiliness', '${user.oilinessLevel} / 5'),
                _InfoRow(
                    'Habits',
                    user.habits.isEmpty
                        ? 'None selected'
                        : user.habits.map((h) => h.label).join(', ')),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            _SectionCard(
              title: 'Allergies',
              actionLabel: 'Manage',
              onAction: () =>
                  Navigator.pushNamed(context, AppRoutes.myAllergies),
              children: [
                if (user.allergies.isEmpty)
                  Text('No known allergies', style: AppTextStyles.bodySecondary)
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final a in user.allergies) TagChip.negative(label: a),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('Routine reminders', style: AppTextStyles.body),
                    subtitle: Text('Local setting – not yet connected',
                        style: AppTextStyles.small),
                    value: _reminders,
                    onChanged: (v) => setState(() => _reminders = v),
                  ),
                  if (analysis is MockSkinAnalysisService) ...[
                    const Divider(height: 1),
                    SwitchListTile(
                      title: Text('Demo: simulate analysis failure',
                          style: AppTextStyles.body),
                      subtitle: Text(
                          'Preview the error / retry state on the analyzing screen',
                          style: AppTextStyles.small),
                      value: analysis.simulateFailure,
                      onChanged: (v) =>
                          setState(() => analysis.simulateFailure = v),
                    ),
                  ],
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline),
                    title: Text('About & disclaimer', style: AppTextStyles.body),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => showAboutDialog(
                      context: context,
                      applicationName: 'SkinGuard AI',
                      applicationVersion: '1.0.0 (static frontend demo)',
                      applicationIcon: const ShieldLogo(size: 36),
                      children: [
                        Text(
                          'SkinGuard AI provides general skincare information and is not a '
                          'medical device. Results in this build are demonstration data only. '
                          'Consult a dermatologist for any medical concern.',
                          style: AppTextStyles.bodySecondary,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                        const Icon(Icons.logout_rounded, color: AppColors.danger),
                    title: Text('Log out',
                        style: AppTextStyles.body
                            .copyWith(color: AppColors.danger)),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.children,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final List<Widget> children;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(title, style: AppTextStyles.h3)),
              if (actionLabel != null)
                TextButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
              width: 96, child: Text(label, style: AppTextStyles.bodySecondary)),
          Expanded(child: Text(value, style: AppTextStyles.body)),
        ],
      ),
    );
  }
}
