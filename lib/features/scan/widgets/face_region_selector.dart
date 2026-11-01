import 'package:flutter/material.dart';

import '../../../models/skin_scan.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text_styles.dart';

/// Tappable face map. Region positions follow the Figma design and are
/// expressed in a 250 x 360 coordinate space that is scaled to fit.
class FaceRegionSelector extends StatelessWidget {
  const FaceRegionSelector({
    super.key,
    required this.selected,
    required this.onToggle,
    this.enabled = true,
  });

  final Set<FaceRegion> selected;
  final ValueChanged<FaceRegion> onToggle;
  final bool enabled;

  static const _size = Size(250, 360);

  static const Map<FaceRegion, Rect> _areas = {
    FaceRegion.forehead: Rect.fromLTWH(32, 22, 186, 76),
    FaceRegion.leftCheek: Rect.fromLTWH(3, 150, 94, 94),
    FaceRegion.nose: Rect.fromLTWH(103, 136, 44, 98),
    FaceRegion.rightCheek: Rect.fromLTWH(153, 150, 94, 94),
    FaceRegion.lips: Rect.fromLTWH(82, 255, 86, 32),
    FaceRegion.chin: Rect.fromLTWH(76, 305, 98, 44),
  };

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Center(
        child: SizedBox(
          height: 300,
          child: FittedBox(
            child: SizedBox.fromSize(
              size: _size,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.skin,
                        border: Border.all(color: AppColors.skinBorder),
                        borderRadius: const BorderRadius.all(
                            Radius.elliptical(125, 180)),
                      ),
                    ),
                  ),
                  for (final entry in _areas.entries)
                    Positioned.fromRect(
                      rect: entry.value,
                      child: _RegionOval(
                        region: entry.key,
                        selected: selected.contains(entry.key),
                        onTap: enabled ? () => onToggle(entry.key) : null,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RegionOval extends StatelessWidget {
  const _RegionOval({
    required this.region,
    required this.selected,
    required this.onTap,
  });

  final FaceRegion region;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: region.label,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          alignment: Alignment.center,
          decoration: ShapeDecoration(
            color: selected
                ? AppColors.primary
                : const Color(0xFFF7E6D8),
            shape: OvalBorder(
              side: BorderSide(
                color: selected ? AppColors.primary : const Color(0xFF9C8A7C),
                width: 1.2,
              ),
            ),
          ),
          child: FittedBox(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Text(
                region.shortLabel,
                style: AppTextStyles.small.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
