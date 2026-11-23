import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import 'brand.dart';
import 'layout.dart';

/// Small "Coming Soon" pill used on every feature reserved for FYP-2.
class ComingSoonTag extends StatelessWidget {
  const ComingSoonTag({super.key, this.compact = false});

  /// Tighter version for navigation items and segmented controls.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 5 : 8, vertical: compact ? 1 : 3),
      decoration: BoxDecoration(
        color: AppColors.blush,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.blushBorder),
      ),
      child: Text(
        'Coming Soon',
        maxLines: 1,
        style: AppTextStyles.small.copyWith(
          color: AppColors.clay,
          fontSize: compact ? 9 : 11,
          fontWeight: FontWeight.w700,
          height: 1.3,
        ),
      ),
    );
  }
}

/// Card shown in place of hidden content.
class ComingSoonCard extends StatelessWidget {
  const ComingSoonCard({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTextStyles.title)),
          const SizedBox(width: AppSpacing.sm),
          const ComingSoonTag(),
        ],
      ),
    );
  }
}

/// Fallback page if a hidden route is ever opened directly.
class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SgAppBar(),
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.page),
        child: Center(
          child: EmptyState(
            icon: Icons.hourglass_empty_rounded,
            title: 'Coming Soon',
            message: 'This feature will be available in a future update.',
          ),
        ),
      ),
    );
  }
}

void showComingSoon(BuildContext context, String feature) =>
    showSnack(context, '$feature is coming soon');
