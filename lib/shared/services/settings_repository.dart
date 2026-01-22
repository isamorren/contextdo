import 'package:hive/hive.dart';
import 'settings_entity.dart';

class SettingsRepository {
  static const boxName = 'settingsBox';
  static const key = 'settings';

  Future<Box<SettingsEntity>> _box() async =>
      Hive.openBox<SettingsEntity>(boxName);

  Future<SettingsEntity> get() async {
    final box = await _box();
    return box.get(key) ??
        SettingsEntity(
          lat: 4.7110, // Bogotá por defecto
          lon: -74.0721,
          locationLabel: 'Bogotá, CO',
          rainThresholdMm: 0.1,
        );
  }

  Future<void> save(SettingsEntity s) async {
    final box = await _box();
    await box.put(key, s);
  }
}
