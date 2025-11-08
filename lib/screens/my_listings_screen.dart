import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookswap_app/config/app_theme.dart';
import 'package:bookswap_app/models/book.dart';
import 'package:bookswap_app/widgets/book_card.dart';
import 'package:bookswap_app/screens/post_book_screen.dart';
import 'package:bookswap_app/screens/edit_book_screen.dart';
import 'package:bookswap_app/services/firestore_service.dart';
import 'package:bookswap_app/providers/auth_provider.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userId = authProvider.user?.uid;
    
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Listings'),
      ),
      body: userId == null 
          ? _buildErrorState('Please sign in to view your listings')
          : StreamBuilder<List<Book>>(
              stream: _firestoreService.getUserBooksStream(userId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return _buildErrorState('Error: ${snapshot.error}');
                }

                final books = snapshot.data ?? [];

                if (books.isEmpty) {
                  return _buildEmptyState();
                }

                return _buildMyBooksList(books);
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
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
        backgroundColor: AppTheme.accentGold,
        foregroundColor: AppTheme.primaryNavy,
        icon: const Icon(Icons.add),
        label: const Text('Post Book'),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 60,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_add_outlined,
              size: 80,
              color: (isDark ? AppTheme.darkSubtext : AppTheme.subtleGray).withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No listings yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppTheme.darkSubtext : AppTheme.subtleGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Post your first book to start swapping!',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppTheme.darkSubtext : AppTheme.subtleGray,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyBooksList(List<Book> books) {
    return RefreshIndicator(
      onRefresh: () async {
        setState(() {});
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8, bottom: 80),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return Dismissible(
            key: Key(book.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.errorRed,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: Colors.white,
                size: 28,
              ),
            ),
            confirmDismiss: (direction) async {
              return await _confirmDelete(context);
            },
            onDismissed: (direction) async {
              try {
                await _firestoreService.deleteBook(book.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${book.title} deleted'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error deleting book: $e'),
                      backgroundColor: AppTheme.errorRed,
                    ),
                  );
                }
              }
            },
            child: BookCard(
              book: book,
              onTap: () {
                _showEditOptions(book);
              },
            ),
          );
        },
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete listing?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showEditOptions(Book book) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Edit listing'),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditBookScreen(book: book),
                  ),
                );
                
                if (result == true && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Book updated successfully!'),
                      backgroundColor: AppTheme.successGreen,
                    ),
                  );
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility_outlined),
              title: const Text('View details'),
              onTap: () {
                Navigator.pop(context);
                _showBookDetails(book);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: AppTheme.errorRed,
              ),
              title: const Text(
                'Delete listing',
                style: TextStyle(color: AppTheme.errorRed),
              ),
              onTap: () async {
                Navigator.pop(context);
                final confirm = await _confirmDelete(context);
                if (confirm) {
                  try {
                    await _firestoreService.deleteBook(book.id);
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${book.title} deleted'),
                          backgroundColor: AppTheme.successGreen,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error deleting book: $e'),
                          backgroundColor: AppTheme.errorRed,
                        ),
                      );
                    }
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBookDetails(Book book) {
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
            Text('Condition:', style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(book.condition.displayName, style: AppTheme.bodyText),
            const SizedBox(height: 16),
            if (book.swapFor != null) ...[
              Text('Want to swap for:', style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(book.swapFor!, style: AppTheme.bodyText),
              const SizedBox(height: 16),
            ],
            if (book.description != null) ...[
              Text('Description:', style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(book.description!, style: AppTheme.bodyText),
              const SizedBox(height: 16),
            ],
            Text('Posted: ${book.timeAgo}', style: AppTheme.caption),
          ],
        ),
      ),
    );
  }
}
