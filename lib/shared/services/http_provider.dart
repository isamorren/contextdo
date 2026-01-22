import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'http_client.dart';

final dioProvider = Provider<Dio>((ref) => createDio());
