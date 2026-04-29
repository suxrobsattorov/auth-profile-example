import 'dart:io';

import 'package:alice/alice.dart';
import 'package:alice_dio/alice_dio_adapter.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:auth_profile_example/infrastructure/local/token_storage.dart';

import '../../core/constants/app_constants.dart';

class DioClient {
  final Alice alice;
  final TokenStorage _storage;

  DioClient(this.alice, this._storage);

  Dio client({bool requireAuth = false}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        contentType: Headers.jsonContentType,
        headers: {
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
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

    if (requireAuth) {
      dio.interceptors.add(
        QueuedInterceptorsWrapper(
          onRequest: (options, handler) async {
            final token = await _storage.getAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
            handler.next(options);
          },
        ),
      );
    }

    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
          logPrint: (o) => debugPrint('[DIO] $o'),
        ),
      );
    }

    return dio;
  }
}
