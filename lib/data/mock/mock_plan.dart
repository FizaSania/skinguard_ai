import '../../core/constants/app_assets.dart';
import '../../models/skincare_plan.dart';

/// Demo routine and progress photos for "My plan & tracker".
///
/// FUTURE DATABASE INTEGRATION: the routine will be generated from the
/// user's recommendations and stored per user.
class MockPlan {
  MockPlan._();

  static List<RoutineTask> routine() => [
        RoutineTask(
            id: 'm1',
            title: 'Cleanse with Gentle Gel Cleanser',
            period: RoutinePeriod.morning),
        RoutineTask(
            id: 'm2',
            title: 'Apply Oil-Free Gel Moisturizer',
            period: RoutinePeriod.morning),
        RoutineTask(
            id: 'm3',
            title: 'Apply Fragrance-Free SPF 50 Sunscreen',
            period: RoutinePeriod.morning),
        RoutineTask(
            id: 'e1',
            title: 'Cleanse with Gentle Gel Cleanser',
            period: RoutinePeriod.evening),
        RoutineTask(
            id: 'e2',
            title: 'Apply Oil-Free Gel Moisturizer',
            period: RoutinePeriod.evening),
      ];

  /// Sample timeline entries (02 Sep, 10 Sep, 18 Sep) from the design.
  /// Marked as samples so the UI labels them as demo content.
  static List<ProgressEntry> progress() {
    final year = DateTime.now().year;
    return [
      ProgressEntry(
          id: 'p1',
          date: DateTime(year, 9, 2),
          imagePath: AppAssets.sampleProgress[0],
          isSample: true),
      ProgressEntry(
          id: 'p2',
          date: DateTime(year, 9, 10),
          imagePath: AppAssets.sampleProgress[1],
          isSample: true),
      ProgressEntry(
          id: 'p3',
          date: DateTime(year, 9, 18),
          imagePath: AppAssets.sampleProgress[2],
          isSample: true),
    ];
  }
}
