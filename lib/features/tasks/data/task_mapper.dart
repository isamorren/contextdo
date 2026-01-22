import '../domain/task.dart';
import 'task_entity.dart';

class TaskMapper {
  static Task fromEntity(TaskEntity e) {
    return Task(
      id: e.id,
      title: e.title,
      type: e.type == 1 ? TaskType.outdoor : TaskType.indoor,
      minTemp: e.minTemp,
      maxTemp: e.maxTemp,
      requireNoRain: e.requireNoRain,
      requireDaylight: e.requireDaylight,
      enabled: e.enabled,
      createdAt: e.createdAt,
      lastNotifiedAt: e.lastNotifiedAt,
    );
  }

  static TaskEntity toEntity(Task t) {
    return TaskEntity(
      id: t.id,
      title: t.title,
      type: t.type == TaskType.outdoor ? 1 : 0,
      minTemp: t.minTemp,
      maxTemp: t.maxTemp,
      requireNoRain: t.requireNoRain,
      requireDaylight: t.requireDaylight,
      enabled: t.enabled,
      createdAt: t.createdAt,
      lastNotifiedAt: t.lastNotifiedAt,
    );
  }
}
