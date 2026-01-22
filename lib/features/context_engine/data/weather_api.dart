import 'package:dio/dio.dart';

class WeatherSnapshot {
  final double temperatureC;
  final double precipitationMm;

  WeatherSnapshot({required this.temperatureC, required this.precipitationMm});
}

class WeatherApi {
  final Dio _dio;
  WeatherApi(this._dio);

  Future<WeatherSnapshot> fetchCurrent({
    required double lat,
    required double lon,
  }) async {
    try {
      final res = await _dio.get(
        'https://api.open-meteo.com/v1/forecast',
        queryParameters: {
          'latitude': lat,
          'longitude': lon,
          'current': 'temperature_2m,precipitation',
          'timezone': 'auto',
        },
      );

      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Respuesta inválida (no es JSON object)');
      }

      final current = data['current'];
      if (current is! Map<String, dynamic>) {
        throw const FormatException('Respuesta inválida: falta "current"');
      }

      final temp = current['temperature_2m'];
      final precip = current['precipitation'];

      if (temp is! num || precip is! num) {
        throw const FormatException('Campos inválidos en "current"');
      }

      return WeatherSnapshot(
        temperatureC: temp.toDouble(),
        precipitationMm: precip.toDouble(),
      );
    } on DioException catch (e) {
      // Mensaje estable para UI/Logs
      throw Exception('Error de red (Open-Meteo): ${e.type}');
    }
  }
}
