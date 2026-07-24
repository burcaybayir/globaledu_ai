import 'package:globaledu_ai/core/config/env_config.dart';

class ApiConstants {
  ApiConstants._();

  // OpenAI
  static const String openAiBaseUrl = 'https://api.openai.com/v1';
  static const String chatCompletionsEndpoint = '/chat/completions';
  static const String embeddingsEndpoint = '/embeddings';

  static String get openAiModel => EnvConfig.openAiModel;
  static int get openAiMaxTokens => EnvConfig.openAiMaxTokens;

  // Temperature settings per use case
  static const double chatTemperature = 0.7;
  static const double reviewTemperature = 0.3;
  static const double recommendationTemperature = 0.5;

  // Headers
  static Map<String, String> get baseHeaders => {
        'Content-Type': 'application/json',
      };

  // Rate Limiting
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
}
