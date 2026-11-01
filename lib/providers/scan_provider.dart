import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/skin_concern.dart';
import '../models/skin_scan.dart';
import '../services/analysis_service.dart';
import '../services/scan_service.dart';

/// Holds the scan currently being set up / captured and the scan history.
class ScanProvider extends ChangeNotifier {
  ScanProvider(this._scanService, this._analysisService);

  final ScanService _scanService;
  final SkinAnalysisService _analysisService;
  final _uuid = const Uuid();

  ScanSession? _current;
  final List<ScanSession> _history = [];
  bool _historyLoaded = false;

  ScanSession get current => _current ??= _newSession();
  List<ScanSession> get history => List.unmodifiable(_history);
  bool get historyLoaded => _historyLoaded;

  ScanSession? get latestScan {
    for (final s in _history) {
      if (s.result != null) return s;
    }
    return null;
  }

  AnalysisResult? get latestResult => latestScan?.result;

  ScanSession? sessionById(String? id) {
    if (id == null) return latestScan;
    if (_current?.id == id) return _current;
    for (final s in _history) {
      if (s.id == id) return s;
    }
    return null;
  }

  Future<void> loadHistory() async {
    if (_historyLoaded) return;
    _history
      ..clear()
      ..addAll(await _scanService.fetchHistory());
    _historyLoaded = true;
    notifyListeners();
  }

  void clearAll() {
    _current = null;
    _history.clear();
    _historyLoaded = false;
    notifyListeners();
  }

  // ------------------------------------------------------------- set-up

  /// Continues an unfinished draft, or starts a new one if the last scan
  /// was completed.
  void ensureDraft() {
    final c = _current;
    if (c == null || c.status == ScanStatus.completed) startNewScan();
  }

  void startNewScan() {
    _current = _newSession();
    notifyListeners();
  }

  void toggleRegion(FaceRegion region) {
    final s = current;
    if (s.regions.contains(region)) {
      s.regions.remove(region);
      s.images.removeWhere((i) => i.region == region);
    } else {
      s.regions.add(region);
    }
    notifyListeners();
  }

  void clearRegions() {
    current.regions.clear();
    current.images.removeWhere((i) => i.region != null);
    notifyListeners();
  }

  /// Switching mode discards images that belong to the other mode so
  /// full-face and patch photos are never mixed.
  void setType(ScanType type) {
    final s = current;
    if (s.type == type) return;
    s.type = type;
    final targets = s.captureTargets.toSet();
    s.images.removeWhere((i) => !targets.contains(i.region));
    notifyListeners();
  }

  /// Screens edit the answer objects directly and then call this.
  void answersChanged() => notifyListeners();

  // ------------------------------------------------------------ capture

  void setImage(FaceRegion? target, String path, {bool isSample = false}) {
    final s = current;
    s.images.removeWhere((i) => i.region == target);
    s.images.add(ScanImage(
      path: path,
      region: target,
      sessionId: s.id,
      capturedAt: DateTime.now(),
      isSample: isSample,
    ));
    s.status = ScanStatus.capturing;
    notifyListeners();
  }

  void removeImage(FaceRegion? target) {
    current.images.removeWhere((i) => i.region == target);
    notifyListeners();
  }

  void rotateImage(FaceRegion? target) {
    final image = current.imageFor(target);
    if (image == null) return;
    image.quarterTurns = (image.quarterTurns + 1) % 4;
    notifyListeners();
  }

  /// Index (into `current.captureTargets`) of the first target without a
  /// photo, or null when every target has one. An index is used because a
  /// null target means "full face".
  int? get nextMissingIndex {
    final targets = current.captureTargets;
    for (var i = 0; i < targets.length; i++) {
      if (current.imageFor(targets[i]) == null) return i;
    }
    return null;
  }

  // ----------------------------------------------------------- analysis

  /// Runs the analysis for the current scan. On success the scan is saved to
  /// history. The stream is forwarded to the analyzing screen.
  Stream<AnalysisProgress> analyzeCurrent() {
    final session = current;
    session.status = ScanStatus.analyzing;

    final controller = StreamController<AnalysisProgress>();
    _analysisService.analyze(session).listen(
      (progress) {
        if (progress.result != null) {
          session.result = progress.result;
          session.status = ScanStatus.completed;
          _history.removeWhere((s) => s.id == session.id);
          _history.insert(0, session);
          // FUTURE DATABASE INTEGRATION: persisted by the real ScanService.
          unawaited(_scanService.saveScan(session));
          notifyListeners();
        }
        controller.add(progress);
      },
      onError: (Object e) {
        session.status = ScanStatus.failed;
        controller.addError(e);
      },
      onDone: controller.close,
    );
    return controller.stream;
  }

  ScanSession _newSession() =>
      ScanSession(id: _uuid.v4(), createdAt: DateTime.now());
}
