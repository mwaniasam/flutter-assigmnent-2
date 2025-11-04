import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookswap_app/config/app_theme.dart';
import 'package:bookswap_app/models/book.dart';
import 'package:bookswap_app/widgets/custom_text_field.dart';
import 'package:bookswap_app/screens/book_search_screen.dart';
import 'package:bookswap_app/services/google_books_service.dart';
import 'package:bookswap_app/services/firestore_service.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostBookScreen extends StatefulWidget {
  const PostBookScreen({super.key});

  @override
  State<PostBookScreen> createState() => _PostBookScreenState();
}

class _PostBookScreenState extends State<PostBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _swapForController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  
  BookCondition _selectedCondition = BookCondition.good;
  BookSearchResult? _selectedBook;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _swapForController.dispose();
    super.dispose();
  }

  Future<void> _searchBook() async {
    final result = await Navigator.push<BookSearchResult>(
      context,
      MaterialPageRoute(
        builder: (context) => const BookSearchScreen(),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedBook = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightGray,
      appBar: AppBar(
        title: const Text('Post a Book'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_selectedBook == null) ...[
              Card(
                child: InkWell(
                  onTap: _searchBook,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(
                          Icons.search,
                          size: 48,
                          color: AppTheme.accentGold,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Search for a Book',
                          style: AppTheme.heading2.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find the book you want to swap',
                          style: AppTheme.bodyText.copyWith(
                            color: AppTheme.subtleGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              _buildSelectedBookCard(),
              const SizedBox(height: 20),
              CustomTextField(
                label: 'Swap For (Optional)',
                hint: 'What book would you like in exchange?',
                controller: _swapForController,
              ),
              const SizedBox(height: 20),
              _buildConditionSelector(),
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleSubmit,
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryNavy),
                          ),
                        )
                      : const Text('Post Book'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedBookCard() {
    if (_selectedBook == null) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_selectedBook!.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: _selectedBook!.imageUrl!,
                      width: 80,
                      height: 120,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 80,
                        height: 120,
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 80,
                        height: 120,
                        color: Colors.grey[300],
                        child: const Icon(Icons.book),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.book, size: 40),
                  ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedBook!.title,
                        style: AppTheme.heading2.copyWith(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedBook!.authorNames,
                        style: AppTheme.bodyText.copyWith(
                          color: AppTheme.subtleGray,
                        ),
                      ),
                      if (_selectedBook!.publisher != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _selectedBook!.publisher!,
                          style: AppTheme.bodyText.copyWith(
                            color: AppTheme.subtleGray,
                            fontSize: 13,
                          ),
                        ),
                      ],
                      if (_selectedBook!.publishedDate != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Published: ${_selectedBook!.publishedDate}',
                          style: AppTheme.bodyText.copyWith(
                            color: AppTheme.subtleGray,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _searchBook,
              icon: const Icon(Icons.edit),
              label: const Text('Change Book'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Condition',
          style: AppTheme.bodyText.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: BookCondition.values.map((condition) {
            final isSelected = _selectedCondition == condition;
            return ChoiceChip(
              label: Text(condition.displayName),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedCondition = condition;
                });
              },
              selectedColor: AppTheme.accentGold,
              backgroundColor: AppTheme.cardBackground,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.primaryNavy : AppTheme.subtleGray,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _handleSubmit() async {
    if (_selectedBook == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a book first'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      try {
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('User not authenticated');
        }

        // Get user data
        final userData = await _firestoreService.getUserById(currentUser.uid);
        
        final book = Book(
          id: '', // Firestore will generate this
          title: _selectedBook!.title,
          author: _selectedBook!.authorNames,
          swapFor: _swapForController.text.isNotEmpty ? _swapForController.text : null,
          condition: _selectedCondition,
          ownerId: currentUser.uid,
          ownerName: userData?.displayName ?? currentUser.displayName ?? 'Anonymous',
          postedAt: DateTime.now(),
          imageUrl: _selectedBook!.imageUrl,
          isbn: _selectedBook!.isbn,
          publisher: _selectedBook!.publisher,
          publishedDate: _selectedBook!.publishedDate,
          description: _selectedBook!.description,
        );

        await _firestoreService.postBook(book);

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Book posted successfully!'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
        Navigator.pop(context, true);
      } catch (e) {
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error posting book: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isSubmitting = false;
          });
        }
      }
    }
  }
}
