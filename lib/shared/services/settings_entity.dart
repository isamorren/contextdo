import 'package:hive/hive.dart';

part 'settings_entity.g.dart';

@HiveType(typeId: 2)
class SettingsEntity extends HiveObject {
  @HiveField(0)
  double lat;

  @HiveField(1)
  double lon;

  @HiveField(2)
  String locationLabel;

  @HiveField(3)
  double rainThresholdMm; // umbral lluvia (mm/h)

  SettingsEntity({
    required this.lat,
    required this.lon,
    required this.locationLabel,
    required this.rainThresholdMm,
  });
}
