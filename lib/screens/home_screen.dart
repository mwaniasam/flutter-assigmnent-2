import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookswap_app/config/app_theme.dart';
import 'package:bookswap_app/models/book.dart';
import 'package:bookswap_app/widgets/book_card.dart';
import 'package:bookswap_app/screens/post_book_screen.dart';
import 'package:bookswap_app/services/firestore_service.dart';
import 'package:bookswap_app/providers/auth_provider.dart';
import 'package:bookswap_app/providers/swap_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Browse Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              final result = await navigator.push(
                MaterialPageRoute(
                  builder: (context) => const PostBookScreen(),
                ),
              );
              
              if (result == true && mounted) {
                scaffoldMessenger.showSnackBar(
                  const SnackBar(
                    content: Text('Book posted successfully!'),
                    backgroundColor: AppTheme.successGreen,
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Book>>(
        stream: _firestoreService.getBooksStream(),
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
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => setState(() {}),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final books = snapshot.data ?? [];

          if (books.isEmpty) {
            return _buildEmptyState();
          }

          return RefreshIndicator(
            onRefresh: () async {
              setState(() {});
            },
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final book = books[index];
                return BookCard(
                  book: book,
                  onTap: () {
                    _showBookDetails(book);
                  },
                  onLike: () async {
                    await _firestoreService.toggleBookLike(
                      book.id,
                      !book.isLiked,
                    );
                  },
                );
              },
            ),
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
            Icons.library_books_outlined,
            size: 80,
            color: isDark 
                ? AppTheme.darkSubtext.withValues(alpha: 0.5)
                : AppTheme.subtleGray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No books available yet',
            style: AppTheme.heading2.copyWith(
              color: isDark ? AppTheme.darkSubtext : AppTheme.subtleGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to post a book!',
            style: AppTheme.caption.copyWith(
              color: isDark ? AppTheme.darkSubtext : AppTheme.subtleGray,
            ),
          ),
        ],
      ),
    );
  }

  void _showBookDetails(Book book) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final currentUserId = authProvider.user?.uid;
    final isOwnBook = currentUserId == book.ownerId;
    
    // Get owner info
    final owner = await _firestoreService.getUserById(book.ownerId);
    
    if (!mounted) return;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.title, style: AppTheme.heading2),
            const SizedBox(height: 8),
            Text('by ${book.author}', style: AppTheme.caption),
            const SizedBox(height: 16),
            if (owner != null) ...[
              Text('Owner:', style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(owner.name, style: AppTheme.bodyText),
              const SizedBox(height: 16),
            ],
            Text('Condition:', style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(book.condition.displayName, style: AppTheme.bodyText),
            const SizedBox(height: 16),
            if (book.swapFor != null) ...[
              Text('Owner wants:', style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(book.swapFor!, style: AppTheme.bodyText),
              const SizedBox(height: 16),
            ],
            if (!isOwnBook) ...[
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final navigator = Navigator.of(context);
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        
                        navigator.pop();
                        
                        // Create or get chat room
                        await _firestoreService.createOrGetChatRoom(
                          book.ownerId,
                          book.id,
                        );
                        
                        if (!mounted) return;
                        
                        scaffoldMessenger.showSnackBar(
                          const SnackBar(
                            content: Text('Chat started! Check your Chats tab.'),
                            backgroundColor: AppTheme.successGreen,
                          ),
                        );
                      },
                      icon: const Icon(Icons.chat_bubble_outline),
                      label: const Text('Chat'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.accentGold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _showSwapOfferDialog(book, owner?.name ?? 'Owner');
                      },
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Swap'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentGold,
                        foregroundColor: AppTheme.primaryNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSwapOfferDialog(Book book, String ownerName) {
    final messageController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Initiate Swap Offer'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Send a swap offer for "${book.title}" to $ownerName',
              style: AppTheme.bodyText,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                hintText: 'Add a message (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final swapProvider = Provider.of<SwapProvider>(context, listen: false);
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              
              navigator.pop();
              
              final success = await swapProvider.createSwapOffer(
                bookId: book.id,
                bookTitle: book.title,
                bookAuthor: book.author,
                bookImageUrl: book.imageUrl,
                receiverId: book.ownerId,
                receiverName: ownerName,
                message: messageController.text.isNotEmpty ? messageController.text : null,
              );
              
              if (!mounted) return;
              
              scaffoldMessenger.showSnackBar(
                SnackBar(
                  content: Text(
                    success 
                        ? 'Swap offer sent! Check My Offers tab.' 
                        : 'Failed to send swap offer',
                  ),
                  backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
                ),
              );
            },
            child: const Text('Send Offer'),
          ),
        ],
      ),
    );
  }
}
