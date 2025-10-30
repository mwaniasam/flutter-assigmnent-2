class Book {
  final String id;
  final String title;
  final String author;
  final String? swapFor; // What the owner wants in exchange
  final BookCondition condition;
  final String ownerId;
  final String ownerName;
  final DateTime postedAt;
  final String? imageUrl;
  final bool isLiked;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    this.swapFor,
    required this.condition,
    required this.ownerId,
    required this.ownerName,
    required this.postedAt,
    this.imageUrl,
    this.isLiked = false,
  });

  String get timeAgo {
    final difference = DateTime.now().difference(postedAt);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? swapFor,
    BookCondition? condition,
    String? ownerId,
    String? ownerName,
    DateTime? postedAt,
    String? imageUrl,
    bool? isLiked,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      swapFor: swapFor ?? this.swapFor,
      condition: condition ?? this.condition,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      postedAt: postedAt ?? this.postedAt,
      imageUrl: imageUrl ?? this.imageUrl,
      isLiked: isLiked ?? this.isLiked,
    );
  }
}

enum BookCondition {
  brandNew('New'),
  likeNew('Like New'),
  good('Good'),
  used('Used');

  final String displayName;
  const BookCondition(this.displayName);
}
