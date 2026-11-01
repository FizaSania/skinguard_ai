enum RoutinePeriod {
  morning('MORNING'),
  evening('EVENING');

  const RoutinePeriod(this.label);
  final String label;
}

class RoutineTask {
  RoutineTask({
    required this.id,
    required this.title,
    required this.period,
    this.isDone = false,
    this.isCustom = false,
  });

  final String id;
  final String title;
  final RoutinePeriod period;
  bool isDone;

  /// Tasks added by the user (can be removed).
  final bool isCustom;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'period': period.name,
        'isDone': isDone,
        'isCustom': isCustom,
      };
}

/// A photo in the "Patch Progress" timeline.
class ProgressEntry {
  ProgressEntry({
    required this.id,
    required this.date,
    required this.imagePath,
    this.isSample = false,
    this.note = '',
  });

  final String id;
  final DateTime date;
  final String imagePath;
  final bool isSample;
  final String note;
}
