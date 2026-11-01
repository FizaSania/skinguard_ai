import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/skincare_plan.dart';
import '../services/plan_service.dart';

/// Daily routine checklist and patch-progress photos (session state only).
class PlanProvider extends ChangeNotifier {
  PlanProvider(this._service);

  final PlanService _service;
  final _uuid = const Uuid();

  final List<RoutineTask> _tasks = [];
  final List<ProgressEntry> _progress = [];
  bool _loaded = false;

  bool get loaded => _loaded;
  List<RoutineTask> get tasks => List.unmodifiable(_tasks);
  List<ProgressEntry> get progress => List.unmodifiable(_progress);

  List<RoutineTask> tasksFor(RoutinePeriod period) =>
      _tasks.where((t) => t.period == period).toList();

  int get completedCount => _tasks.where((t) => t.isDone).length;
  int get totalCount => _tasks.length;
  double get completion => totalCount == 0 ? 0 : completedCount / totalCount;

  Future<void> load() async {
    if (_loaded) return;
    _tasks
      ..clear()
      ..addAll(await _service.loadRoutine());
    _progress
      ..clear()
      ..addAll(await _service.loadProgress());
    _loaded = true;
    notifyListeners();
  }

  /// Test / reset helper.
  void setTasks(List<RoutineTask> tasks) {
    _tasks
      ..clear()
      ..addAll(tasks);
    _loaded = true;
    notifyListeners();
  }

  void toggleTask(String id) {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.isDone = !task.isDone;
    _persist();
    notifyListeners();
  }

  bool addTask(String title, RoutinePeriod period) {
    final value = title.trim();
    if (value.isEmpty) return false;
    _tasks.add(RoutineTask(
        id: _uuid.v4(), title: value, period: period, isCustom: true));
    _persist();
    notifyListeners();
    return true;
  }

  void removeTask(String id) {
    _tasks.removeWhere((t) => t.id == id);
    _persist();
    notifyListeners();
  }

  void addProgressEntry(String imagePath, {bool isSample = false}) {
    _progress.add(ProgressEntry(
      id: _uuid.v4(),
      date: DateTime.now(),
      imagePath: imagePath,
      isSample: isSample,
    ));
    // FUTURE IMAGE UPLOAD INTEGRATION: upload the follow-up photo and link
    // it to the original scan for progress comparison.
    notifyListeners();
  }

  void clear() {
    _tasks.clear();
    _progress.clear();
    _loaded = false;
    notifyListeners();
  }

  // FUTURE DATABASE INTEGRATION: persist routine completion per day.
  void _persist() => _service.saveRoutine(_tasks);
}
