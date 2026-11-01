import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/routes.dart';
import '../../core/constants/app_assets.dart';
import '../../core/utils/formatters.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/layout.dart';
import '../../core/widgets/scan_image_view.dart';
import '../../core/widgets/selection.dart';
import '../../models/skincare_plan.dart';
import '../../providers/plan_provider.dart';
import '../../services/app_services.dart';
import '../../services/image_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_theme.dart';

class PlannerScreen extends StatefulWidget {
  const PlannerScreen({super.key});

  @override
  State<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends State<PlannerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => context.read<PlanProvider>().load());
  }

  Future<void> _addTask() async {
    final result = await showModalBottomSheet<(String, RoutinePeriod)>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const _AddTaskSheet(),
    );
    if (result != null && mounted) {
      context.read<PlanProvider>().addTask(result.$1, result.$2);
    }
  }

  Future<void> _addFollowUp() async {
    final plan = context.read<PlanProvider>();
    final images = context.read<AppServices>().image;
    final choice = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.science_outlined),
              title: const Text('Use sample image (demo)'),
              onTap: () => Navigator.pop(context, 'sample'),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    if (choice == 'sample') {
      plan.addProgressEntry(AppAssets.sampleSkin, isSample: true);
      showSnack(context, 'Sample follow-up photo added');
      return;
    }
    try {
      final path = choice == 'camera'
          ? await images.capturePhoto()
          : await images.pickFromGallery();
      if (path == null || !mounted) return;
      plan.addProgressEntry(path);
      showSnack(context, 'Follow-up photo added');
    } on ImageServiceException catch (e) {
      if (mounted) showSnack(context, '${e.message} Try the sample image.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final plan = context.watch<PlanProvider>();

    return PageLayout(
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          PrimaryButton(label: 'Add Follow-up Photo', onPressed: _addFollowUp),
          const SizedBox(height: AppSpacing.md),
          SecondaryButton(
            label: 'Compare Scans',
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.compareScans),
          ),
        ],
      ),
      children: [
        Text('My plan & tracker', style: AppTextStyles.h1),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: LinearProgressIndicator(
                  value: plan.completion,
                  minHeight: 8,
                  color: AppColors.primary,
                  backgroundColor: AppColors.surfaceMuted,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Text('${plan.completedCount} of ${plan.totalCount} done today',
                key: const Key('plan_counter'),
                style: AppTextStyles.label.copyWith(color: AppColors.primary)),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
        SectionTitle(
          'My Daily Skincare Plan',
          trailing: TextButton.icon(
            onPressed: _addTask,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add step'),
          ),
        ),
        for (final period in RoutinePeriod.values) ...[
          Text(period.label, style: AppTextStyles.overline),
          const SizedBox(height: 6),
          _RoutineCard(tasks: plan.tasksFor(period), plan: plan),
          const SizedBox(height: AppSpacing.lg),
        ],
        const SizedBox(height: AppSpacing.sm),
        const SectionTitle('Patch Progress',
            subtitle: 'Add a photo every week to see how your skin changes.'),
        if (plan.progress.isEmpty)
          const InfoNote(
              icon: Icons.photo_outlined,
              text: 'No progress photos yet. Add your first follow-up photo.')
        else
          SizedBox(
            height: 128,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: plan.progress.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final e = plan.progress[i];
                return Column(
                  children: [
                    SizedBox(
                      width: 104,
                      height: 92,
                      child: ScanImageView(
                        path: e.imagePath,
                        isSample: e.isSample,
                        radius: AppRadius.md,
                        showSampleLabel: false,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                        '${Formatters.dayMonth(e.date)}${e.isSample ? ' · demo' : ''}',
                        style: AppTextStyles.label),
                  ],
                );
              },
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        if (plan.progress.any((e) => e.isSample))
          Text('Entries marked "demo" are sample images, not real progress data.',
              style: AppTextStyles.small),
      ],
    );
  }
}

class _RoutineCard extends StatelessWidget {
  const _RoutineCard({required this.tasks, required this.plan});

  final List<RoutineTask> tasks;
  final PlanProvider plan;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return AppCard(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text('No steps yet – tap “Add step”.',
            style: AppTextStyles.bodySecondary),
      );
    }
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < tasks.length; i++) ...[
            if (i > 0) const Divider(height: 1),
            CheckboxListTile(
              key: Key('task_${tasks[i].id}'),
              value: tasks[i].isDone,
              onChanged: (_) => plan.toggleTask(tasks[i].id),
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                tasks[i].title,
                style: AppTextStyles.body.copyWith(
                  fontSize: 16,
                  decoration:
                      tasks[i].isDone ? TextDecoration.lineThrough : null,
                  color: tasks[i].isDone
                      ? AppColors.textSecondary
                      : AppColors.textPrimary,
                ),
              ),
              secondary: tasks[i].isCustom
                  ? IconButton(
                      tooltip: 'Remove step',
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => plan.removeTask(tasks[i].id),
                    )
                  : null,
            ),
          ],
        ],
      ),
    );
  }
}

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet();

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _controller = TextEditingController();
  RoutinePeriod _period = RoutinePeriod.morning;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    if (_controller.text.trim().isEmpty) {
      setState(() => _error = 'Enter a step name');
      return;
    }
    Navigator.pop(context, (_controller.text.trim(), _period));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(AppSpacing.page, AppSpacing.xl,
          AppSpacing.page, MediaQuery.viewInsetsOf(context).bottom + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add routine step', style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _controller,
            autofocus: true,
            maxLength: 60,
            decoration: InputDecoration(
                hintText: 'e.g. Apply eye cream', errorText: _error),
            onSubmitted: (_) => _save(),
          ),
          const SizedBox(height: AppSpacing.sm),
          SegmentedToggle(
            labels: const ['Morning', 'Evening'],
            selectedIndex: _period.index,
            onChanged: (i) =>
                setState(() => _period = RoutinePeriod.values[i]),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(label: 'Add', onPressed: _save),
        ],
      ),
    );
  }
}
