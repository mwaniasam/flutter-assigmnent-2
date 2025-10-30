class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final bool isRead;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });

  String get timeString {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

class ChatConversation {
  final String id;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final List<ChatMessage> messages;
  final DateTime lastMessageTime;

  const ChatConversation({
    required this.id,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.messages,
    required this.lastMessageTime,
  });

  ChatMessage? get lastMessage => messages.isNotEmpty ? messages.last : null;
  
  int get unreadCount => messages.where((m) => !m.isRead && m.senderId == otherUserId).length;
}
