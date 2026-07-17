import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:globaledu_ai/core/utils/logger.dart';
import 'package:globaledu_ai/features/ai_assistant/domain/entities/conversation.dart';
import 'package:globaledu_ai/features/ai_assistant/domain/entities/chat_message.dart';
import 'package:uuid/uuid.dart';

class ConversationRepository {
  ConversationRepository._();
  static final instance = ConversationRepository._();

  static const _kKey = 'globaledu_conversations';
  List<Conversation> _cache = [];
  bool _loaded = false;

  // ── Load / Save ────────────────────────────────────────────────────────────

  Future<List<Conversation>> loadAll() async {
    if (_loaded) return _cache;
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_kKey);
      if (json == null) {
        _cache = [];
      } else {
        final list = jsonDecode(json) as List<dynamic>;
        _cache = list
            .map((e) => Conversation.fromJson(e as Map<String, dynamic>))
            .toList()
          ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      }
      _loaded = true;
    } catch (e) {
      AppLogger.error('Failed to load conversations', e);
      _cache = [];
      _loaded = true;
    }
    return _cache;
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(_cache.map((c) => c.toJson()).toList());
      await prefs.setString(_kKey, json);
    } catch (e) {
      AppLogger.error('Failed to save conversations', e);
    }
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<Conversation> createConversation({String model = 'gpt-4o-mini'}) async {
    await loadAll();
    final conv = Conversation(
      id: const Uuid().v4(),
      title: 'New Conversation',
      messages: [],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      model: model,
    );
    _cache.insert(0, conv);
    await _persist();
    return conv;
  }

  Future<Conversation> addMessage(String convId, ChatMessage message) async {
    await loadAll();
    final idx = _cache.indexWhere((c) => c.id == convId);
    if (idx == -1) throw StateError('Conversation $convId not found');

    final updated = _cache[idx].copyWith(
      messages: [..._cache[idx].messages, message],
      updatedAt: DateTime.now(),
    );
    _cache[idx] = updated;
    // keep sorted by updatedAt
    _cache.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    await _persist();
    return updated;
  }

  Future<Conversation> updateLastMessage(String convId, ChatMessage message) async {
    await loadAll();
    final idx = _cache.indexWhere((c) => c.id == convId);
    if (idx == -1) throw StateError('Conversation $convId not found');

    final msgs = List<ChatMessage>.from(_cache[idx].messages);
    if (msgs.isNotEmpty && msgs.last.id == message.id) {
      msgs[msgs.length - 1] = message;
    } else {
      msgs.add(message);
    }

    final updated = _cache[idx].copyWith(
      messages: msgs,
      updatedAt: DateTime.now(),
    );
    _cache[idx] = updated;
    await _persist();
    return updated;
  }

  Future<void> updateTitle(String convId, String title) async {
    await loadAll();
    final idx = _cache.indexWhere((c) => c.id == convId);
    if (idx == -1) return;
    _cache[idx] = _cache[idx].copyWith(title: title);
    await _persist();
  }

  Future<void> updateModel(String convId, String model) async {
    await loadAll();
    final idx = _cache.indexWhere((c) => c.id == convId);
    if (idx == -1) return;
    _cache[idx] = _cache[idx].copyWith(model: model);
    await _persist();
  }

  Future<void> togglePin(String convId) async {
    await loadAll();
    final idx = _cache.indexWhere((c) => c.id == convId);
    if (idx == -1) return;
    _cache[idx] = _cache[idx].copyWith(isPinned: !_cache[idx].isPinned);
    await _persist();
  }

  Future<void> delete(String convId) async {
    await loadAll();
    _cache.removeWhere((c) => c.id == convId);
    await _persist();
  }

  Future<void> deleteAll() async {
    _cache = [];
    await _persist();
  }

  List<Conversation> search(String query) {
    if (query.isEmpty) return _cache;
    final q = query.toLowerCase();
    return _cache.where((c) {
      if (c.title.toLowerCase().contains(q)) return true;
      return c.messages.any((m) => m.content.toLowerCase().contains(q));
    }).toList();
  }

  Conversation? getById(String id) =>
      _cache.where((c) => c.id == id).firstOrNull;
}
