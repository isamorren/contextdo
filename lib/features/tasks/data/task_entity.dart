import 'package:hive/hive.dart';

part 'task_entity.g.dart';

@HiveType(typeId: 1)
class TaskEntity extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  /// 0 indoor, 1 outdoor
  @HiveField(2)
  int type;

  @HiveField(3)
  double minTemp;

  @HiveField(4)
  double maxTemp;

  @HiveField(5)
  bool requireNoRain;

  @HiveField(6)
  bool requireDaylight;

  @HiveField(7)
  bool enabled;

  @HiveField(8)
  DateTime createdAt;

  @HiveField(9)
  DateTime? lastNotifiedAt;

  TaskEntity({
    required this.id,
    required this.title,
    required this.type,
    required this.minTemp,
    required this.maxTemp,
    required this.requireNoRain,
    required this.requireDaylight,
    required this.enabled,
    required this.createdAt,
    required this.lastNotifiedAt,
  });
}
