import 'package:cloud_firestore/cloud_firestore.dart';

enum SwapStatus {
  pending,
  accepted,
  rejected,
  cancelled;

  String get displayName {
    switch (this) {
      case SwapStatus.pending:
        return 'Pending';
      case SwapStatus.accepted:
        return 'Accepted';
      case SwapStatus.rejected:
        return 'Rejected';
      case SwapStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class SwapOffer {
  final String id;
  final String bookId;
  final String bookTitle;
  final String bookAuthor;
  final String? bookImageUrl;
  final String senderId;
  final String senderName;
  final String receiverId;
  final String receiverName;
  final SwapStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? message;

  const SwapOffer({
    required this.id,
    required this.bookId,
    required this.bookTitle,
    required this.bookAuthor,
    this.bookImageUrl,
    required this.senderId,
    required this.senderName,
    required this.receiverId,
    required this.receiverName,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.message,
  });

  // Convert from Firestore
  factory SwapOffer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SwapOffer(
      id: doc.id,
      bookId: data['bookId'] ?? '',
      bookTitle: data['bookTitle'] ?? '',
      bookAuthor: data['bookAuthor'] ?? '',
      bookImageUrl: data['bookImageUrl'],
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      receiverId: data['receiverId'] ?? '',
      receiverName: data['receiverName'] ?? '',
      status: SwapStatus.values.firstWhere(
        (e) => e.name == data['status'],
        orElse: () => SwapStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      message: data['message'],
    );
  }

  // Convert to Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'bookId': bookId,
      'bookTitle': bookTitle,
      'bookAuthor': bookAuthor,
      'bookImageUrl': bookImageUrl,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'receiverName': receiverName,
      'status': status.name,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'message': message,
    };
  }

  SwapOffer copyWith({
    String? id,
    String? bookId,
    String? bookTitle,
    String? bookAuthor,
    String? bookImageUrl,
    String? senderId,
    String? senderName,
    String? receiverId,
    String? receiverName,
    SwapStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? message,
  }) {
    return SwapOffer(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      bookTitle: bookTitle ?? this.bookTitle,
      bookAuthor: bookAuthor ?? this.bookAuthor,
      bookImageUrl: bookImageUrl ?? this.bookImageUrl,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      receiverId: receiverId ?? this.receiverId,
      receiverName: receiverName ?? this.receiverName,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      message: message ?? this.message,
    );
  }

  String get timeAgo {
    final difference = DateTime.now().difference(createdAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} min${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
