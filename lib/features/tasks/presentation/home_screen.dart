import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../context_engine/application/context_engine_providers.dart';
import '../domain/task.dart';
import 'task_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ContextDo'),
        actions: [
          IconButton(
            tooltip: 'Configuración',
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
          ),
          IconButton(
            tooltip: 'Probar ahora',
            onPressed: () => _showEvaluateNow(context),
            icon: const Icon(Icons.auto_awesome_outlined),
          ),
          IconButton(
            tooltip: 'Actualizar',
            onPressed: () => ref.read(tasksProvider.notifier).refresh(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/task'),
        icon: const Icon(Icons.add),
        label: const Text('Nueva tarea'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: tasksAsync.when(
                data: (tasks) {
                  if (tasks.isEmpty) {
                    return _EmptyStateWidget(
                      onCreate: () => context.push('/task'),
                    );
                  }
                  return _TaskListWithEvaluation(tasks: tasks);
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorStateWidget(
                  message: e.toString(),
                  onRetry: () => ref.read(tasksProvider.notifier).refresh(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Función de nivel superior (NO va dentro de una clase)
Future<void> _showEvaluateNow(BuildContext context) async {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => const _EvaluateNowSheet(),
  );
}

/// Widget que muestra la lista de tareas con evaluación de elegibilidad (FASE 1.3 y 1.4)
class _TaskListWithEvaluation extends ConsumerWidget {
  final List<Task> tasks;
  const _TaskListWithEvaluation({required this.tasks});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final evalAsync = ref.watch(evaluateNowProvider);

    // Construimos un mapa taskId -> eligible para lookup rápido
    final evalResults = evalAsync.whenOrNull(data: (items) => items);
    final eligibilityMap = evalResults != null
        ? {for (final e in evalResults) e.taskId: e.eligible}
        : null;

    final eligibleCount = eligibilityMap?.values.where((e) => e).length ?? 0;
    final hasEvaluation = eligibilityMap != null;

    // FASE 2.1: Obtener la primera tarea elegible para la card de recomendación
    final firstEligible = evalResults?.where((e) => e.eligible).firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // FASE 2.1: Card "Recomendación del momento"
        if (firstEligible != null)
          _RecommendationCard(item: firstEligible, otherEligibleCount: eligibleCount - 1),

        // Header solo cuando NO hay card pero sí hay evaluación (0 elegibles)
        if (firstEligible == null && hasEvaluation)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Ahora mismo no es el mejor momento',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ),
        Expanded(
          child: ListView.separated(
            itemCount: tasks.length,
            separatorBuilder: (context, index) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final task = tasks[i];
              // FASE 1.3: Determinar si es elegible (null si no hay evaluación aún)
              final isEligible = eligibilityMap?[task.id];
              return _TaskCardWidget(task: task, isEligible: isEligible);
            },
          ),
        ),
      ],
    );
  }
}

/// FASE 2.1: Card destacada con la recomendación del momento
class _RecommendationCard extends StatelessWidget {
  final TaskEvalView item;
  final int otherEligibleCount;
  const _RecommendationCard({required this.item, this.otherEligibleCount = 0});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final snap = item.snapshot;
    final isOutdoor = item.taskType == TaskType.outdoor;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 0,
        color: cs.primaryContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    color: cs.onPrimaryContainer,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Recomendado ahora',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: cs.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const Spacer(),
                  // Icono del tipo de tarea (interior/exterior)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: cs.onPrimaryContainer.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isOutdoor ? Icons.park : Icons.home,
                      color: cs.onPrimaryContainer,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                item.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: cs.onPrimaryContainer,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: [
                  _MiniChip(
                    icon: Icons.thermostat,
                    text: '${snap.temperatureC.round()}°C',
                    colorScheme: cs,
                  ),
                  if (snap.precipitationMm < 0.1)
                    _MiniChip(
                      icon: Icons.water_drop_outlined,
                      text: 'Sin lluvia',
                      colorScheme: cs,
                    ),
                  if (snap.isDaylight == true)
                    _MiniChip(
                      icon: Icons.wb_sunny_outlined,
                      text: 'Con luz',
                      colorScheme: cs,
                    ),
                ],
              ),
              // Indicador de otras tareas elegibles
              if (otherEligibleCount > 0) ...[
                const SizedBox(height: 10),
                Text(
                  '+$otherEligibleCount tarea${otherEligibleCount > 1 ? 's' : ''} más disponible${otherEligibleCount > 1 ? 's' : ''}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: cs.onPrimaryContainer.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Chip pequeño para la card de recomendación
class _MiniChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final ColorScheme colorScheme;

  const _MiniChip({
    required this.icon,
    required this.text,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.onPrimaryContainer.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.onPrimaryContainer),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCardWidget extends ConsumerWidget {
  final Task task;
  final bool? isEligible; // null = no evaluado aún, true = elegible, false = no elegible
  const _TaskCardWidget({required this.task, this.isEligible});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    // FASE 1.3: Atenuar tareas no elegibles (solo si está habilitada y evaluada)
    final shouldDim = task.enabled && isEligible == false;
    final opacity = shouldDim ? 0.6 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                task.type == TaskType.outdoor ? Icons.park : Icons.home,
                color: cs.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      _ChipWidget(
                        text: task.type == TaskType.outdoor
                            ? 'Exterior'
                            : 'Interior',
                      ),
                      _ChipWidget(
                        text:
                            '${task.minTemp.round()}–${task.maxTemp.round()}°C',
                      ),
                      if (task.requireNoRain)
                        const _ChipWidget(text: 'Sin lluvia'),
                      if (task.requireDaylight)
                        const _ChipWidget(text: 'Luz día'),
                    ],
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: task.enabled,
              onChanged: (v) =>
                  ref.read(tasksProvider.notifier).toggleEnabled(task.id, v),
            ),
            IconButton(
              tooltip: 'Eliminar',
              onPressed: () => ref.read(tasksProvider.notifier).remove(task.id),
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _ChipWidget extends StatelessWidget {
  final String text;
  const _ChipWidget({required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(text),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  final VoidCallback onCreate;
  const _EmptyStateWidget({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.auto_awesome, size: 56, color: cs.primary),
            const SizedBox(height: 16),
            Text(
              'Tus tareas, pero con sentido',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Crea tareas que solo se activan cuando el clima y la luz son adecuados.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Crear mi primera tarea'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorStateWidget({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off_outlined, size: 40),
          const SizedBox(height: 10),
          Text(
            'Sin conexión',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          const Text(
            'Revisa tu conexión a internet',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}

class _EvaluateNowSheet extends ConsumerWidget {
  const _EvaluateNowSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(evaluateNowProvider);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: 16 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: async.when(
          loading: () => const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => SizedBox(
            height: 240,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off_outlined, size: 40),
                  const SizedBox(height: 10),
                  Text(
                    'Sin conexión',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Necesitamos internet para consultar el clima',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => ref.invalidate(evaluateNowProvider),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
          data: (items) {
            if (items.isEmpty) {
              return SizedBox(
                height: 220,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.toggle_off_outlined, size: 40),
                      const SizedBox(height: 10),
                      Text(
                        'No hay tareas activas',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 6),
                      const Text('Activa al menos una tarea para evaluar.'),
                    ],
                  ),
                ),
              );
            }

            final snap = items.first.snapshot;
            final eligibleCount = items.where((e) => e.eligible).length;
            final total = items.length;

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.75,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    eligibleCount > 0
                        ? '✨ $eligibleCount de $total tarea${total == 1 ? '' : 's'} puede${eligibleCount == 1 ? '' : 'n'} hacerse ahora'
                        : 'Ahora mismo no hay tareas elegibles',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Condiciones actuales',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _InfoChip(
                        icon: Icons.thermostat,
                        text: '${snap.temperatureC.toStringAsFixed(1)}°C',
                      ),
                      _InfoChip(
                        icon: Icons.water_drop_outlined,
                        text: '${snap.precipitationMm.toStringAsFixed(1)} mm',
                      ),
                      if (snap.isDaylight != null)
                        _InfoChip(
                          icon: Icons.wb_sunny_outlined,
                          text: snap.isDaylight! ? 'Día' : 'Noche',
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Text(
                        'Resultados',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => ref.invalidate(evaluateNowProvider),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reevaluar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, i) => _EvalCard(item: items[i]),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EvalCard extends StatelessWidget {
  final TaskEvalView item;
  const _EvalCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = item.eligible ? cs.primary : cs.error;

    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              item.eligible
                  ? Icons.check_circle_outline
                  : Icons.cancel_outlined,
              color: color,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(item.reason),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18),
      label: Text(text),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
