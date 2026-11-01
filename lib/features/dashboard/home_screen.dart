import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/layout.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.onSelectTab,
    required this.onStartAnalysis,
  });

  final ValueChanged<int> onSelectTab;
  final VoidCallback onStartAnalysis;

  @override
  Widget build(BuildContext context) {
    final name = context.watch<UserProvider>().user?.firstName ?? '';

    return Scaffold(
      appBar: SgAppBar(
        showBack: false,
        leading: IconButton(
          tooltip: 'Settings',
          icon: const Icon(Icons.settings_outlined),
          onPressed: () => onSelectTab(2),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.page, 8, AppSpacing.page, AppSpacing.xl),
          children: [
            Text('Your personal skincare assistant', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.lg),
            Text(name.isEmpty ? 'Hello! 👋' : 'Hello, $name! 👋',
                style: AppTextStyles.h2.copyWith(color: AppColors.primary)),
            const SizedBox(height: 6),
            Text("Let's take care of your skin today.",
                style: AppTextStyles.bodySecondary.copyWith(fontSize: 16)),
            const SizedBox(height: AppSpacing.xl),
            _AnalyzeCard(onStart: onStartAnalysis),
            const SizedBox(height: AppSpacing.xl + 4),
            Text('Quick Access', style: AppTextStyles.h2),
            const SizedBox(height: AppSpacing.md),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _QuickCard(
                      icon: Icons.health_and_safety_outlined,
                      title: 'My Allergies',
                      subtitle: 'Review your allergy information.',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.myAllergies),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _QuickCard(
                      icon: Icons.insights_outlined,
                      title: 'Latest Results',
                      subtitle: 'View your last skin analysis.',
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.results),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl + 4),
            Text('Explore Skincare', style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.md),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _ExploreRow(
                    title: 'Recommended for You',
                    subtitle: 'Suggestions based on your skin profile.',
                    route: AppRoutes.recommendations,
                  ),
                  const Divider(height: 1),
                  _ExploreRow(
                    title: 'Products & Ingredients',
                    subtitle: 'Explore product and ingredient information.',
                    route: AppRoutes.products,
                  ),
                  const Divider(height: 1),
                  _ExploreRow(
                    title: 'My Plan Tracker',
                    subtitle: 'Keep track of your skincare routine.',
                    route: AppRoutes.planner,
                  ),
                  const Divider(height: 1),
                  _ExploreRow(
                    title: 'Lifestyle Guide',
                    subtitle: 'Discover skincare and lifestyle tips.',
                    route: AppRoutes.lifestyle,
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

class _AnalyzeCard extends StatelessWidget {
  const _AnalyzeCard({required this.onStart});

  final VoidCallback onStart;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: Colors.transparent,
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
                color: AppColors.primarySoft, shape: BoxShape.circle),
            child: const Icon(Icons.face_retouching_natural,
                color: AppColors.primary, size: 32),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Analyze Your Skin', style: AppTextStyles.title),
                const SizedBox(height: 2),
                Text('Take a selfie or upload a photo.',
                    style: AppTextStyles.bodySecondary),
                const SizedBox(height: AppSpacing.md),
                SizedBox(
                  height: 42,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onStart,
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    child: const Text('Start Skin Analysis'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderColor: Colors.transparent,
      radius: AppRadius.xl,
      padding: const EdgeInsets.all(AppSpacing.lg),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(height: AppSpacing.sm),
          Text(title, style: AppTextStyles.title),
          const SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.small),
        ],
      ),
    );
  }
}

class _ExploreRow extends StatelessWidget {
  const _ExploreRow({
    required this.title,
    required this.subtitle,
    required this.route,
  });

  final String title;
  final String subtitle;
  final String route;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      title: Text(title, style: AppTextStyles.title.copyWith(fontSize: 18)),
      subtitle: Text(subtitle, style: AppTextStyles.small),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textPrimary),
      onTap: () => Navigator.pushNamed(context, route),
    );
  }
}
