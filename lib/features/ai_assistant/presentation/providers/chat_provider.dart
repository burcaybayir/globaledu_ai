import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:globaledu_ai/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:globaledu_ai/features/ai_assistant/domain/entities/conversation.dart';
import 'package:globaledu_ai/features/ai_assistant/data/repositories/conversation_repository.dart';
import 'package:globaledu_ai/services/ai/openai_service.dart';
import 'package:globaledu_ai/services/ai/tts_service.dart';
import 'package:globaledu_ai/services/ai/stt_service.dart';
import 'package:globaledu_ai/core/utils/logger.dart';

// ── Providers ─────────────────────────────────────────────────────────────────

/// All conversations list
final conversationsProvider =
    StateNotifierProvider<ConversationsNotifier, AsyncValue<List<Conversation>>>(
  (ref) => ConversationsNotifier(),
);

/// Active conversation ID
final activeConversationIdProvider = StateProvider<String?>((ref) => null);

/// Active model selection
final activeModelProvider = StateProvider<String>((ref) => 'gpt-4o-mini');

/// STT listening state
final sttListeningProvider = StateProvider<bool>((ref) => false);

/// TTS speaking state
final ttsSpeakingProvider = StateProvider<bool>((ref) => false);

/// Search query
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Chat state for the active conversation
final chatProvider =
    StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  final convId = ref.watch(activeConversationIdProvider);
  final model = ref.watch(activeModelProvider);
  return ChatNotifier(ref, convId, model);
});

// ── Conversations Notifier ─────────────────────────────────────────────────────

class ConversationsNotifier
    extends StateNotifier<AsyncValue<List<Conversation>>> {
  ConversationsNotifier() : super(const AsyncValue.loading()) {
    _load();
  }

  final _repo = ConversationRepository.instance;

  Future<void> _load() async {
    try {
      final list = await _repo.loadAll();
      state = AsyncValue.data(list);
    } catch (e, s) {
      state = AsyncValue.error(e, s);
    }
  }

  void refresh() => _load();

  List<Conversation> search(String query) => _repo.search(query);

  Future<Conversation> create({String model = 'gpt-4o-mini'}) async {
    final conv = await _repo.createConversation(model: model);
    _load();
    return conv;
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    _load();
  }

  Future<void> togglePin(String id) async {
    await _repo.togglePin(id);
    _load();
  }

  void updateFromChat(Conversation conv) {
    state.whenData((list) {
      final idx = list.indexWhere((c) => c.id == conv.id);
      if (idx == -1) {
        state = AsyncValue.data([conv, ...list]);
      } else {
        final updated = [...list];
        updated[idx] = conv;
        updated.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
        state = AsyncValue.data(updated);
      }
    });
  }
}

// ── Chat State ────────────────────────────────────────────────────────────────

class ChatState {
  const ChatState({
    this.conversation,
    this.isStreaming = false,
    this.streamingText = '',
    this.error,
    this.isListening = false,
    this.voiceText = '',
  });

  final Conversation? conversation;
  final bool isStreaming;
  final String streamingText;
  final String? error;
  final bool isListening;
  final String voiceText;

  List<ChatMessage> get messages => conversation?.messages ?? [];

  ChatState copyWith({
    Conversation? conversation,
    bool? isStreaming,
    String? streamingText,
    String? error,
    bool? isListening,
    String? voiceText,
  }) =>
      ChatState(
        conversation: conversation ?? this.conversation,
        isStreaming: isStreaming ?? this.isStreaming,
        streamingText: streamingText ?? this.streamingText,
        error: error,
        isListening: isListening ?? this.isListening,
        voiceText: voiceText ?? this.voiceText,
      );
}

// ── Chat Notifier ─────────────────────────────────────────────────────────────

class ChatNotifier extends StateNotifier<ChatState> {
  ChatNotifier(this._ref, this._convId, this._model) : super(const ChatState()) {
    if (_convId != null) _load();
  }

  final Ref _ref;
  String? _convId;
  String _model;
  final _repo = ConversationRepository.instance;
  final _ai = OpenAIStreamService.instance;
  final _tts = TtsService.instance;
  final _stt = SttService.instance;
  final _uuid = const Uuid();

  // ── Load ──────────────────────────────────────────────────────────────────

  Future<void> _load() async {
    await _repo.loadAll();
    final conv = _repo.getById(_convId!);
    if (conv != null) state = state.copyWith(conversation: conv);
  }

  Future<Conversation> _ensureConversation() async {
    if (_convId == null) {
      final conv = await _repo.createConversation(model: _model);
      _convId = conv.id;
      _ref.read(activeConversationIdProvider.notifier).state = conv.id;
      state = state.copyWith(conversation: conv);
      return conv;
    }
    await _repo.loadAll();
    return _repo.getById(_convId!)!;
  }

  // ── Send Message ──────────────────────────────────────────────────────────

  Future<void> sendMessage(
    String text, {
    List<MessageAttachment> attachments = const [],
  }) async {
    if (text.trim().isEmpty && attachments.isEmpty) return;
    if (state.isStreaming) return;

    try {
      final conv = await _ensureConversation();

      // Build user message
      var userContent = text.trim();
      if (attachments.isNotEmpty) {
        final attachInfo = attachments.map((a) {
          if (a.extractedText != null) {
            return '\n\n[Attached: ${a.name}]\n${a.extractedText}';
          }
          return '\n\n[Attached file: ${a.name}]';
        }).join();
        userContent += attachInfo;
      }

      final userMsg = ChatMessage(
        id: _uuid.v4(),
        role: MessageRole.user,
        content: userContent,
        createdAt: DateTime.now(),
        attachments: attachments,
      );

      var updatedConv = await _repo.addMessage(conv.id, userMsg);
      state = state.copyWith(conversation: updatedConv, isStreaming: true, streamingText: '');
      _ref.read(conversationsProvider.notifier).updateFromChat(updatedConv);

      // Generate title from first user message
      if (updatedConv.messages.length == 1) {
        _ai.generateTitle(text).then((title) async {
          await _repo.updateTitle(conv.id, title);
          _ref.read(conversationsProvider.notifier).refresh();
        });
      }

      // Stream AI response
      final assistantId = _uuid.v4();
      final assistantMsg = ChatMessage(
        id: assistantId,
        role: MessageRole.assistant,
        content: '',
        createdAt: DateTime.now(),
        isStreaming: true,
        model: _model,
      );
      updatedConv = await _repo.addMessage(conv.id, assistantMsg);
      state = state.copyWith(conversation: updatedConv);

      final buffer = StringBuffer();
      await for (final token in _ai.streamCompletion(
        messages: updatedConv.messages
            .where((m) => !m.isStreaming)
            .toList()
          ..removeLast(), // remove the empty assistant placeholder
        model: _model,
      )) {
        buffer.write(token);
        state = state.copyWith(streamingText: buffer.toString());
      }

      // Finalize
      final finalMsg = assistantMsg.copyWith(
        content: buffer.toString(),
        isStreaming: false,
      );
      updatedConv = await _repo.updateLastMessage(conv.id, finalMsg);
      state = state.copyWith(
        conversation: updatedConv,
        isStreaming: false,
        streamingText: '',
      );
      _ref.read(conversationsProvider.notifier).updateFromChat(updatedConv);
    } catch (e, s) {
      AppLogger.error('Chat send error', e);
      state = state.copyWith(isStreaming: false, error: e.toString());
    }
  }

  // ── Model ──────────────────────────────────────────────────────────────────

  Future<void> changeModel(String model) async {
    _model = model;
    _ref.read(activeModelProvider.notifier).state = model;
    if (_convId != null) {
      await _repo.updateModel(_convId!, model);
    }
  }

  // ── Voice Input ───────────────────────────────────────────────────────────

  Future<void> startVoiceInput() async {
    final ok = await _stt.initialize();
    if (!ok) return;
    state = state.copyWith(isListening: true, voiceText: '');

    await _stt.startListening(
      onResult: (text) => state = state.copyWith(voiceText: text),
      onDone: () {
        final text = state.voiceText;
        state = state.copyWith(isListening: false, voiceText: '');
        if (text.isNotEmpty) sendMessage(text);
      },
    );
  }

  Future<void> stopVoiceInput() async {
    await _stt.stopListening();
    state = state.copyWith(isListening: false);
  }

  // ── Voice Output ──────────────────────────────────────────────────────────

  Future<void> speakMessage(String text) async {
    await _tts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  // ── New / Switch ──────────────────────────────────────────────────────────

  Future<void> newConversation() async {
    final conv = await _repo.createConversation(model: _model);
    _convId = conv.id;
    _ref.read(activeConversationIdProvider.notifier).state = conv.id;
    state = ChatState(conversation: conv);
    _ref.read(conversationsProvider.notifier).refresh();
  }

  Future<void> switchConversation(String convId) async {
    _convId = convId;
    _ref.read(activeConversationIdProvider.notifier).state = convId;
    state = const ChatState();
    await _load();
  }

  Future<void> deleteCurrentConversation() async {
    if (_convId == null) return;
    await _repo.delete(_convId!);
    _convId = null;
    _ref.read(activeConversationIdProvider.notifier).state = null;
    state = const ChatState();
    _ref.read(conversationsProvider.notifier).refresh();
  }
}
