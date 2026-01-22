import 'package:hive/hive.dart';

import '../domain/task.dart';
import 'task_entity.dart';
import 'task_mapper.dart';

class TaskRepository {
  static const boxName = 'tasksBox';

  Future<Box<TaskEntity>> _box() async {
    return Hive.openBox<TaskEntity>(boxName);
  }

  Future<List<Task>> getAll() async {
    final box = await _box();
    final items = box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items.map(TaskMapper.fromEntity).toList();
  }

  Future<void> upsert(Task task) async {
    final box = await _box();
    await box.put(task.id, TaskMapper.toEntity(task));
  }

  Future<void> delete(String id) async {
    final box = await _box();
    await box.delete(id);
  }

  Future<void> setEnabled(String id, bool enabled) async {
    final box = await _box();
    final current = box.get(id);
    if (current == null) return;
    current.enabled = enabled;
    await current.save();
  }
}
