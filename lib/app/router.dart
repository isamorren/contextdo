import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/tasks/presentation/home_screen.dart';
import '../features/tasks/presentation/task_form_screen.dart';
import '../shared/services/settings_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/task', builder: (context, state) => const TaskFormScreen()),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
    ),
  ],
  errorBuilder: (context, state) =>
      Scaffold(body: Center(child: Text(state.error.toString()))),
);
