import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/services/http_provider.dart';
import 'sun_api.dart';
import 'weather_api.dart';

final weatherApiProvider = Provider<WeatherApi>((ref) {
  return WeatherApi(ref.read(dioProvider));
});

final sunApiProvider = Provider<SunApi>((ref) {
  return SunApi(ref.read(dioProvider));
});
