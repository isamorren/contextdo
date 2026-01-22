import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:contextdo/app/app.dart';
import 'package:contextdo/features/tasks/data/task_entity.dart';
import 'package:contextdo/shared/services/settings_entity.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('contextdo_hive_test_');
    Hive.init(dir.path);

    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TaskEntityAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(SettingsEntityAdapter());
    }
  });

  tearDownAll(() async {
    await Hive.close();
  });

  testWidgets('App builds (smoke)', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: ContextDoApp()));

    // En vez de pumpAndSettle (que se cuelga con animaciones infinitas),
    // bombeamos unos frames y verificamos que no crasheó al construir.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.byType(ContextDoApp), findsOneWidget);
  });
}
