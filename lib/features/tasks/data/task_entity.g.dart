// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskEntityAdapter extends TypeAdapter<TaskEntity> {
  @override
  final int typeId = 1;

  @override
  TaskEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TaskEntity(
      id: fields[0] as String,
      title: fields[1] as String,
      type: fields[2] as int,
      minTemp: fields[3] as double,
      maxTemp: fields[4] as double,
      requireNoRain: fields[5] as bool,
      requireDaylight: fields[6] as bool,
      enabled: fields[7] as bool,
      createdAt: fields[8] as DateTime,
      lastNotifiedAt: fields[9] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TaskEntity obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.minTemp)
      ..writeByte(4)
      ..write(obj.maxTemp)
      ..writeByte(5)
      ..write(obj.requireNoRain)
      ..writeByte(6)
      ..write(obj.requireDaylight)
      ..writeByte(7)
      ..write(obj.enabled)
      ..writeByte(8)
      ..write(obj.createdAt)
      ..writeByte(9)
      ..write(obj.lastNotifiedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
