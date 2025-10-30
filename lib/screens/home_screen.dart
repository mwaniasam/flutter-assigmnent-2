import 'package:flutter/material.dart';
import 'package:bookswap_app/config/app_theme.dart';
import 'package:bookswap_app/models/book.dart';
import 'package:bookswap_app/widgets/book_card.dart';
import 'package:bookswap_app/screens/post_book_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Book> _books;

  @override
  void initState() {
    super.initState();
    _books = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('Browse Listings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PostBookScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: _books.isEmpty ? _buildEmptyState() : _buildBookList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.library_books_outlined,
            size: 80,
            color: AppTheme.subtleGray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No books available yet',
            style: AppTheme.heading2.copyWith(
              color: AppTheme.subtleGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to post a book!',
            style: AppTheme.caption,
          ),
        ],
      ),
    );
  }

  Widget _buildBookList() {
    return RefreshIndicator(
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
        setState(() {
          _books = [];
        });
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: _books.length,
        itemBuilder: (context, index) {
          final book = _books[index];
          return BookCard(
            book: book,
            onTap: () {
              _showBookDetails(book);
            },
            onLike: () {
              setState(() {
                _books[index] = book.copyWith(isLiked: !book.isLiked);
              });
            },
          );
        },
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
            if (book.swapFor != null) ...[
              Text('Owner wants:', style: AppTheme.bodyText.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(book.swapFor!, style: AppTheme.bodyText),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // Would navigate to chat
                },
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Start Chat'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
