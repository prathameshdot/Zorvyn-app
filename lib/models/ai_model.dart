class ChatMessage {
  final String role; // user | assistant
  final String content;
  final String? timestamp;

  ChatMessage({required this.role, required this.content, this.timestamp});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      role: json['role'] ?? 'assistant',
      content: json['content'] ?? '',
      timestamp: json['timestamp']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {'role': role, 'content': content};

  bool get isUser => role == 'user';
}

class AiConversation {
  final String? id;
  final String? conversationId;
  final String? userId;
  final List<ChatMessage> messages;
  final String? createdAt;
  final String? updatedAt;

  AiConversation({
    this.id,
    this.conversationId,
    this.userId,
    this.messages = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory AiConversation.fromJson(Map<String, dynamic> json) {
    return AiConversation(
      id: json['id']?.toString(),
      conversationId: json['conversationId']?.toString() ?? json['conversation_id']?.toString(),
      userId: json['userId']?.toString(),
      messages: (json['messages'] ?? [])
          .map<ChatMessage>((e) => ChatMessage.fromJson(e))
          .toList(),
      createdAt: json['createdAt']?.toString() ?? json['created_at']?.toString(),
      updatedAt: json['updatedAt']?.toString() ?? json['updated_at']?.toString(),
    );
  }

  String get preview {
    if (messages.isEmpty) return 'No messages';
    final first = messages.firstWhere((m) => m.isUser, orElse: () => messages.first);
    final text = first.content;
    return text.length > 60 ? '${text.substring(0, 60)}...' : text;
  }
}
