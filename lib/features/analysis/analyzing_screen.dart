import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/widgets/brand.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/layout.dart';
import '../../models/skin_concern.dart';
import '../../providers/scan_provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

/// Shows analysis progress for the current scan.
///
/// FUTURE ML INTEGRATION: no change is needed here – the stages and result
/// come from SkinAnalysisService (via ScanProvider.analyzeCurrent). When the
/// real service is plugged in, this screen shows real progress.
class AnalyzingScreen extends StatefulWidget {
  const AnalyzingScreen({super.key});

  @override
  State<AnalyzingScreen> createState() => _AnalyzingScreenState();
}

class _AnalyzingScreenState extends State<AnalyzingScreen> {
  StreamSubscription<AnalysisProgress>? _sub;
  AnalysisStage? _stage;
  AnalysisResult? _result;
  String? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  void _start() {
    _sub?.cancel();
    setState(() {
      _stage = null;
      _result = null;
      _error = null;
    });
    _sub = context.read<ScanProvider>().analyzeCurrent().listen(
      (p) => setState(() {
        _stage = p.stage;
        _result = p.result;
      }),
      onError: (Object e) => setState(() => _error = e.toString()),
    );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  bool get _running => _result == null && _error == null;

  /// Number of finished stages (0–3).
  int get _completed {
    if (_result != null) return AnalysisStage.values.length;
    if (_stage == null) return 0;
    return _stage!.index;
  }

  void _viewResults() {
    final scanId = context.read<ScanProvider>().current.id;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.results,
      (route) => route.settings.name == AppRoutes.shell,
      arguments: scanId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _completed / AnalysisStage.values.length;

    return PopScope(
      canPop: !_running,
      child: Scaffold(
        appBar: const SgAppBar(showBack: false),
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.page),
                  child: Column(
                    children: [
                      const SizedBox(height: AppSpacing.xl),
                      const DemoBadge(label: 'Demo analysis – no real AI'),
                      const SizedBox(height: AppSpacing.xl),
                      _ProgressRing(
                          progress: progress, error: _error != null),
                      const SizedBox(height: AppSpacing.xxl),
                      Text(
                        _error != null
                            ? 'Analysis failed'
                            : _result != null
                                ? 'Analysis complete'
                                : 'Analyzing your skin...',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.h1,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        _error ??
                            (_result != null
                                ? 'Your demo result is ready.'
                                : 'This can take a few moments. Please keep the app open.'),
                        textAlign: TextAlign.center,
                        style: AppTextStyles.bodySecondary,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      for (final stage in AnalysisStage.values)
                        _StageRow(
                          label: stage.label,
                          state: stage.index < _completed
                              ? _StageState.done
                              : (_running && stage == _stage)
                                  ? _StageState.active
                                  : (_error != null && stage == _stage)
                                      ? _StageState.failed
                                      : _StageState.pending,
                        ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page, 8, AppSpacing.page, AppSpacing.lg),
                child: _error != null
                    ? Column(
                        children: [
                          PrimaryButton(label: 'Try again', onPressed: _start),
                          const SizedBox(height: AppSpacing.md),
                          SecondaryButton(
                              label: 'Back to photos',
                              onPressed: () => Navigator.pop(context)),
                        ],
                      )
                    : PrimaryButton(
                        label: 'View Results',
                        onPressed: _result == null ? null : _viewResults,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  const _ProgressRing({required this.progress, required this.error});

  final double progress;
  final bool error;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: progress == 0 ? 0.08 : progress),
              duration: const Duration(milliseconds: 600),
              builder: (context, v, _) => CircularProgressIndicator(
                value: v,
                strokeWidth: 10,
                color: error ? AppColors.danger : AppColors.primary,
                backgroundColor: AppColors.surfaceMuted,
              ),
            ),
          ),
          Container(
            width: 170,
            height: 170,
            decoration: const BoxDecoration(
                color: AppColors.primarySoft, shape: BoxShape.circle),
            child: Center(
              child: error
                  ? const Icon(Icons.error_outline,
                      size: 56, color: AppColors.danger)
                  : const ShieldLogo(size: 64),
            ),
          ),
        ],
      ),
    );
  }
}

enum _StageState { pending, active, done, failed }

class _StageRow extends StatelessWidget {
  const _StageRow({required this.label, required this.state});

  final String label;
  final _StageState state;

  @override
  Widget build(BuildContext context) {
    final Widget indicator = switch (state) {
      _StageState.done => const CircleAvatar(
          radius: 13,
          backgroundColor: AppColors.primary,
          child: Icon(Icons.check, size: 16, color: Colors.white)),
      _StageState.active => const SizedBox(
          width: 26,
          height: 26,
          child: CircularProgressIndicator(
              strokeWidth: 3, color: AppColors.primary)),
      _StageState.failed => const Icon(Icons.cancel,
          color: AppColors.danger, size: 28),
      _StageState.pending => Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.border, width: 2.5),
          ),
        ),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          indicator,
          const SizedBox(width: 16),
          Expanded(
            child: Text(label,
                style: state == _StageState.pending
                    ? AppTextStyles.bodySecondary.copyWith(fontSize: 16)
                    : AppTextStyles.label.copyWith(fontSize: 16)),
          ),
        ],
      ),
    );
  }
}
