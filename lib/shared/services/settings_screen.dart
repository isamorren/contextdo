import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_controller.dart';
import 'settings_entity.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _labelCtrl = TextEditingController();
  final _latCtrl = TextEditingController();
  final _lonCtrl = TextEditingController();
  final _rainCtrl = TextEditingController();

  @override
  void dispose() {
    _labelCtrl.dispose();
    _latCtrl.dispose();
    _lonCtrl.dispose();
    _rainCtrl.dispose();
    super.dispose();
  }

  void _fill(SettingsEntity s) {
    _labelCtrl.text = s.locationLabel;
    _latCtrl.text = s.lat.toStringAsFixed(6);
    _lonCtrl.text = s.lon.toStringAsFixed(6);
    _rainCtrl.text = s.rainThresholdMm.toStringAsFixed(1);
  }

  Future<void> _save(SettingsEntity current) async {
    if (!_formKey.currentState!.validate()) return;

    final s = SettingsEntity(
      lat: double.parse(_latCtrl.text.trim()),
      lon: double.parse(_lonCtrl.text.trim()),
      locationLabel: _labelCtrl.text.trim(),
      rainThresholdMm: double.parse(_rainCtrl.text.trim()),
    );

    await ref.read(settingsProvider.notifier).saveSettings(s);
    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Configuración guardada')));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: settingsAsync.when(
                data: (s) {
                  if (_labelCtrl.text.isEmpty &&
                      _latCtrl.text.isEmpty &&
                      _lonCtrl.text.isEmpty &&
                      _rainCtrl.text.isEmpty) {
                    _fill(s);
                  }

                  return Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        TextFormField(
                          controller: _labelCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Ubicación (nombre)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v ?? '').trim().isEmpty ? 'Requerido' : null,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _latCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Latitud',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) =>
                                    double.tryParse((v ?? '').trim()) == null
                                    ? 'Número inválido'
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _lonCtrl,
                                decoration: const InputDecoration(
                                  labelText: 'Longitud',
                                  border: OutlineInputBorder(),
                                ),
                                keyboardType: TextInputType.number,
                                validator: (v) =>
                                    double.tryParse((v ?? '').trim()) == null
                                    ? 'Número inválido'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _rainCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Umbral lluvia (mm/h)',
                            hintText: 'Ej: 0.1',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (v) =>
                              double.tryParse((v ?? '').trim()) == null
                              ? 'Número inválido'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () => _save(s),
                          icon: const Icon(Icons.save),
                          label: const Text('Guardar'),
                        ),
                      ],
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text(e.toString())),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
