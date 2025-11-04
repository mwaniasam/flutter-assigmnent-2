class Book {
  final String id;
  final String title;
  final String author;
  final String? swapFor;
  final BookCondition condition;
  final String ownerId;
  final String ownerName;
  final DateTime postedAt;
  final String? imageUrl;
  final bool isLiked;
  final String? isbn;
  final String? publisher;
  final String? publishedDate;
  final String? description;

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
    this.isbn,
    this.publisher,
    this.publishedDate,
    this.description,
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
    String? isbn,
    String? publisher,
    String? publishedDate,
    String? description,
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
      isbn: isbn ?? this.isbn,
      publisher: publisher ?? this.publisher,
      publishedDate: publishedDate ?? this.publishedDate,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'swapFor': swapFor,
      'condition': condition.name,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'postedAt': postedAt.toIso8601String(),
      'imageUrl': imageUrl,
      'isbn': isbn,
      'publisher': publisher,
      'publishedDate': publishedDate,
      'description': description,
      'likedBy': isLiked ? [ownerId] : [],
    };
  }

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      author: json['author'] ?? '',
      swapFor: json['swapFor'],
      condition: BookCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => BookCondition.used,
      ),
      ownerId: json['ownerId'] ?? '',
      ownerName: json['ownerName'] ?? '',
      postedAt: json['postedAt'] is String
          ? DateTime.parse(json['postedAt'])
          : DateTime.now(),
      imageUrl: json['imageUrl'],
      isLiked: (json['likedBy'] as List?)?.contains(json['currentUserId'] ?? '') ?? false,
      isbn: json['isbn'],
      publisher: json['publisher'],
      publishedDate: json['publishedDate'],
      description: json['description'],
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
