import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tasks/domain/task.dart';
import '../../tasks/presentation/task_controller.dart';
import '../../../shared/services/settings_controller.dart';
import '../data/context_api_providers.dart';
import 'context_engine.dart';

final contextEngineProvider = Provider<ContextEngine>((ref) {
  return ContextEngine(
    weatherApi: ref.read(weatherApiProvider),
    sunApi: ref.read(sunApiProvider),
  );
});

class TaskEvalView {
  final String taskId;
  final String title;
  final TaskType taskType;
  final bool eligible;
  final String reason;
  final ContextSnapshot snapshot;

  TaskEvalView({
    required this.taskId,
    required this.title,
    required this.taskType,
    required this.eligible,
    required this.reason,
    required this.snapshot,
  });
}

final evaluateNowProvider = FutureProvider.autoDispose<List<TaskEvalView>>((
  ref,
) async {
  final tasks = await ref.read(tasksProvider.future);
  final settings = await ref.read(settingsProvider.future);

  final active = tasks.where((t) => t.enabled).toList();
  if (active.isEmpty) return <TaskEvalView>[];

  final engine = ref.read(contextEngineProvider);
  final now = DateTime.now();

  // Evaluamos en paralelo para que sea rápido.
  final results = await Future.wait(
    active.map((t) async {
      final r = await engine.evaluate(
        task: t,
        lat: settings.lat,
        lon: settings.lon,
        rainThresholdMm: settings.rainThresholdMm,
        now: now,
      );
      return TaskEvalView(
        taskId: t.id,
        title: t.title,
        taskType: t.type,
        eligible: r.eligible,
        reason: r.reason,
        snapshot: r.snapshot,
      );
    }),
  );

  // Orden: primero elegibles
  results.sort((a, b) => (b.eligible ? 1 : 0).compareTo(a.eligible ? 1 : 0));
  return results;
});
