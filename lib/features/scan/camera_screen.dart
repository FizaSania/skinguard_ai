import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/constants/app_assets.dart';
import '../../core/widgets/scan_image_view.dart';
import '../../models/skin_scan.dart';
import '../../providers/scan_provider.dart';
import '../../services/app_services.dart';
import '../../services/image_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// Value returned by [PhotoReviewScreen].
enum ReviewOutcome { retake, continued }

/// Capture screen for both full face and patch scans.
///
/// For patch scans with several regions the user captures one region at a
/// time; each photo is stored against its own region so images are never
/// mixed up.
///
/// The preview area is a static placeholder. "Take Photo" opens the system
/// camera through [ImageService].
// FUTURE IMAGE INTEGRATION: replace the placeholder with a live preview
// using the `camera` package and real lighting / face-position checks.
class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  int _targetIndex = 0;
  bool _busy = false;
  bool _flash = false;
  String? _notice;

  @override
  void initState() {
    super.initState();
    _targetIndex = context.read<ScanProvider>().nextMissingIndex ?? 0;
  }

  FaceRegion? _targetAt(ScanSession s) =>
      s.captureTargets[_targetIndex.clamp(0, s.captureTargets.length - 1)];

  Future<void> _capture({required bool fromGallery}) async {
    final images = context.read<AppServices>().image;
    setState(() => _busy = true);
    try {
      final path = fromGallery
          ? await images.pickFromGallery()
          : await images.capturePhoto();
      if (path != null && mounted) await _store(path, isSample: false);
    } on ImageServiceException catch (e) {
      if (mounted) await _offerSample(e.message);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _offerSample(String reason) async {
    final useSample = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Camera unavailable'),
        content: Text(
            '$reason\n\nYou can continue the demo with a sample image instead. '
            'It will be clearly labelled as sample content.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Use sample image')),
        ],
      ),
    );
    if (useSample == true && mounted) {
      await _store(AppAssets.sampleSkin, isSample: true);
    }
  }

  Future<void> _store(String path, {required bool isSample}) async {
    final scans = context.read<ScanProvider>();
    scans.setImage(_targetAt(scans.current), path, isSample: isSample);
    await _openReview(_targetIndex);
  }

  Future<void> _openReview(int index) async {
    final scans = context.read<ScanProvider>();
    final target = scans.current.captureTargets[index];
    final outcome = await Navigator.pushNamed(
        context, AppRoutes.photoReview,
        arguments: ReviewArgs(target));
    if (!mounted) return;

    if (outcome == ReviewOutcome.continued) {
      final next = scans.nextMissingIndex;
      if (next == null) {
        Navigator.pushNamed(context, AppRoutes.analyzing);
      } else {
        final nextLabel =
            scans.current.captureTargets[next]?.label ?? 'Full Face';
        // Shown inline (a snackbar would cover the capture buttons).
        setState(() {
          _targetIndex = next;
          _notice = '${target?.label ?? 'Photo'} saved. Now capture: $nextLabel';
        });
      }
    } else {
      setState(() {
        _targetIndex = index;
        _notice = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final scans = context.watch<ScanProvider>();
    final session = scans.current;
    final targets = session.captureTargets;
    final target = _targetAt(session);
    final isPatch = session.type == ScanType.patch;

    return Scaffold(
      backgroundColor: AppColors.cameraBackground,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
              isPatch: isPatch,
              title: target?.label ?? 'Full face',
              flash: _flash,
              onFlash: () => setState(() => _flash = !_flash),
            ),
            if (_notice != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_notice!,
                            style: AppTextStyles.small.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _PreviewPlaceholder(isPatch: isPatch),
              ),
            ),
            if (isPatch && targets.length > 1)
              _RegionProgress(
                session: session,
                currentIndex: _targetIndex,
                onSelect: (i) {
                  if (session.imageFor(targets[i]) != null) {
                    _openReview(i);
                  } else {
                    setState(() => _targetIndex = i);
                  }
                },
              ),
            const SizedBox(height: 12),
            _Shutter(
                busy: _busy, onTap: () => _capture(fromGallery: false)),
            const SizedBox(height: 6),
            Text('Take Photo',
                style: AppTextStyles.label.copyWith(color: Colors.white)),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.page, 14, AppSpacing.page, 0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : () => _capture(fromGallery: true),
                  icon: const Icon(Icons.photo_outlined),
                  label: const Text('Upload from Gallery'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white70),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.lg)),
                    textStyle: AppTextStyles.button,
                  ),
                ),
              ),
            ),
            Wrap(
              alignment: WrapAlignment.center,
              children: [
                TextButton(
                  onPressed: _busy
                      ? null
                      : () => _store(AppAssets.sampleSkin, isSample: true),
                  child: Text('Use sample image (demo)',
                      style: AppTextStyles.small
                          .copyWith(color: Colors.white70)),
                ),
                if (session.allImagesCaptured)
                  TextButton(
                    onPressed: () =>
                        Navigator.pushNamed(context, AppRoutes.analyzing),
                    child: Text('Continue to analysis →',
                        style: AppTextStyles.small.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700)),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.isPatch,
    required this.title,
    required this.flash,
    required this.onFlash,
  });

  final bool isPatch;
  final String title;
  final bool flash;
  final VoidCallback onFlash;

  @override
  Widget build(BuildContext context) {
    Widget roundButton(IconData icon, String tip, VoidCallback onTap) =>
        IconButton(
          tooltip: tip,
          onPressed: onTap,
          style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              fixedSize: const Size(46, 46)),
          icon: Icon(icon, color: Colors.white),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          roundButton(Icons.close, 'Back', () => Navigator.maybePop(context)),
          Expanded(
            child: Column(
              children: [
                if (isPatch)
                  Text('Capturing skin region',
                      style:
                          AppTextStyles.small.copyWith(color: Colors.white60)),
                Text(title,
                    style: AppTextStyles.title.copyWith(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          // Flash is a visual toggle only until a live camera is integrated.
          roundButton(flash ? Icons.flash_on : Icons.flash_off,
              'Flash (preview only)', onFlash),
        ],
      ),
    );
  }
}

class _PreviewPlaceholder extends StatelessWidget {
  const _PreviewPlaceholder({required this.isPatch});

  final bool isPatch;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.xl),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF7A6152), AppColors.cameraPreview, Color(0xFF3E2C22)],
            stops: [0, 0.6, 1],
          ),
        ),
        child: LayoutBuilder(builder: (context, c) {
          return Stack(
            children: [
              // Rule-of-thirds grid
              for (final f in [1 / 3, 2 / 3]) ...[
                Positioned(
                    left: c.maxWidth * f,
                    top: 0,
                    bottom: 0,
                    child: Container(width: 0.6, color: Colors.white24)),
                Positioned(
                    top: c.maxHeight * f,
                    left: 0,
                    right: 0,
                    child: Container(height: 0.6, color: Colors.white24)),
              ],
              // Framing guide
              Center(
                child: isPatch
                    ? const _CornerFrame(size: Size(220, 220))
                    : Container(
                        width: c.maxWidth * 0.62,
                        height: c.maxHeight * 0.72,
                        decoration: ShapeDecoration(
                          shape: OvalBorder(
                            side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.85),
                                width: 2.5),
                          ),
                        ),
                      ),
              ),
              Positioned(
                left: 14,
                top: 14,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  // FUTURE IMAGE INTEGRATION: show the real lighting status
                  // computed from the live camera frames.
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                          width: 9,
                          height: 9,
                          decoration: const BoxDecoration(
                              color: AppColors.warning,
                              shape: BoxShape.circle)),
                      const SizedBox(width: 8),
                      Text('Lighting: check not active (demo)',
                          style: AppTextStyles.small.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Column(
                  children: [
                    Text(
                      isPatch
                          ? 'Place the patch inside the frame'
                          : 'Position your face inside the oval',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.label
                          .copyWith(color: Colors.white, fontSize: 15),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Live preview is not enabled in this build – Take Photo opens your device camera.',
                      textAlign: TextAlign.center,
                      style:
                          AppTextStyles.small.copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CornerFrame extends StatelessWidget {
  const _CornerFrame({required this.size});

  final Size size;

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: Colors.white, width: 3);
    Widget corner(Alignment a) {
      final top = a.y < 0, left = a.x < 0;
      return Align(
        alignment: a,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            border: Border(
              top: top ? side : BorderSide.none,
              bottom: top ? BorderSide.none : side,
              left: left ? side : BorderSide.none,
              right: left ? BorderSide.none : side,
            ),
          ),
        ),
      );
    }

    return SizedBox.fromSize(
      size: size,
      child: Stack(
        children: [
          corner(Alignment.topLeft),
          corner(Alignment.topRight),
          corner(Alignment.bottomLeft),
          corner(Alignment.bottomRight),
        ],
      ),
    );
  }
}

class _RegionProgress extends StatelessWidget {
  const _RegionProgress({
    required this.session,
    required this.currentIndex,
    required this.onSelect,
  });

  final ScanSession session;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final targets = session.captureTargets;
    final done = targets.where((t) => session.imageFor(t) != null).length;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        children: [
          Text('$done of ${targets.length} regions captured',
              style: AppTextStyles.small.copyWith(color: Colors.white70)),
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: targets.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final image = session.imageFor(targets[i]);
                final active = i == currentIndex;
                return ActionChip(
                  onPressed: () => onSelect(i),
                  backgroundColor: active
                      ? AppColors.primary
                      : Colors.white.withValues(alpha: 0.12),
                  side: BorderSide.none,
                  avatar: image == null
                      ? null
                      : SizedBox(
                          width: 20,
                          height: 20,
                          child: ScanImageView(
                            path: image.path,
                            isSample: image.isSample,
                            showSampleLabel: false,
                            radius: 10,
                          ),
                        ),
                  label: Text(
                    '${targets[i]!.label}${image != null ? ' ✓' : ''}',
                    style: AppTextStyles.small.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Shutter extends StatelessWidget {
  const _Shutter({required this.busy, required this.onTap});

  final bool busy;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Take photo',
      child: GestureDetector(
        onTap: busy ? null : onTap,
        child: Container(
          width: 78,
          height: 78,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4),
          ),
          child: Container(
            decoration: const BoxDecoration(
                color: Colors.white, shape: BoxShape.circle),
            child: busy
                ? const Padding(
                    padding: EdgeInsets.all(18),
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
