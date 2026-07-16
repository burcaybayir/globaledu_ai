import 'package:dio/dio.dart';
import 'package:globaledu_ai/core/constants/app_constants.dart';
import 'package:globaledu_ai/core/network/api_interceptors.dart';

class ApiClient {
  ApiClient._();

  static Dio? _instance;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.connectionTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.addAll([
      AuthInterceptor(),
      LoggingInterceptor(),
      RetryInterceptor(dio: dio),
    ]);

    return dio;
  }

  /// Creates a Dio instance specifically for OpenAI requests.
  static Dio createOpenAiClient(String apiKey) {
    final dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.openai.com/v1',
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 120),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
      ),
    );

    dio.interceptors.addAll([
      LoggingInterceptor(),
      RetryInterceptor(dio: dio, maxRetries: 2),
    ]);

    return dio;
  }

  /// Resets the singleton instance (useful for testing).
  static void reset() {
    _instance?.close();
    _instance = null;
  }
}
