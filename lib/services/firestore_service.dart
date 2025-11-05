import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bookswap_app/models/book.dart';
import 'package:bookswap_app/models/chat.dart';
import 'package:bookswap_app/models/user_model.dart';

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
    return _firestore
        .collection('books')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return Book.fromJson(data);
      }).toList();
    });
  }

  Stream<List<Book>> getUserBooksStream(String userId) {
    return _firestore
        .collection('books')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      final books = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
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
    final chatRoomDoc = await chatRoomRef.get();

    if (!chatRoomDoc.exists) {
      // Create new chat room
      await chatRoomRef.set({
        'participants': participants,
        'bookId': bookId,
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessage': null,
      });
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

        // Count unread messages
        final unreadSnapshot = await _firestore
            .collection('chatRooms')
            .doc(doc.id)
            .collection('messages')
            .where('senderId', isNotEqualTo: userId)
            .where('isRead', isEqualTo: false)
            .get();

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
          unreadCount: unreadSnapshot.docs.length,
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
        return ChatMessage(
          id: doc.id,
          senderId: data['senderId'],
          content: data['content'],
          timestamp: (data['timestamp'] as Timestamp).toDate(),
          isRead: data['isRead'] ?? false,
        );
      }).toList();
    });
  }

  Future<void> sendMessage(String chatRoomId, String content) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final chatRoomRef = _firestore.collection('chatRooms').doc(chatRoomId);
    
    // Add message
    await chatRoomRef.collection('messages').add({
      'senderId': userId,
      'content': content,
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });

    // Update last message in chat room
    await chatRoomRef.update({
      'lastMessage': content,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
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
}
