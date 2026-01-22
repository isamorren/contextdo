import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/task.dart';
import 'task_controller.dart';

class TaskFormScreen extends ConsumerStatefulWidget {
  const TaskFormScreen({super.key});

  @override
  ConsumerState<TaskFormScreen> createState() => _TaskFormScreenState();
}

class _TaskFormScreenState extends ConsumerState<TaskFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();

  TaskType taskType = TaskType.outdoor;

  bool requireNoRain = true;
  bool requireDaylight = true;

  double minTemp = 12;
  double maxTemp = 28;

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final task = Task(
      title: _titleCtrl.text.trim(),
      type: taskType,
      minTemp: minTemp,
      maxTemp: maxTemp,
      requireNoRain: requireNoRain,
      requireDaylight: requireDaylight,
      enabled: true,
    );

    await ref.read(tasksProvider.notifier).save(task);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva tarea')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Título',
                        hintText: 'Ej: Salir a correr',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        final value = (v ?? '').trim();
                        if (value.isEmpty) return 'Escribe un título';
                        if (value.length < 3) return 'Muy corto';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 12),

                    SegmentedButton<TaskType>(
                      segments: const [
                        ButtonSegment(
                          value: TaskType.outdoor,
                          label: Text('Exterior'),
                          icon: Icon(Icons.park_outlined),
                        ),
                        ButtonSegment(
                          value: TaskType.indoor,
                          label: Text('Interior'),
                          icon: Icon(Icons.home_outlined),
                        ),
                      ],
                      selected: {taskType},
                      onSelectionChanged: (s) {
                        setState(() => taskType = s.first);
                      },
                    ),

                    _SectionCard(
                      title: 'Condiciones',
                      child: Column(
                        children: [
                          SwitchListTile.adaptive(
                            value: requireNoRain,
                            onChanged: (v) => setState(() => requireNoRain = v),
                            title: const Text('Evitar lluvia'),
                            subtitle: const Text(
                              'Solo notificar si no hay lluvia.',
                            ),
                          ),
                          const Divider(height: 1),
                          SwitchListTile.adaptive(
                            value: requireDaylight,
                            onChanged: (v) =>
                                setState(() => requireDaylight = v),
                            title: const Text('Solo con luz de día'),
                            subtitle: const Text(
                              'Entre salida y puesta del sol.',
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    _SectionCard(
                      title: 'Temperatura',
                      subtitle: '${minTemp.round()}°C – ${maxTemp.round()}°C',
                      child: Column(
                        children: [
                          RangeSlider(
                            values: RangeValues(minTemp, maxTemp),
                            min: -5,
                            max: 40,
                            divisions: 45,
                            labels: RangeLabels(
                              '${minTemp.round()}°C',
                              '${maxTemp.round()}°C',
                            ),
                            onChanged: (range) => setState(() {
                              minTemp = range.start;
                              maxTemp = range.end;
                            }),
                          ),
                          Text(
                            'Tip: ajusta el rango para evitar notificaciones inútiles.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),

                          // ✅ Micro-preview (FASE 1.1)
                          const SizedBox(height: 12),
                          _EligibilityPreview(
                            requireNoRain: requireNoRain,
                            requireDaylight: requireDaylight,
                            minTemp: minTemp,
                            maxTemp: maxTemp,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    FilledButton.icon(
                      onPressed: _save,
                      icon: const Icon(Icons.check),
                      label: const Text('Guardar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EligibilityPreview extends StatelessWidget {
  final bool requireNoRain;
  final bool requireDaylight;
  final double minTemp;
  final double maxTemp;

  const _EligibilityPreview({
    required this.requireNoRain,
    required this.requireDaylight,
    required this.minTemp,
    required this.maxTemp,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    final parts = <String>[
      if (requireNoRain) 'Sin lluvia',
      if (requireDaylight) 'Con luz de día',
      '${minTemp.round()}–${maxTemp.round()} °C',
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Esta tarea será elegible cuando:',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: parts
                .map(
                  (t) => Chip(
                    label: Text(t),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;

  const _SectionCard({required this.title, required this.child, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
