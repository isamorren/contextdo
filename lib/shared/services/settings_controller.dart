import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'settings_entity.dart';
import 'settings_repository.dart';

final settingsRepoProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepository();
});

final settingsProvider =
    AsyncNotifierProvider<SettingsController, SettingsEntity>(
      SettingsController.new,
    );

class SettingsController extends AsyncNotifier<SettingsEntity> {
  @override
  Future<SettingsEntity> build() async {
    final repo = ref.read(settingsRepoProvider);
    return repo.get();
  }

  Future<void> saveSettings(SettingsEntity s) async {
    final repo = ref.read(settingsRepoProvider);
    state = const AsyncValue.loading();
    await repo.save(s);
    state = AsyncValue.data(s);
  }
}
