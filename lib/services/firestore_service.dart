import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookswap_app/models/book.dart';
import 'package:bookswap_app/models/chat.dart';
import 'package:bookswap_app/models/user_model.dart';
import 'package:bookswap_app/models/swap.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ==================== USERS ====================
  
  Future<void> createUserDocument(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }

  Future<UserModel?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromJson(doc.data()!);
    }
    return null;
  }

  Stream<UserModel?> getCurrentUserStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(null);
    
    return _firestore.collection('users').doc(userId).snapshots().map(
      (doc) => doc.exists ? UserModel.fromJson(doc.data()!) : null,
    );
  }

  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (email != null) updates['email'] = email;
    if (photoUrl != null) updates['photoURL'] = photoUrl; // Match UserModel field name
    updates['updatedAt'] = FieldValue.serverTimestamp();

    await _firestore.collection('users').doc(userId).update(updates);
  }

  // ==================== BOOKS ====================
  
  Future<String> postBook(Book book) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final bookData = book.toJson();
    bookData['ownerId'] = userId;
    bookData['createdAt'] = FieldValue.serverTimestamp();
    bookData['updatedAt'] = FieldValue.serverTimestamp();

    final docRef = await _firestore.collection('books').add(bookData);
    return docRef.id;
  }

  Stream<List<Book>> getBooksStream() {
    final currentUserId = _auth.currentUser?.uid;
    
    return _firestore
        .collection('books')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['currentUserId'] = currentUserId; // Add current user ID for isLiked calculation
        return Book.fromJson(data);
      }).toList();
    });
  }

  Stream<List<Book>> getUserBooksStream(String userId) {
    final currentUserId = _auth.currentUser?.uid;
    
    return _firestore
        .collection('books')
        .where('ownerId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final books = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        data['currentUserId'] = currentUserId; // Add current user ID for isLiked calculation
        return Book.fromJson(data);
      }).toList();
      
      // Sort manually to avoid composite index requirement
      books.sort((a, b) => b.postedAt.compareTo(a.postedAt));
      return books;
    });
  }

  Future<List<Book>> searchBooks(String query) async {
    final snapshot = await _firestore
        .collection('books')
        .where('title', isGreaterThanOrEqualTo: query)
        .where('title', isLessThanOrEqualTo: '$query\uf8ff')
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return Book.fromJson(data);
    }).toList();
  }

  Future<void> deleteBook(String bookId) async {
    await _firestore.collection('books').doc(bookId).delete();
  }

  Future<void> toggleBookLike(String bookId, bool isLiked) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final bookRef = _firestore.collection('books').doc(bookId);
    
    if (isLiked) {
      await bookRef.update({
        'likedBy': FieldValue.arrayUnion([userId]),
      });
    } else {
      await bookRef.update({
        'likedBy': FieldValue.arrayRemove([userId]),
      });
    }
  }

  // ==================== CHATS ====================
  
  Future<String> createOrGetChatRoom(String otherUserId, String bookId) async {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) throw Exception('User not authenticated');

    // Create a consistent chat room ID
    final participants = [currentUserId, otherUserId]..sort();
    final chatRoomId = '${participants[0]}_${participants[1]}_$bookId';

    final chatRoomRef = _firestore.collection('chatRooms').doc(chatRoomId);
    
    try {
      // Try to create the chat room (will fail if it already exists)
      await chatRoomRef.set({
        'participants': participants,
        'bookId': bookId,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessage': '',
      }, SetOptions(merge: true)); // Use merge to avoid overwriting existing data
    } catch (e) {
      // Chat room might already exist, that's okay
      print('Chat room creation: $e');
    }

    return chatRoomId;
  }

  Stream<List<ChatConversation>> getChatsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('chatRooms')
        .where('participants', arrayContains: userId)
        .snapshots()
        .asyncMap((snapshot) async {
      List<ChatConversation> conversations = [];
      
      // Sort manually after fetching to avoid composite index requirement

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final participants = List<String>.from(data['participants']);
        final otherUserId = participants.firstWhere(
          (id) => id != userId,
          orElse: () => '',
        );
        
        // Skip if no other user found
        if (otherUserId.isEmpty) continue;

        // Get other user's data
        final otherUser = await getUserById(otherUserId);
        if (otherUser == null) continue;

        // Get last message
        ChatMessage? lastMessage;
        final messagesSnapshot = await _firestore
            .collection('chatRooms')
            .doc(doc.id)
            .collection('messages')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        if (messagesSnapshot.docs.isNotEmpty) {
          final messageData = messagesSnapshot.docs.first.data();
          lastMessage = ChatMessage(
            id: messagesSnapshot.docs.first.id,
            senderId: messageData['senderId'],
            content: messageData['content'],
            timestamp: (messageData['timestamp'] as Timestamp).toDate(),
            isRead: messageData['isRead'] ?? false,
          );
        }

        // Unread count temporarily disabled (requires Firestore composite index)
        // You can enable this by creating the index in Firebase Console

        conversations.add(ChatConversation(
          id: doc.id,
          chatRoomId: doc.id,
          otherUserId: otherUserId,
          otherUserName: otherUser.name,
          bookId: data['bookId'],
          lastMessage: lastMessage,
          lastMessageTime: lastMessage?.timestamp ?? 
              (data['lastMessageTime'] as Timestamp?)?.toDate() ?? 
              DateTime.now(),
          unreadCount: 0, // Disabled - requires composite index
        ));
      }

      // Sort by lastMessageTime manually
      conversations.sort((a, b) => b.lastMessageTime.compareTo(a.lastMessageTime));
      
      return conversations;
    });
  }

  Stream<List<ChatMessage>> getMessagesStream(String chatRoomId) {
    return _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        // Handle null timestamp (happens briefly when message is first created)
        final timestamp = data['timestamp'];
        final messageTime = timestamp != null 
            ? (timestamp as Timestamp).toDate() 
            : DateTime.now();
            
        return ChatMessage(
          id: doc.id,
          senderId: data['senderId'] ?? '',
          content: data['content'] ?? '',
          timestamp: messageTime,
          isRead: data['isRead'] ?? false,
        );
      }).toList();
    });
  }

  Future<void> sendMessage(String chatRoomId, String content) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final chatRoomRef = _firestore.collection('chatRooms').doc(chatRoomId);
    
    try {
      // Add message
      await chatRoomRef.collection('messages').add({
        'senderId': userId,
        'content': content,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
      });

      // Update last message in chat room (use set with merge to ensure it exists)
      await chatRoomRef.set({
        'lastMessage': content,
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error in sendMessage: $e');
      rethrow;
    }
  }

  Future<void> markMessagesAsRead(String chatRoomId, String otherUserId) async {
    final messagesRef = _firestore
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages');

    final unreadMessages = await messagesRef
        .where('senderId', isEqualTo: otherUserId)
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();
  }

  // ==================== SWAP OFFERS ====================

  // Create a new swap offer
  Future<String> createSwapOffer({
    required String bookId,
    required String bookTitle,
    required String bookAuthor,
    String? bookImageUrl,
    required String receiverId,
    required String receiverName,
    String? message,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final user = await getUserById(userId);
    if (user == null) throw Exception('User not found');

    final swap = SwapOffer(
      id: '', // Will be set by Firestore
      bookId: bookId,
      bookTitle: bookTitle,
      bookAuthor: bookAuthor,
      bookImageUrl: bookImageUrl,
      senderId: userId,
      senderName: user.displayName,
      receiverId: receiverId,
      receiverName: receiverName,
      status: SwapStatus.pending,
      createdAt: DateTime.now(),
      message: message,
    );

    final docRef = await _firestore.collection('swaps').add(swap.toFirestore());
    return docRef.id;
  }

  // Get all swap offers (sent and received)
  Stream<List<SwapOffer>> getSwapOffersStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('swaps')
        .where('senderId', isEqualTo: userId)
        .snapshots()
        .asyncMap((senderSnapshot) async {
      // Get swaps where user is sender
      final senderSwaps = senderSnapshot.docs
          .map((doc) => SwapOffer.fromFirestore(doc))
          .toList();

      // Get swaps where user is receiver
      final receiverSnapshot = await _firestore
          .collection('swaps')
          .where('receiverId', isEqualTo: userId)
          .get();

      final receiverSwaps = receiverSnapshot.docs
          .map((doc) => SwapOffer.fromFirestore(doc))
          .toList();

      // Combine and sort by date
      final allSwaps = [...senderSwaps, ...receiverSwaps];
      allSwaps.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return allSwaps;
    });
  }

  // Get swaps sent by current user
  Stream<List<SwapOffer>> getSentSwapsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('swaps')
        .where('senderId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final swaps = snapshot.docs.map((doc) => SwapOffer.fromFirestore(doc)).toList();
      // Sort manually to avoid composite index requirement
      swaps.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return swaps;
    });
  }

  // Get swaps received by current user
  Stream<List<SwapOffer>> getReceivedSwapsStream() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('swaps')
        .where('receiverId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final swaps = snapshot.docs.map((doc) => SwapOffer.fromFirestore(doc)).toList();
      // Sort manually to avoid composite index requirement
      swaps.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return swaps;
    });
  }

  // Update swap status
  Future<void> updateSwapStatus(String swapId, SwapStatus status) async {
    await _firestore.collection('swaps').doc(swapId).update({
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Accept swap offer
  Future<void> acceptSwapOffer(String swapId) async {
    await updateSwapStatus(swapId, SwapStatus.accepted);
    
    // Create chat room when swap is accepted
    final swapDoc = await _firestore.collection('swaps').doc(swapId).get();
    if (swapDoc.exists) {
      final swapData = swapDoc.data()!;
      final senderId = swapData['senderId'] as String;
      final receiverId = swapData['receiverId'] as String;
      final bookId = swapData['bookId'] as String;
      
      // Create chat room between sender and receiver
      await _createChatRoomForSwap(senderId, receiverId, bookId, swapId);
    }
  }

  // Create chat room for accepted swap
  Future<String> _createChatRoomForSwap(
    String user1Id,
    String user2Id,
    String bookId,
    String swapId,
  ) async {
    // Create a consistent chat room ID (same as createOrGetChatRoom)
    final participants = [user1Id, user2Id]..sort();
    final chatRoomId = '${participants[0]}_${participants[1]}_$bookId';
    
    // Use set with merge to create or update
    await _firestore.collection('chatRooms').doc(chatRoomId).set({
      'participants': participants,
      'bookId': bookId,
      'swapId': swapId,
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    
    return chatRoomId;
  }

  // Reject swap offer
  Future<void> rejectSwapOffer(String swapId) async {
    await updateSwapStatus(swapId, SwapStatus.rejected);
  }

  // Cancel swap offer (by sender)
  Future<void> cancelSwapOffer(String swapId) async {
    await updateSwapStatus(swapId, SwapStatus.cancelled);
  }

  // Delete swap offer
  Future<void> deleteSwapOffer(String swapId) async {
    await _firestore.collection('swaps').doc(swapId).delete();
  }

  // Get swap offers for a specific book
  Stream<List<SwapOffer>> getSwapsForBook(String bookId) {
    return _firestore
        .collection('swaps')
        .where('bookId', isEqualTo: bookId)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => SwapOffer.fromFirestore(doc)).toList());
  }
}
