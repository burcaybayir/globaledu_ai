import 'package:cloud_functions/cloud_functions.dart';
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

  /// Stream a response (currently yields full response at once from Cloud Function)
  Stream<String> streamCompletion({
    required List<ChatMessage> messages,
    String model = 'gpt-4o-mini',
    double temperature = 0.7,
    int maxTokens = 2000,
  }) async* {
    final apiMessages = <Map<String, dynamic>>[
      {'role': 'system', 'content': _kSystemPrompt},
      ...messages.where((m) => m.role != MessageRole.system).map((m) => m.toApiMessage()),
    ];

    try {
      final callable = FirebaseFunctions.instance.httpsCallable('chatWithAI');
      final response = await callable.call<Map<String, dynamic>>({
        'model': model,
        'messages': apiMessages,
        'maxTokens': maxTokens,
      });

      final data = response.data as Map<String, dynamic>;
      
      if (data['success'] != true) {
        throw Exception('Cloud Function error: ${data['error']}');
      }

      yield data['response'] as String;
      
    } on FirebaseFunctionsException catch (e) {
      AppLogger.error('Firebase Functions error', e, e.stackTrace);
      yield* _handleError(e.code);
    } catch (e) {
      AppLogger.error('Stream error', e);
      yield '\n\n*An error occurred. Please check your connection.*';
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

  Stream<String> _handleError(String code) async* {
    switch (code) {
      case 'unauthenticated':
        yield '\n\n*You must be logged in to use the AI.*';
      case 'resource-exhausted':
        yield '\n\n*You have run out of AI credits. Please upgrade your plan.*';
      default:
        yield '\n\n*Request failed. Please try again.*';
    }
  }
}

extension _StringTake on String {
  String take(int n) => length <= n ? this : substring(0, n);
}
