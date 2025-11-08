import 'package:flutter/foundation.dart';
import 'package:bookswap_app/models/swap.dart';
import 'package:bookswap_app/services/firestore_service.dart';

class SwapProvider extends ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  
  List<SwapOffer> _swapOffers = [];
  List<SwapOffer> _sentSwaps = [];
  List<SwapOffer> _receivedSwaps = [];
  bool _isLoading = false;
  String? _error;

  List<SwapOffer> get swapOffers => _swapOffers;
  List<SwapOffer> get sentSwaps => _sentSwaps;
  List<SwapOffer> get receivedSwaps => _receivedSwaps;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get pendingReceivedCount => _receivedSwaps
      .where((swap) => swap.status == SwapStatus.pending)
      .length;

  void loadSwapOffers() {
    _firestoreService.getSwapOffersStream().listen((swaps) {
      _swapOffers = swaps;
      notifyListeners();
    });
  }

  void loadSentSwaps() {
    _firestoreService.getSentSwapsStream().listen((swaps) {
      _sentSwaps = swaps;
      notifyListeners();
    });
  }

  void loadReceivedSwaps() {
    _firestoreService.getReceivedSwapsStream().listen((swaps) {
      _receivedSwaps = swaps;
      notifyListeners();
    });
  }

  Future<bool> createSwapOffer({
    required String bookId,
    required String bookTitle,
    required String bookAuthor,
    String? bookImageUrl,
    required String receiverId,
    required String receiverName,
    String? message,
  }) async {
    try {
      _setLoading(true);
      _error = null;
      
      await _firestoreService.createSwapOffer(
        bookId: bookId,
        bookTitle: bookTitle,
        bookAuthor: bookAuthor,
        bookImageUrl: bookImageUrl,
        receiverId: receiverId,
        receiverName: receiverName,
        message: message,
      );
      
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> acceptSwap(String swapId) async {
    try {
      _setLoading(true);
      await _firestoreService.acceptSwapOffer(swapId);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> rejectSwap(String swapId) async {
    try {
      _setLoading(true);
      await _firestoreService.rejectSwapOffer(swapId);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> cancelSwap(String swapId) async {
    try {
      _setLoading(true);
      await _firestoreService.cancelSwapOffer(swapId);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      return false;
    }
  }

  Future<bool> deleteSwap(String swapId) async {
    try {
      _setLoading(true);
      await _firestoreService.deleteSwapOffer(swapId);
      _setLoading(false);
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
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
