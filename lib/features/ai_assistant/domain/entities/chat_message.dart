import 'package:equatable/equatable.dart';

enum MessageRole { user, assistant, system }

enum AttachmentType { image, pdf, document }

class MessageAttachment extends Equatable {
  const MessageAttachment({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    this.size,
    this.localPath,
    this.extractedText,
  });

  final String id;
  final String name;
  final AttachmentType type;
  final String url;
  final int? size;
  final String? localPath;
  final String? extractedText;

  @override
  List<Object?> get props => [id, name, type, url];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'url': url,
        'size': size,
        'localPath': localPath,
        'extractedText': extractedText,
      };

  factory MessageAttachment.fromJson(Map<String, dynamic> j) =>
      MessageAttachment(
        id: j['id'] as String,
        name: j['name'] as String,
        type: AttachmentType.values.firstWhere((e) => e.name == j['type']),
        url: j['url'] as String,
        size: j['size'] as int?,
        localPath: j['localPath'] as String?,
        extractedText: j['extractedText'] as String?,
      );
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.role,
    required this.content,
    required this.createdAt,
    this.attachments = const [],
    this.isStreaming = false,
    this.model,
    this.tokenCount,
    this.isSaved = false,
  });

  final String id;
  final MessageRole role;
  final String content;
  final DateTime createdAt;
  final List<MessageAttachment> attachments;
  final bool isStreaming;
  final String? model;
  final int? tokenCount;
  final bool isSaved;

  ChatMessage copyWith({
    String? content,
    bool? isStreaming,
    int? tokenCount,
    bool? isSaved,
  }) =>
      ChatMessage(
        id: id,
        role: role,
        content: content ?? this.content,
        createdAt: createdAt,
        attachments: attachments,
        isStreaming: isStreaming ?? this.isStreaming,
        model: model,
        tokenCount: tokenCount ?? this.tokenCount,
        isSaved: isSaved ?? this.isSaved,
      );

  @override
  List<Object?> get props => [id, role, content, createdAt, isStreaming];

  Map<String, dynamic> toJson() => {
        'id': id,
        'role': role.name,
        'content': content,
        'createdAt': createdAt.toIso8601String(),
        'attachments': attachments.map((a) => a.toJson()).toList(),
        'model': model,
        'tokenCount': tokenCount,
        'isSaved': isSaved,
      };

  factory ChatMessage.fromJson(Map<String, dynamic> j) => ChatMessage(
        id: j['id'] as String,
        role: MessageRole.values.firstWhere((e) => e.name == j['role']),
        content: j['content'] as String,
        createdAt: DateTime.parse(j['createdAt'] as String),
        attachments: (j['attachments'] as List<dynamic>? ?? [])
            .map((a) => MessageAttachment.fromJson(a as Map<String, dynamic>))
            .toList(),
        model: j['model'] as String?,
        tokenCount: j['tokenCount'] as int?,
        isSaved: j['isSaved'] as bool? ?? false,
      );

  /// Convert to OpenAI API format
  Map<String, dynamic> toApiMessage() => {
        'role': role.name,
        'content': content,
      };
}
