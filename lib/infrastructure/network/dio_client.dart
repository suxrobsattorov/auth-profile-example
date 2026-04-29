import 'dart:io';

import 'package:alice/alice.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import '../../core/constants/app_constants.dart';

final Alice alice = Alice();

class DioClient {
  Dio client({bool requireAuth = false}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    if (!kIsWeb) {
      dio.httpClientAdapter = IOHttpClientAdapter(
        createHttpClient: () => HttpClient(),
      );
    }

    final adapter = AliceDioAdapter();
    alice.addAdapter(adapter);
    dio.interceptors.add(adapter);

    return dio;
  }
}
