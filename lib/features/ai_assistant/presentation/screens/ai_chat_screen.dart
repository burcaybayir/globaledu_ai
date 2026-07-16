import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/core/theme/app_spacing.dart';
import 'package:globaledu_ai/core/extensions/context_extensions.dart';
import 'package:globaledu_ai/services/ai/openai_service.dart';
import 'package:globaledu_ai/services/ai/prompt_templates.dart';

final _openAiProvider = Provider((ref) => OpenAiService());
final _messagesProvider = StateProvider<List<_ChatMessage>>((ref) => []);
final _isTypingProvider = StateProvider<bool>((ref) => false);

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  static const _suggestions = [
    '🎓 Recommend universities for CS in Germany',
    '📝 How to write a strong SOP?',
    '💰 Find scholarships for master\'s programs',
    '🛂 US F-1 visa interview tips',
  ];

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final messages = ref.watch(_messagesProvider);
    final isTyping = ref.watch(_isTypingProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: const Icon(Icons.auto_awesome,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AI Assistant',
                    style: context.textTheme.titleMedium),
                Text(
                  isTyping ? 'Typing...' : 'Online',
                  style: context.textTheme.bodySmall?.copyWith(
                    color: isTyping
                        ? AppColors.primary
                        : AppColors.success,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            onPressed: () {
              // Navigate to conversation list
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(
                      AppSpacing.pagePaddingHorizontal,
                    ),
                    itemCount: messages.length + (isTyping ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == messages.length && isTyping) {
                        return _TypingIndicator();
                      }
                      return _ChatBubble(message: messages[index]);
                    },
                  ),
          ),

          // Input
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.huge),
          Container(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(Icons.auto_awesome,
                color: Colors.white, size: 40),
          ),
          const SizedBox(height: AppSpacing.xxl),
          Text(
            'How can I help you today?',
            style: context.textTheme.headlineMedium,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ask me anything about studying abroad',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xxxl),
          ...List.generate(_suggestions.length, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _SuggestionChip(
                text: _suggestions[i],
                onTap: () => _sendMessage(_suggestions[i]),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildInput() {
    final isDark = context.isDarkMode;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        context.bottomPadding + AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLines: 4,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Ask me anything...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (text) {
                if (text.trim().isNotEmpty) _sendMessage(text);
              },
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () {
                if (_controller.text.trim().isNotEmpty) {
                  _sendMessage(_controller.text);
                }
              },
              icon: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    _controller.clear();
    _focusNode.unfocus();

    // Add user message
    final messages = ref.read(_messagesProvider.notifier);
    messages.state = [
      ...messages.state,
      _ChatMessage(content: trimmed, isUser: true),
    ];

    ref.read(_isTypingProvider.notifier).state = true;
    _scrollToBottom();

    // Get AI response
    try {
      final aiService = ref.read(_openAiProvider);
      final history = messages.state
          .map((m) => {
                'role': m.isUser ? 'user' : 'assistant',
                'content': m.content,
              })
          .toList();

      final response = await aiService.chatCompletion(
        messages: history,
        systemPrompt: PromptTemplates.studyAbroadAssistant
            .replaceAll('{user_context}', 'Student using GlobalEdu AI'),
      );

      messages.state = [
        ...messages.state,
        _ChatMessage(content: response, isUser: false),
      ];
    } catch (e) {
      messages.state = [
        ...messages.state,
        _ChatMessage(
          content: 'Sorry, I encountered an error. Please try again.',
          isUser: false,
        ),
      ];
    }

    ref.read(_isTypingProvider.notifier).state = false;
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
}

class _ChatMessage {
  const _ChatMessage({required this.content, required this.isUser});
  final String content;
  final bool isUser;
}

class _ChatBubble extends StatelessWidget {
  const _ChatBubble({required this.message});
  final _ChatMessage message;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;

    return Align(
      alignment:
          message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        constraints: BoxConstraints(
          maxWidth: context.screenWidth * 0.78,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? AppColors.primary
              : (isDark
                  ? AppColors.darkSurfaceVariant
                  : AppColors.lightSurfaceVariant),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppSpacing.radiusLg),
            topRight: const Radius.circular(AppSpacing.radiusLg),
            bottomLeft: Radius.circular(
              message.isUser ? AppSpacing.radiusLg : AppSpacing.radiusXs,
            ),
            bottomRight: Radius.circular(
              message.isUser ? AppSpacing.radiusXs : AppSpacing.radiusLg,
            ),
          ),
        ),
        child: Text(
          message.content,
          style: TextStyle(
            color: message.isUser
                ? Colors.white
                : (isDark
                    ? AppColors.darkTextPrimary
                    : AppColors.lightTextPrimary),
            fontSize: 14,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = context.isDarkMode;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.darkSurfaceVariant
              : AppColors.lightSurfaceVariant,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: Duration(milliseconds: 600 + i * 200),
              builder: (_, value, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.3 + value * 0.5),
                    shape: BoxShape.circle,
                  ),
                );
              },
            );
          }),
        ),
      ),
    );
  }
}

class _SuggestionChip extends StatelessWidget {
  const _SuggestionChip({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: context.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: context.colorScheme.outline.withOpacity(0.2),
          ),
        ),
        child: Text(text, style: context.textTheme.bodyMedium),
      ),
    );
  }
}
