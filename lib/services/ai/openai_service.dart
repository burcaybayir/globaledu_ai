import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:globaledu_ai/core/config/env_config.dart';
import 'package:globaledu_ai/core/constants/api_constants.dart';
import 'package:globaledu_ai/core/errors/exceptions.dart';
import 'package:globaledu_ai/core/network/api_client.dart';
import 'package:globaledu_ai/core/utils/logger.dart';
import 'package:globaledu_ai/services/ai/prompt_templates.dart';

/// OpenAI service for chat completions and AI features.
class OpenAiService {
  OpenAiService({Dio? dio})
      : _dio = dio ??
            ApiClient.createOpenAiClient(EnvConfig.openAiApiKey);

  final Dio _dio;

  /// Sends a chat completion request and returns the full response.
  Future<String> chatCompletion({
    required List<Map<String, String>> messages,
    String? systemPrompt,
    double temperature = ApiConstants.chatTemperature,
    int? maxTokens,
  }) async {
    try {
      final allMessages = <Map<String, String>>[
        if (systemPrompt != null)
          {'role': 'system', 'content': systemPrompt},
        ...messages,
      ];

      final response = await _dio.post(
        ApiConstants.chatCompletionsEndpoint,
        data: {
          'model': EnvConfig.openAiModel,
          'messages': allMessages,
          'temperature': temperature,
          'max_tokens': maxTokens ?? EnvConfig.openAiMaxTokens,
        },
      );

      final content = response.data['choices'][0]['message']['content'] as String;
      return content.trim();
    } on DioException catch (e) {
      AppLogger.error('OpenAI chat completion failed', e);
      throw AiException(
        message: _extractErrorMessage(e),
        code: 'OPENAI_CHAT_ERROR',
      );
    } catch (e) {
      AppLogger.error('Unexpected AI error', e);
      throw AiException(
        message: 'Failed to get AI response. Please try again.',
        code: 'OPENAI_UNKNOWN',
      );
    }
  }

  /// Streams a chat completion response token by token.
  Stream<String> chatCompletionStream({
    required List<Map<String, String>> messages,
    String? systemPrompt,
    double temperature = ApiConstants.chatTemperature,
    int? maxTokens,
  }) async* {
    try {
      final allMessages = <Map<String, String>>[
        if (systemPrompt != null)
          {'role': 'system', 'content': systemPrompt},
        ...messages,
      ];

      final response = await _dio.post<ResponseBody>(
        ApiConstants.chatCompletionsEndpoint,
        data: {
          'model': EnvConfig.openAiModel,
          'messages': allMessages,
          'temperature': temperature,
          'max_tokens': maxTokens ?? EnvConfig.openAiMaxTokens,
          'stream': true,
        },
        options: Options(responseType: ResponseType.stream),
      );

      final stream = response.data!.stream;
      String buffer = '';

      await for (final chunk in stream) {
        buffer += utf8.decode(chunk);
        final lines = buffer.split('\n');
        buffer = lines.last;

        for (final line in lines.take(lines.length - 1)) {
          final trimmed = line.trim();
          if (trimmed.isEmpty || trimmed == 'data: [DONE]') continue;
          if (!trimmed.startsWith('data: ')) continue;

          try {
            final json = jsonDecode(trimmed.substring(6));
            final delta = json['choices']?[0]?['delta']?['content'] as String?;
            if (delta != null && delta.isNotEmpty) {
              yield delta;
            }
          } catch (_) {
            // Skip malformed chunks
          }
        }
      }
    } on DioException catch (e) {
      AppLogger.error('OpenAI stream failed', e);
      throw AiException(
        message: _extractErrorMessage(e),
        code: 'OPENAI_STREAM_ERROR',
      );
    }
  }

  /// Reviews a document using AI.
  Future<String> reviewDocument({
    required String documentContent,
    required String documentType,
    String? targetInfo,
  }) async {
    final systemPrompt = PromptTemplates.documentReview
        .replaceAll('{document_type}', documentType)
        .replaceAll('{target_info}', targetInfo ?? 'Not specified')
        .replaceAll('{document_content}', documentContent);

    return chatCompletion(
      messages: [
        {'role': 'user', 'content': 'Please review this document.'},
      ],
      systemPrompt: systemPrompt,
      temperature: ApiConstants.reviewTemperature,
    );
  }

  /// Gets university recommendations based on profile.
  Future<String> getUniversityRecommendations({
    required String studentProfile,
    required List<String> targetCountries,
    required String educationLevel,
    required String studyField,
    String? budget,
    double? gpa,
  }) async {
    final systemPrompt = PromptTemplates.universityRecommendation
        .replaceAll('{student_profile}', studentProfile)
        .replaceAll('{target_countries}', targetCountries.join(', '))
        .replaceAll('{education_level}', educationLevel)
        .replaceAll('{study_field}', studyField)
        .replaceAll('{budget}', budget ?? 'Flexible')
        .replaceAll('{gpa}', gpa?.toString() ?? 'Not provided');

    return chatCompletion(
      messages: [
        {
          'role': 'user',
          'content': 'Recommend universities that match my profile.',
        },
      ],
      systemPrompt: systemPrompt,
      temperature: ApiConstants.recommendationTemperature,
    );
  }

  String _extractErrorMessage(DioException e) {
    if (e.response?.data is Map) {
      final error = (e.response!.data as Map)['error'];
      if (error is Map) {
        return error['message'] as String? ?? 'AI service error occurred.';
      }
    }
    if (e.response?.statusCode == 429) {
      return 'AI rate limit reached. Please wait a moment.';
    }
    if (e.response?.statusCode == 401) {
      return 'AI service authentication failed.';
    }
    return 'AI service is temporarily unavailable.';
  }
}
