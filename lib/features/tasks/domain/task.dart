import 'package:uuid/uuid.dart';

enum TaskType { indoor, outdoor }

class Task {
  final String id;
  final String title;
  final TaskType type;

  final double minTemp;
  final double maxTemp;

  final bool requireNoRain;
  final bool requireDaylight;

  final bool enabled;

  final DateTime createdAt;
  final DateTime? lastNotifiedAt;

  Task({
    String? id,
    required this.title,
    required this.type,
    required this.minTemp,
    required this.maxTemp,
    required this.requireNoRain,
    required this.requireDaylight,
    required this.enabled,
    DateTime? createdAt,
    this.lastNotifiedAt,
  }) : id = id ?? const Uuid().v4(),
       createdAt = createdAt ?? DateTime.now();

  Task copyWith({
    String? title,
    TaskType? type,
    double? minTemp,
    double? maxTemp,
    bool? requireNoRain,
    bool? requireDaylight,
    bool? enabled,
    DateTime? lastNotifiedAt,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      minTemp: minTemp ?? this.minTemp,
      maxTemp: maxTemp ?? this.maxTemp,
      requireNoRain: requireNoRain ?? this.requireNoRain,
      requireDaylight: requireDaylight ?? this.requireDaylight,
      enabled: enabled ?? this.enabled,
      createdAt: createdAt,
      lastNotifiedAt: lastNotifiedAt ?? this.lastNotifiedAt,
    );
  }
}
