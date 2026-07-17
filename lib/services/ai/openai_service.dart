import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:globaledu_ai/core/config/env_config.dart';
import 'package:globaledu_ai/core/utils/logger.dart';
import 'package:globaledu_ai/features/ai_assistant/domain/entities/chat_message.dart';

/// Available AI models
class AiModel {
  const AiModel({
    required this.id,
    required this.name,
    required this.description,
    this.isPremium = false,
    this.contextWindow = 128000,
    this.icon = '🤖',
  });

  final String id;
  final String name;
  final String description;
  final bool isPremium;
  final int contextWindow;
  final String icon;

  static const gpt4o = AiModel(
    id: 'gpt-4o',
    name: 'GPT-4o',
    description: 'Most capable — text, images, files',
    isPremium: true,
    icon: '⚡',
  );
  static const gpt4oMini = AiModel(
    id: 'gpt-4o-mini',
    name: 'GPT-4o Mini',
    description: 'Fast and affordable',
    icon: '🚀',
  );
  static const gpt35 = AiModel(
    id: 'gpt-3.5-turbo',
    name: 'GPT-3.5 Turbo',
    description: 'Fast responses, great for chat',
    icon: '💬',
  );
  static const gpt4turbo = AiModel(
    id: 'gpt-4-turbo',
    name: 'GPT-4 Turbo',
    description: 'Powerful with vision support',
    isPremium: true,
    icon: '🧠',
  );

  static const all = [gpt4o, gpt4oMini, gpt35, gpt4turbo];
}

/// System prompt for the Study Abroad AI
const _kSystemPrompt = '''
You are GlobalEdu AI, an expert study abroad assistant helping students navigate their international education journey.

You are deeply knowledgeable about:
- **Universities** worldwide — rankings, programs, admission requirements, campus life
- **Scholarships & Funding** — merit-based, government grants, university-specific aid
- **Visa Applications** — student visa processes for USA, UK, Canada, Australia, Germany, and more
- **IELTS & TOEFL** — preparation strategies, score requirements, test tips
- **TOEFL, GRE, GMAT** — exam strategies and university requirements
- **Accommodation** — on-campus vs off-campus, student housing, costs
- **Part-time Jobs & Internships** — working while studying abroad, work permits
- **Immigration** — post-study work visas, PR pathways (Canada, Australia, Germany)
- **Career Planning** — global job markets, networking, career services
- **Budget Planning** — cost of living, tuition comparisons, financial planning

**Personality:**
- Warm, encouraging, and professional
- Give specific, actionable advice (not generic answers)
- Use bullet points and headers for clarity
- Always consider the student's background and goals
- When asked about specific universities, provide real data

**Format:** Use Markdown for all responses — headers, bullet points, bold text, tables where helpful.
''';

class OpenAIStreamService {
  OpenAIStreamService._();
  static final instance = OpenAIStreamService._();

  final _baseUrl = 'https://api.openai.com/v1/chat/completions';

  String get _apiKey => EnvConfig.openAiApiKey;

  /// Stream a response token by token from OpenAI
  Stream<String> streamCompletion({
    required List<ChatMessage> messages,
    String model = 'gpt-4o-mini',
    double temperature = 0.7,
    int maxTokens = 2000,
  }) async* {
    // Build the message list with system prompt
    final apiMessages = <Map<String, dynamic>>[
      {'role': 'system', 'content': _kSystemPrompt},
      ...messages.where((m) => m.role != MessageRole.system).map((m) => m.toApiMessage()),
    ];

    final body = jsonEncode({
      'model': model,
      'messages': apiMessages,
      'stream': true,
      'temperature': temperature,
      'max_tokens': maxTokens,
    });

    try {
      final request = http.Request('POST', Uri.parse(_baseUrl));
      request.headers.addAll({
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_apiKey',
      });
      request.body = body;

      final response = await request.send();

      if (response.statusCode != 200) {
        final errBody = await response.stream.bytesToString();
        AppLogger.error('OpenAI error ${response.statusCode}: $errBody');
        yield* _handleError(response.statusCode);
        return;
      }

      // SSE stream parsing
      await for (final chunk in response.stream.transform(utf8.decoder)) {
        final lines = chunk.split('\n');
        for (final line in lines) {
          if (!line.startsWith('data: ')) continue;
          final data = line.substring(6).trim();
          if (data == '[DONE]') return;
          if (data.isEmpty) continue;

          try {
            final json = jsonDecode(data) as Map<String, dynamic>;
            final choices = json['choices'] as List<dynamic>?;
            if (choices == null || choices.isEmpty) continue;

            final delta = choices[0]['delta'] as Map<String, dynamic>?;
            final content = delta?['content'] as String?;
            if (content != null && content.isNotEmpty) {
              yield content;
            }
          } catch (_) {
            // skip malformed chunks
          }
        }
      }
    } catch (e) {
      AppLogger.error('Stream error', e);
      yield '\n\n*An error occurred. Please check your API key and connection.*';
    }
  }

  /// Non-streaming for single response
  Future<String> complete({
    required List<ChatMessage> messages,
    String model = 'gpt-4o-mini',
    double temperature = 0.7,
  }) async {
    final buffer = StringBuffer();
    await for (final token in streamCompletion(
      messages: messages,
      model: model,
      temperature: temperature,
    )) {
      buffer.write(token);
    }
    return buffer.toString();
  }

  /// Generate a conversation title from the first user message
  Future<String> generateTitle(String firstMessage) async {
    try {
      final messages = [
        ChatMessage(
          id: 'sys',
          role: MessageRole.user,
          content: 'Generate a short (max 5 words) title for this conversation: "$firstMessage". Reply with only the title, no quotes.',
          createdAt: DateTime.now(),
        ),
      ];
      final title = await complete(messages: messages, model: 'gpt-4o-mini', temperature: 0.3);
      return title.trim().replaceAll('"', '').take(50);
    } catch (_) {
      return firstMessage.length > 40
          ? '${firstMessage.substring(0, 40)}...'
          : firstMessage;
    }
  }

  Stream<String> _handleError(int code) async* {
    switch (code) {
      case 401:
        yield '\n\n*Invalid API key. Please add your OpenAI key in the .env file.*';
      case 429:
        yield '\n\n*Rate limit exceeded. Please wait a moment and try again.*';
      case 503:
        yield '\n\n*OpenAI is temporarily unavailable. Please try again.*';
      default:
        yield '\n\n*Request failed (error $code). Please try again.*';
    }
  }
}

extension _StringTake on String {
  String take(int n) => length <= n ? this : substring(0, n);
}
