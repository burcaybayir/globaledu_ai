import 'package:equatable/equatable.dart';
import 'package:globaledu_ai/features/ai_assistant/domain/entities/chat_message.dart';

class Conversation extends Equatable {
  const Conversation({
    required this.id,
    required this.title,
    required this.messages,
    required this.createdAt,
    required this.updatedAt,
    this.model = 'gpt-4o',
    this.isPinned = false,
    this.isArchived = false,
    this.totalTokens = 0,
  });

  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String model;
  final bool isPinned;
  final bool isArchived;
  final int totalTokens;

  Conversation copyWith({
    String? title,
    List<ChatMessage>? messages,
    DateTime? updatedAt,
    String? model,
    bool? isPinned,
    bool? isArchived,
    int? totalTokens,
  }) =>
      Conversation(
        id: id,
        title: title ?? this.title,
        messages: messages ?? this.messages,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        model: model ?? this.model,
        isPinned: isPinned ?? this.isPinned,
        isArchived: isArchived ?? this.isArchived,
        totalTokens: totalTokens ?? this.totalTokens,
      );

  String get preview =>
      messages.where((m) => m.role == MessageRole.assistant).lastOrNull?.content.take(80) ??
      'No messages yet';

  @override
  List<Object?> get props => [id, title, updatedAt, model];

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'messages': messages.map((m) => m.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'model': model,
        'isPinned': isPinned,
        'isArchived': isArchived,
        'totalTokens': totalTokens,
      };

  factory Conversation.fromJson(Map<String, dynamic> j) => Conversation(
        id: j['id'] as String,
        title: j['title'] as String,
        messages: (j['messages'] as List<dynamic>)
            .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
            .toList(),
        createdAt: DateTime.parse(j['createdAt'] as String),
        updatedAt: DateTime.parse(j['updatedAt'] as String),
        model: j['model'] as String? ?? 'gpt-4o',
        isPinned: j['isPinned'] as bool? ?? false,
        isArchived: j['isArchived'] as bool? ?? false,
        totalTokens: j['totalTokens'] as int? ?? 0,
      );
}

extension StringX on String {
  String take(int n) => length <= n ? this : '${substring(0, n)}...';
}
