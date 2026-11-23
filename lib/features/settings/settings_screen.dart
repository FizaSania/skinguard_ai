import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/coming_soon.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/layout.dart';
import '../../core/widgets/selection.dart';
import '../../providers/settings_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// App settings, opened from the gear icon on the dashboard.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  static const _themeModes = [
    (ThemeMode.light, 'Light', Icons.light_mode_outlined),
    (ThemeMode.dark, 'Dark', Icons.dark_mode_outlined),
    (ThemeMode.system, 'System', Icons.brightness_auto_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return PageLayout(
      children: [
        const PageHeading('Settings',
            subtitle: 'Choose how SkinGuard AI looks and works for you.'),
        const SectionTitle('Appearance'),
        ChoiceGrid<(ThemeMode, String, IconData)>(
          options: _themeModes,
          labelOf: (m) => m.$2,
          isSelected: (m) => settings.themeMode == m.$1,
          onTap: (m) => settings.setThemeMode(m.$1),
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionTitle('Text size'),
        ChoiceGrid<AppTextSize>(
          options: AppTextSize.values,
          labelOf: (s) => s.label,
          isSelected: (s) => settings.textSize == s,
          onTap: settings.setTextSize,
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionTitle('Preferences'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              _ComingSoonRow(Icons.notifications_none_rounded, 'Notifications'),
              Divider(height: 1),
              _ComingSoonRow(Icons.language_rounded, 'Language'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionTitle('Privacy & security'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: const [
              _ComingSoonRow(Icons.lock_outline_rounded, 'Change password'),
              Divider(height: 1),
              _ComingSoonRow(Icons.privacy_tip_outlined, 'Privacy policy'),
              Divider(height: 1),
              _ComingSoonRow(Icons.delete_outline_rounded, 'Delete my data'),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const SectionTitle('About'),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: Icon(Icons.medical_information_outlined,
                    color: AppColors.primary),
                title: Text('Medical disclaimer', style: AppTextStyles.body),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showDisclaimer(context),
              ),
              const Divider(height: 1),
              ListTile(
                leading:
                    Icon(Icons.description_outlined, color: AppColors.primary),
                title:
                    Text('Open-source licenses', style: AppTextStyles.body),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showLicensePage(
                  context: context,
                  applicationName: 'SkinGuard AI',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Padding(
                    padding: EdgeInsets.all(8),
                    child: ShieldLogo(size: 40),
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.info_outline, color: AppColors.primary),
                title: Text('App version', style: AppTextStyles.body),
                trailing: Text('1.0.0', style: AppTextStyles.bodySecondary),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showDisclaimer(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Medical disclaimer'),
        content: const Text(
            'SkinGuard AI provides general skincare information and is not a '
            'medical device. Results in this build are demonstration data '
            'only. Consult a dermatologist for any medical concern.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK')),
        ],
      ),
    );
  }
}

class _ComingSoonRow extends StatelessWidget {
  const _ComingSoonRow(this.icon, this.title);

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondary),
      title: Text(title, style: AppTextStyles.body),
      trailing: const ComingSoonTag(),
      onTap: () => showComingSoon(context, title),
    );
  }
}
