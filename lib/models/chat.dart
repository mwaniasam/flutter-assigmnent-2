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
  final String chatRoomId;
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatar;
  final String bookId;
  final ChatMessage? lastMessage;
  final DateTime lastMessageTime;
  final int unreadCount;
  final List<ChatMessage> messages;

  const ChatConversation({
    required this.id,
    String? chatRoomId,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatar,
    required this.bookId,
    this.lastMessage,
    required this.lastMessageTime,
    this.unreadCount = 0,
    this.messages = const [],
  }) : chatRoomId = chatRoomId ?? id;
}
