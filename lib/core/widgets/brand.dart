import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Shield-with-leaf mark used in headers.
class ShieldLogo extends StatelessWidget {
  const ShieldLogo({super.key, this.size = 26, this.color = AppColors.primary});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(Icons.shield_outlined, size: size, color: color),
          Padding(
            padding: EdgeInsets.only(bottom: size * 0.06),
            child: Icon(Icons.eco, size: size * 0.4, color: color),
          ),
        ],
      ),
    );
  }
}

/// "🛡 SkinGuard AI" brand row shown at the top of most screens.
class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key, this.color = AppColors.textPrimary});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ShieldLogo(
            size: 24,
            color: color == AppColors.textPrimary ? AppColors.primary : color),
        const SizedBox(width: 10),
        Text('SkinGuard AI',
            style: AppTextStyles.title.copyWith(
                color: color, fontWeight: FontWeight.w700, fontSize: 17)),
      ],
    );
  }
}

/// Standard app bar: back arrow, centred brand, optional actions.
class SgAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SgAppBar({
    super.key,
    this.showBack = true,
    this.leading,
    this.actions,
    this.onBack,
  });

  final bool showBack;
  final Widget? leading;
  final List<Widget>? actions;
  final VoidCallback? onBack;

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    return AppBar(
      toolbarHeight: 60,
      automaticallyImplyLeading: false,
      leading: leading ??
          (showBack && (canPop || onBack != null)
              ? IconButton(
                  tooltip: 'Back',
                  icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                  onPressed: onBack ?? () => Navigator.of(context).maybePop(),
                )
              : null),
      title: const BrandTitle(),
      actions: actions,
    );
  }
}
