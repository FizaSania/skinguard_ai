import 'package:flutter/material.dart';

import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// Card-style radio (single) or checkbox (multi) option from the design.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.multiSelect = false,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool multiSelect;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            constraints: const BoxConstraints(minHeight: 54),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: selected ? AppColors.primary : AppColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              children: [
                multiSelect ? _CheckMark(selected) : _RadioMark(selected),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(label,
                      style: AppTextStyles.body.copyWith(fontSize: 16)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RadioMark extends StatelessWidget {
  const _RadioMark(this.selected);
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            width: 1.4),
      ),
      alignment: Alignment.center,
      child: selected
          ? Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: AppColors.primary),
            )
          : null,
    );
  }
}

class _CheckMark extends StatelessWidget {
  const _CheckMark(this.selected);
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: selected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
            color: selected ? AppColors.primary : AppColors.textSecondary,
            width: 1.4),
      ),
      child: selected
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : null,
    );
  }
}

/// Lays out [ChoiceTile]s in a responsive two-column grid (one column on
/// very narrow screens).
class ChoiceGrid<T> extends StatelessWidget {
  const ChoiceGrid({
    super.key,
    required this.options,
    required this.labelOf,
    required this.isSelected,
    required this.onTap,
    this.multiSelect = false,
    this.columns = 2,
  });

  final List<T> options;
  final String Function(T) labelOf;
  final bool Function(T) isSelected;
  final ValueChanged<T> onTap;
  final bool multiSelect;
  final int columns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final cols = constraints.maxWidth < 280 ? 1 : columns;
      const gap = 12.0;
      final width = (constraints.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [
          for (final option in options)
            SizedBox(
              width: width,
              child: ChoiceTile(
                label: labelOf(option),
                selected: isSelected(option),
                multiSelect: multiSelect,
                onTap: () => onTap(option),
              ),
            ),
        ],
      );
    });
  }
}

/// Two-option segmented control (Log In / Sign Up, Original / Heatmap).
class SegmentedToggle extends StatelessWidget {
  const SegmentedToggle({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: i == selectedIndex
                        ? AppColors.surface
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Text(
                    labels[i],
                    style: AppTextStyles.label.copyWith(
                      fontSize: 16,
                      color: i == selectedIndex
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight: i == selectedIndex
                          ? FontWeight.w700
                          : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Pill chip used for region names and selected allergies.
class PillChip extends StatelessWidget {
  const PillChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.onDeleted,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.textPrimary;
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      shape: StadiumBorder(
        side: BorderSide(
            color: selected ? AppColors.primary : AppColors.border),
      ),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.only(
              left: 18, right: onDeleted == null ? 18 : 8, top: 10, bottom: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label,
                  style: AppTextStyles.label.copyWith(fontSize: 15, color: fg)),
              if (onDeleted != null) ...[
                const SizedBox(width: 4),
                InkResponse(
                  onTap: onDeleted,
                  radius: 16,
                  child: Icon(Icons.close, size: 18, color: fg),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Small rounded tag (ingredients to look for / avoid, "Selected" chips).
class TagChip extends StatelessWidget {
  const TagChip({
    super.key,
    required this.label,
    this.icon,
    this.background = AppColors.primarySoft,
    this.foreground = AppColors.textPrimary,
    this.onDeleted,
  });

  const TagChip.positive({super.key, required this.label, this.onDeleted})
      : icon = Icons.check,
        background = AppColors.primarySoft,
        foreground = AppColors.textPrimary;

  const TagChip.negative({super.key, required this.label, this.onDeleted})
      : icon = Icons.close,
        background = AppColors.dangerSoft,
        foreground = AppColors.danger;

  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;
  final VoidCallback? onDeleted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          left: 14, right: onDeleted == null ? 14 : 6, top: 8, bottom: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: foreground),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(label,
                style: AppTextStyles.label
                    .copyWith(color: foreground, fontWeight: FontWeight.w700)),
          ),
          if (onDeleted != null)
            Semantics(
              label: 'Remove $label',
              button: true,
              child: InkResponse(
                onTap: onDeleted,
                radius: 16,
                child: Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Icon(Icons.close, size: 17, color: foreground),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
