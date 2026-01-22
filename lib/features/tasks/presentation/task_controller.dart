import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/task_repository.dart';
import '../domain/task.dart';

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepository();
});

final tasksProvider = AsyncNotifierProvider<TasksController, List<Task>>(
  TasksController.new,
);

class TasksController extends AsyncNotifier<List<Task>> {
  late final TaskRepository _repo;

  @override
  Future<List<Task>> build() async {
    _repo = ref.read(taskRepositoryProvider);
    return _repo.getAll();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.getAll());
  }

  Future<void> save(Task task) async {
    await _repo.upsert(task);
    await refresh();
  }

  Future<void> remove(String id) async {
    await _repo.delete(id);
    await refresh();
  }

  Future<void> toggleEnabled(String id, bool enabled) async {
    await _repo.setEnabled(id, enabled);
    await refresh();
  }
}
