import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/widgets/buttons.dart';
import '../../core/widgets/layout.dart';
import '../../core/widgets/scan_image_view.dart';
import '../../core/widgets/selection.dart';
import '../../models/skin_scan.dart';
import '../../providers/scan_provider.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';
import 'camera_screen.dart';

/// Review the photo for one capture target (full face or a single region).
/// Pops with a [ReviewOutcome].
class PhotoReviewScreen extends StatelessWidget {
  const PhotoReviewScreen({super.key, required this.region});

  /// Null for full face.
  final FaceRegion? region;

  @override
  Widget build(BuildContext context) {
    final scans = context.watch<ScanProvider>();
    final session = scans.current;
    final image = session.imageFor(region);
    final isPatch = session.type == ScanType.patch;

    final targets = session.captureTargets;
    final remaining = targets.where((t) => session.imageFor(t) == null).length;

    if (image == null) {
      return PageLayout(children: [
        EmptyState(
          icon: Icons.photo_camera_outlined,
          title: 'No photo yet',
          message: 'Go back and take or upload a photo first.',
          actionLabel: 'Back to camera',
          onAction: () => Navigator.pop(context, ReviewOutcome.retake),
        ),
      ]);
    }

    return PageLayout(
      bottom: Row(
        children: [
          Expanded(
            child: SecondaryButton(
              label: 'Retake',
              onPressed: () {
                scans.removeImage(region);
                Navigator.pop(context, ReviewOutcome.retake);
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: PrimaryButton(
              label: remaining == 0 ? 'Continue' : 'Next region',
              onPressed: () =>
                  Navigator.pop(context, ReviewOutcome.continued),
            ),
          ),
        ],
      ),
      children: [
        Text('Review your photo', style: AppTextStyles.h1),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            TagChip(label: 'Region: ${image.targetLabel}'),
            if (isPatch && targets.length > 1)
              TagChip(
                  label:
                      'Photo ${targets.indexOf(region) + 1} of ${targets.length}'),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        AspectRatio(
          aspectRatio: 1,
          child: ScanImageView(
            path: image.path,
            isSample: image.isSample,
            quarterTurns: image.quarterTurns,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: ToolButton(
                label: 'Crop',
                icon: Icons.crop,
                badge: 'Soon',
                // FUTURE IMAGE INTEGRATION: integrate image_cropper here and
                // replace the stored path with the cropped file.
                onPressed: () => showPlaceholderDialog(
                  context,
                  title: 'Crop',
                  message:
                      'Cropping is not available in this demo build yet. The photo will be used as it is.',
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: ToolButton(
                label: 'Rotate',
                icon: Icons.rotate_right,
                onPressed: () => scans.rotateImage(region),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        Text('Is this photo clear?', style: AppTextStyles.h3),
        const SizedBox(height: 6),
        Text(
          isPatch
              ? 'Make sure the patch is sharp, well lit and in the centre of the frame.'
              : 'Make sure the picture is clear, well lit and in the centre of the frame.',
          style: AppTextStyles.bodySecondary,
        ),
        const SizedBox(height: AppSpacing.md),
        // No automatic quality check is performed – this is guidance only.
        // FUTURE ML INTEGRATION: an image-quality model could score blur /
        // lighting here before upload.
        InfoNote(
          text: image.isSample
              ? 'You are using the bundled sample image. It is demo content, not your photo.'
              : 'Photo quality is not checked automatically – please review it yourself.',
        ),
      ],
    );
  }
}
