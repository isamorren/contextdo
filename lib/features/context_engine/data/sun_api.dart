import 'package:dio/dio.dart';

class SunTimes {
  final DateTime sunriseUtc;
  final DateTime sunsetUtc;

  SunTimes({required this.sunriseUtc, required this.sunsetUtc});
}

class SunApi {
  final Dio _dio;
  SunApi(this._dio);

  Future<SunTimes> fetch({
    required double lat,
    required double lon,
    required DateTime date,
  }) async {
    try {
      final res = await _dio.get(
        'https://api.sunrise-sunset.org/json',
        queryParameters: {
          'lat': lat,
          'lng': lon,
          'date': '${date.year}-${_two(date.month)}-${_two(date.day)}',
          'formatted': 0,
        },
      );

      final data = res.data;
      if (data is! Map<String, dynamic>) {
        throw const FormatException('Respuesta inválida (no es JSON object)');
      }

      final results = data['results'];
      if (results is! Map<String, dynamic>) {
        throw const FormatException('Respuesta inválida: falta "results"');
      }

      final sunrise = results['sunrise'];
      final sunset = results['sunset'];

      if (sunrise is! String || sunset is! String) {
        throw const FormatException('Campos inválidos en "results"');
      }

      return SunTimes(
        sunriseUtc: DateTime.parse(sunrise).toUtc(),
        sunsetUtc: DateTime.parse(sunset).toUtc(),
      );
    } on DioException catch (e) {
      throw Exception('Error de red (Sunrise-Sunset): ${e.type}');
    }
  }

  String _two(int v) => v.toString().padLeft(2, '0');
}
