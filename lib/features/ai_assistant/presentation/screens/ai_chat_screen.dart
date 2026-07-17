import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:globaledu_ai/core/theme/app_colors.dart';
import 'package:globaledu_ai/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:globaledu_ai/features/ai_assistant/presentation/providers/chat_provider.dart';
import 'package:globaledu_ai/features/ai_assistant/presentation/widgets/message_bubble.dart';
import 'package:globaledu_ai/features/ai_assistant/presentation/widgets/chat_input_bar.dart';
import 'package:globaledu_ai/features/ai_assistant/presentation/widgets/model_selector_sheet.dart';
import 'package:globaledu_ai/features/ai_assistant/presentation/widgets/suggested_prompts.dart';
import 'package:globaledu_ai/services/ai/openai_service.dart';

class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen>
    with TickerProviderStateMixin {
  final _scrollCtrl = ScrollController();
  late AnimationController _headerCtrl;
  late Animation<double> _headerFade;

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..forward();
    _headerFade = CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    _headerCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom({bool animated = true}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      if (animated) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      } else {
        _scrollCtrl.jumpTo(_scrollCtrl.position.maxScrollExtent);
      }
    });
  }

  void _openModelSelector(BuildContext context, String currentModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ModelSelectorSheet(
        currentModel: currentModel,
        onSelect: (model) {
          ref.read(chatProvider.notifier).changeModel(model);
        },
      ),
    );
  }

  void _openConversationDrawer(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _ConversationDrawer(
        onSelect: (convId) {
          ref.read(chatProvider.notifier).switchConversation(convId);
          Navigator.pop(context);
          _scrollToBottom(animated: false);
        },
        onNew: () {
          ref.read(chatProvider.notifier).newConversation();
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final chatState = ref.watch(chatProvider);
    final model = ref.watch(activeModelProvider);
    final messages = chatState.messages;
    final isStreaming = chatState.isStreaming;
    final streamingText = chatState.streamingText;
    final isListening = chatState.isListening;
    final voiceText = chatState.voiceText;

    // Auto-scroll when new content arrives
    ref.listen(chatProvider, (prev, next) {
      if (next.messages.length != prev?.messages.length || next.isStreaming) {
        _scrollToBottom();
      }
    });

    final modelInfo = AiModel.all.firstWhere(
      (m) => m.id == model,
      orElse: () => AiModel.gpt4oMini,
    );

    return Scaffold(
      body: Column(
        children: [
          // ── Header ──────────────────────────────────────────────────────
          FadeTransition(
            opacity: _headerFade,
            child: _ChatHeader(
              modelInfo: modelInfo,
              isStreaming: isStreaming,
              messageCount: messages.length,
              onModelTap: () => _openModelSelector(context, model),
              onHistoryTap: () => _openConversationDrawer(context),
              onNewChat: () => ref.read(chatProvider.notifier).newConversation(),
            ),
          ),

          // ── Content Area ─────────────────────────────────────────────────
          Expanded(
            child: messages.isEmpty && !isStreaming
                ? SuggestedPrompts(
                    onTap: (prompt) => ref
                        .read(chatProvider.notifier)
                        .sendMessage(prompt),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 8),
                    physics: const BouncingScrollPhysics(),
                    itemCount: messages.length,
                    itemBuilder: (_, i) {
                      final msg = messages[i];
                      final isLastAssistant = i == messages.length - 1 &&
                          msg.role == MessageRole.assistant &&
                          isStreaming;

                      return MessageBubble(
                        key: ValueKey(msg.id),
                        message: msg,
                        streamingText: isLastAssistant ? streamingText : null,
                        isStreaming: isLastAssistant,
                        onSpeak: () => ref
                            .read(chatProvider.notifier)
                            .speakMessage(msg.content),
                        onCopy: () {},
                      );
                    },
                  ),
          ),

          // ── Input Bar ────────────────────────────────────────────────────
          ChatInputBar(
            isStreaming: isStreaming,
            isListening: isListening,
            voiceText: voiceText,
            onSend: (text, attachments) =>
                ref.read(chatProvider.notifier).sendMessage(text, attachments: attachments),
            onVoiceStart: () =>
                ref.read(chatProvider.notifier).startVoiceInput(),
            onVoiceStop: () =>
                ref.read(chatProvider.notifier).stopVoiceInput(),
          ),
        ],
      ),
    );
  }
}

// ── Header ────────────────────────────────────────────────────────────────────

class _ChatHeader extends StatelessWidget {
  const _ChatHeader({
    required this.modelInfo,
    required this.isStreaming,
    required this.messageCount,
    required this.onModelTap,
    required this.onHistoryTap,
    required this.onNewChat,
  });

  final AiModel modelInfo;
  final bool isStreaming;
  final int messageCount;
  final VoidCallback onModelTap;
  final VoidCallback onHistoryTap;
  final VoidCallback onNewChat;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.fromLTRB(
        16, MediaQuery.of(context).padding.top + 10, 16, 12,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.15),
          ),
        ),
      ),
      child: Row(
        children: [
          // History button
          _HeaderBtn(icon: Icons.menu_rounded, onTap: onHistoryTap),
          const SizedBox(width: 10),

          // Model selector chip
          Expanded(
            child: GestureDetector(
              onTap: onModelTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(modelInfo.icon, style: const TextStyle(fontSize: 16)),
                    const SizedBox(width: 6),
                    Text(
                      modelInfo.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    if (isStreaming)
                      _ThinkingIndicator()
                    else
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),
          // New chat button
          _HeaderBtn(icon: Icons.add_rounded, onTap: onNewChat),
        ],
      ),
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  const _HeaderBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: theme.colorScheme.onSurface),
      ),
    );
  }
}

class _ThinkingIndicator extends StatefulWidget {
  @override
  State<_ThinkingIndicator> createState() => _ThinkingIndicatorState();
}

class _ThinkingIndicatorState extends State<_ThinkingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_ctrl),
      child: Text(
        ' ●',
        style: TextStyle(
          color: AppColors.accentMint,
          fontSize: 10,
        ),
      ),
    );
  }
}

// ── Conversation Drawer ───────────────────────────────────────────────────────

class _ConversationDrawer extends ConsumerStatefulWidget {
  const _ConversationDrawer({required this.onSelect, required this.onNew});
  final ValueChanged<String> onSelect;
  final VoidCallback onNew;

  @override
  ConsumerState<_ConversationDrawer> createState() => _ConversationDrawerState();
}

class _ConversationDrawerState extends ConsumerState<_ConversationDrawer> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final query = ref.watch(searchQueryProvider);
    final convsAsync = ref.watch(conversationsProvider);
    final activeId = ref.watch(activeConversationIdProvider);

    final convs = convsAsync.when(
      data: (list) =>
          query.isEmpty ? list : ref.read(conversationsProvider.notifier).search(query),
      loading: () => <dynamic>[],
      error: (_, __) => <dynamic>[],
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, scrollCtrl) => Column(
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.outlineVariant,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 16, 10),
            child: Row(
              children: [
                Text(
                  'Conversations',
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: widget.onNew,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add_rounded, color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'New',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Search
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (q) => ref.read(searchQueryProvider.notifier).state = q,
              decoration: InputDecoration(
                hintText: 'Search conversations...',
                prefixIcon: const Icon(Icons.search_rounded, size: 18),
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),

          // List
          Expanded(
            child: convsAsync.isLoading
                ? const Center(child: CircularProgressIndicator())
                : convs.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('💬', style: TextStyle(fontSize: 40)),
                            const SizedBox(height: 8),
                            Text(
                              'No conversations yet',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: scrollCtrl,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: convs.length,
                        itemBuilder: (_, i) {
                          final conv = convs[i];
                          final isActive = conv.id == activeId;
                          return Dismissible(
                            key: Key(conv.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 20),
                              decoration: BoxDecoration(
                                color: AppColors.error.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(Icons.delete_rounded, color: AppColors.error),
                            ),
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('Delete conversation?'),
                                  content: const Text('This cannot be undone.'),
                                  actions: [
                                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete', style: TextStyle(color: AppColors.error))),
                                  ],
                                ),
                              );
                            },
                            onDismissed: (_) => ref.read(conversationsProvider.notifier).delete(conv.id),
                            child: GestureDetector(
                              onTap: () => widget.onSelect(conv.id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  gradient: isActive ? AppColors.primaryGradient : null,
                                  color: isActive ? null : theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Row(
                                  children: [
                                    Text(
                                      '💬',
                                      style: TextStyle(
                                        fontSize: isActive ? 20 : 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            conv.title,
                                            style: theme.textTheme.titleSmall?.copyWith(
                                              color: isActive ? Colors.white : null,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            '${conv.messages.length} messages · ${conv.model}',
                                            style: theme.textTheme.labelSmall?.copyWith(
                                              color: isActive
                                                  ? Colors.white.withOpacity(0.7)
                                                  : theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (conv.isPinned)
                                      Icon(
                                        Icons.push_pin_rounded,
                                        size: 14,
                                        color: isActive ? Colors.white70 : AppColors.accentGold,
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
