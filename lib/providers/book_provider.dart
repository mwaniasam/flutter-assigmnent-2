import 'package:flutter/foundation.dart';
import 'package:bookswap_app/models/book.dart';
import 'package:bookswap_app/services/firestore_service.dart';

class BookProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<Book> _books = [];
  List<Book> _myBooks = [];
  bool _isLoading = false;
  String? _error;

  List<Book> get books => _books;
  List<Book> get myBooks => _myBooks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Stream subscriptions would be managed here
  void loadBooks() {
    _firestoreService.getBooksStream().listen((books) {
      _books = books;
      notifyListeners();
    });
  }

  void loadMyBooks(String userId) {
    _firestoreService.getUserBooksStream(userId).listen((books) {
      _myBooks = books;
      notifyListeners();
    });
  }

  Future<bool> postBook(Book book) async {
    try {
      _setLoading(true);
      _error = null;
      
      await _firestoreService.postBook(book);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteBook(String bookId) async {
    try {
      _setLoading(true);
      _error = null;
      
      await _firestoreService.deleteBook(bookId);
      
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> toggleLike(String bookId, bool isLiked) async {
    try {
      await _firestoreService.toggleBookLike(bookId, isLiked);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
