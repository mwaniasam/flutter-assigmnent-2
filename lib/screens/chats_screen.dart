import 'package:flutter/material.dart';
import 'package:bookswap_app/config/app_theme.dart';
import 'package:bookswap_app/models/chat.dart';
import 'package:bookswap_app/screens/chat_detail_screen.dart';
import 'package:bookswap_app/services/firestore_service.dart';

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({super.key});

  @override
  State<ChatsScreen> createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Chats'),
      ),
      body: StreamBuilder<List<ChatConversation>>(
        stream: _firestoreService.getChatsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: AppTheme.errorRed),
                  const SizedBox(height: 16),
                  Text('Error: ${snapshot.error}'),
                ],
              ),
            );
          }

          final conversations = snapshot.data ?? [];

          if (conversations.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: conversations.length,
            itemBuilder: (context, index) {
              final conversation = conversations[index];
              return _buildChatTile(conversation);
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: isDark 
                ? AppTheme.darkSubtext.withValues(alpha: 0.5)
                : AppTheme.subtleGray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No conversations yet',
            style: AppTheme.heading2.copyWith(
              color: isDark ? AppTheme.darkSubtext : AppTheme.subtleGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start chatting to swap books!',
            style: AppTheme.caption.copyWith(
              color: isDark ? AppTheme.darkSubtext : AppTheme.subtleGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTile(ChatConversation conversation) {
    final lastMessage = conversation.lastMessage;
    final hasUnread = conversation.unreadCount > 0;
    final lastMessageText = lastMessage?.content ?? 'No messages yet';
    final lastMessageTime = lastMessage != null 
        ? conversation.lastMessageTime 
        : DateTime.now();

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                conversation: conversation,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // User avatar
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.accentGold,
                child: Text(
                  conversation.otherUserName.isNotEmpty 
                      ? conversation.otherUserName[0].toUpperCase()
                      : 'U',
                  style: const TextStyle(
                    color: AppTheme.primaryNavy,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          conversation.otherUserName,
                          style: AppTheme.bodyText.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (lastMessage != null)
                          Text(
                            _formatTime(lastMessageTime),
                            style: AppTheme.caption.copyWith(fontSize: 12),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            lastMessageText,
                            style: AppTheme.caption.copyWith(
                              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                              color: hasUnread ? AppTheme.primaryNavy : AppTheme.subtleGray,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentGold,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '${conversation.unreadCount}',
                              style: const TextStyle(
                                color: AppTheme.primaryNavy,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$hour:$minute';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}';
    }
  }
}
