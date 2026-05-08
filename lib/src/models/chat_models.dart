import 'recommended_app.dart';

enum MessageAuthor { user, assistant }

class ChatReply {
  const ChatReply({
    required this.sessionId,
    required this.message,
    required this.intent,
    required this.apps,
  });

  final String sessionId;
  final String message;
  final String intent;
  final List<RecommendedApp> apps;

  factory ChatReply.fromJson(Map<String, dynamic> json) {
    final rawApps = json['apps'];
    final items = rawApps is List ? rawApps : const <Object?>[];
    return ChatReply(
      sessionId: json['session_id']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      intent: json['intent']?.toString() ?? 'unknown',
      apps: items
          .whereType<Object?>()
          .map((Object? item) => item is Map<String, dynamic>
              ? item
              : item is Map
                  ? item.map((Object? key, Object? value) => MapEntry(key.toString(), value))
                  : const <String, dynamic>{})
          .map(RecommendedApp.fromJson)
          .toList(),
    );
  }
}

class ConversationMessage {
  ConversationMessage({
    required this.id,
    required this.author,
    required this.text,
    required this.createdAt,
    this.apps = const <RecommendedApp>[],
    this.isError = false,
  });

  final String id;
  final MessageAuthor author;
  final String text;
  final DateTime createdAt;
  final List<RecommendedApp> apps;
  final bool isError;

  factory ConversationMessage.user(String text) {
    return ConversationMessage(
      id: _messageId(),
      author: MessageAuthor.user,
      text: text,
      createdAt: DateTime.now(),
    );
  }

  factory ConversationMessage.assistant(
    String text, {
    List<RecommendedApp> apps = const <RecommendedApp>[],
    bool isError = false,
  }) {
    return ConversationMessage(
      id: _messageId(),
      author: MessageAuthor.assistant,
      text: text,
      createdAt: DateTime.now(),
      apps: apps,
      isError: isError,
    );
  }

  static String _messageId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}
