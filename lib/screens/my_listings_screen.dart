import 'package:flutter/material.dart';
import 'package:bookswap_app/config/app_theme.dart';
import 'package:bookswap_app/models/book.dart';
import 'package:bookswap_app/widgets/book_card.dart';
import 'package:bookswap_app/screens/post_book_screen.dart';

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  late List<Book> _myBooks;

  @override
  void initState() {
    super.initState();
    _myBooks = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('My Listings'),
      ),
      body: _myBooks.isEmpty ? _buildEmptyState() : _buildMyBooksList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const PostBookScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.accentGold,
        foregroundColor: AppTheme.primaryNavy,
        icon: const Icon(Icons.add),
        label: const Text('Post Book'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_add_outlined,
              size: 80,
              color: AppTheme.subtleGray.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No listings yet',
              style: AppTheme.heading2.copyWith(
                color: AppTheme.subtleGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Post your first book to start swapping!',
              style: AppTheme.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyBooksList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 80),
      itemCount: _myBooks.length,
      itemBuilder: (context, index) {
        final book = _myBooks[index];
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
          onDismissed: (direction) {
            setState(() {
              _myBooks.removeAt(index);
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('${book.title} deleted'),
                action: SnackBarAction(
                  label: 'Undo',
                  onPressed: () {
                    setState(() {
                      _myBooks.insert(index, book);
                    });
                  },
                ),
              ),
            );
          },
          child: BookCard(
            book: book,
            onTap: () {
              _showEditOptions(book);
            },
          ),
        );
      },
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
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility_outlined),
              title: const Text('View details'),
              onTap: () {
                Navigator.pop(context);
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
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
