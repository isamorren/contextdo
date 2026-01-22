import '../../tasks/domain/task.dart';
import '../data/weather_api.dart';
import '../data/sun_api.dart';

class ContextSnapshot {
  final double temperatureC;
  final double precipitationMm;
  final bool? isDaylight; // null si no se evaluó
  final DateTime evaluatedAt;

  ContextSnapshot({
    required this.temperatureC,
    required this.precipitationMm,
    required this.isDaylight,
    required this.evaluatedAt,
  });
}

class EvalResult {
  final bool eligible;
  final String reason;
  final ContextSnapshot snapshot;

  EvalResult({
    required this.eligible,
    required this.reason,
    required this.snapshot,
  });
}

class ContextEngine {
  final WeatherApi weatherApi;
  final SunApi sunApi;

  ContextEngine({required this.weatherApi, required this.sunApi});

  Future<EvalResult> evaluate({
    required Task task,
    required double lat,
    required double lon,
    required double rainThresholdMm,
    required DateTime now,
  }) async {
    final weather = await weatherApi.fetchCurrent(lat: lat, lon: lon);

    bool? isDaylight;
    if (task.requireDaylight) {
      final sun = await sunApi.fetch(lat: lat, lon: lon, date: now.toUtc());
      final nowUtc = now.toUtc();
      isDaylight =
          nowUtc.isAfter(sun.sunriseUtc) && nowUtc.isBefore(sun.sunsetUtc);
    }

    final snap = ContextSnapshot(
      temperatureC: weather.temperatureC,
      precipitationMm: weather.precipitationMm,
      isDaylight: isDaylight,
      evaluatedAt: now,
    );

    // Reglas de temperatura
    if (weather.temperatureC < task.minTemp) {
      return EvalResult(
        eligible: false,
        reason: 'Hace un poco de frío (${_f1(weather.temperatureC)}°C)',
        snapshot: snap,
      );
    }
    if (weather.temperatureC > task.maxTemp) {
      return EvalResult(
        eligible: false,
        reason: 'Hace demasiado calor (${_f1(weather.temperatureC)}°C)',
        snapshot: snap,
      );
    }

    // Regla de lluvia
    if (task.requireNoRain && weather.precipitationMm > rainThresholdMm) {
      return EvalResult(
        eligible: false,
        reason: 'Está lloviendo ahora',
        snapshot: snap,
      );
    }

    // Regla de luz
    if (task.requireDaylight && isDaylight == false) {
      return EvalResult(
        eligible: false,
        reason: 'Ya no hay luz natural',
        snapshot: snap,
      );
    }

    return EvalResult(
      eligible: true,
      reason: 'Buen momento para esta tarea',
      snapshot: snap,
    );
  }

  String _f1(double v) =>
      (v.isFinite ? (v * 10).round() / 10 : 0).toStringAsFixed(1);
}
