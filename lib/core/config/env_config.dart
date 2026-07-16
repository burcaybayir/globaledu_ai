import 'package:flutter_dotenv/flutter_dotenv.dart';

class EnvConfig {
  EnvConfig._();

  static late final String openAiApiKey;
  static late final String openAiModel;
  static late final int openAiMaxTokens;
  static late final String revenueCatAppleKey;
  static late final String revenueCatGoogleKey;
  static late final String appEnv;
  static late final bool isDebug;

  static void initialize() {
    openAiApiKey = dotenv.env['OPENAI_API_KEY'] ?? '';
    openAiModel = dotenv.env['OPENAI_MODEL'] ?? 'gpt-4o-mini';
    openAiMaxTokens = int.tryParse(
          dotenv.env['OPENAI_MAX_TOKENS'] ?? '4096',
        ) ??
        4096;
    revenueCatAppleKey = dotenv.env['REVENUECAT_APPLE_KEY'] ?? '';
    revenueCatGoogleKey = dotenv.env['REVENUECAT_GOOGLE_KEY'] ?? '';
    appEnv = dotenv.env['APP_ENV'] ?? 'development';
    isDebug = dotenv.env['APP_DEBUG'] == 'true';
  }

  static bool get isProduction => appEnv == 'production';
  static bool get isDevelopment => appEnv == 'development';
  static bool get isStaging => appEnv == 'staging';
}
