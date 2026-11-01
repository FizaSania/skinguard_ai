import '../data/mock/mock_plan.dart';
import '../models/skincare_plan.dart';

abstract class PlanService {
  Future<List<RoutineTask>> loadRoutine();

  Future<List<ProgressEntry>> loadProgress();

  Future<void> saveRoutine(List<RoutineTask> tasks);
}

/// Demo routine kept in memory for the current app session only.
///
/// FUTURE DATABASE INTEGRATION:
/// Load / save the routine and daily completion state per user and sync
/// with the backend (`GET/PUT /plan`). Reset `isDone` each new day.
class MockPlanService implements PlanService {
  @override
  Future<List<RoutineTask>> loadRoutine() async => MockPlan.routine();

  @override
  Future<List<ProgressEntry>> loadProgress() async => MockPlan.progress();

  @override
  Future<void> saveRoutine(List<RoutineTask> tasks) async {}
}
