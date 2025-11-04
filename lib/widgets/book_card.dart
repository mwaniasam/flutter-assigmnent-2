import 'package:flutter/material.dart';
import 'package:bookswap_app/config/app_theme.dart';
import 'package:bookswap_app/models/book.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback? onTap;
  final VoidCallback? onLike;

  const BookCard({
    super.key,
    required this.book,
    this.onTap,
    this.onLike,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBookCover(),
              const SizedBox(width: 12),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: AppTheme.heading2.copyWith(fontSize: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: AppTheme.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildConditionBadge(),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: AppTheme.subtleGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          book.timeAgo,
                          style: AppTheme.caption.copyWith(fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              if (onLike != null)
                IconButton(
                  onPressed: onLike,
                  icon: Icon(
                    book.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: book.isLiked ? Colors.red : AppTheme.subtleGray,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookCover() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: book.imageUrl != null
          ? CachedNetworkImage(
              imageUrl: book.imageUrl!,
              width: 80,
              height: 100,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                width: 80,
                height: 100,
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                width: 80,
                height: 100,
                color: AppTheme.primaryNavy,
                child: const Icon(
                  Icons.menu_book,
                  color: AppTheme.accentGold,
                  size: 40,
                ),
              ),
            )
          : Container(
              width: 80,
              height: 100,
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.menu_book,
                color: AppTheme.accentGold,
                size: 40,
              ),
            ),
    );
  }

  Widget _buildConditionBadge() {
    Color badgeColor;
    switch (book.condition) {
      case BookCondition.brandNew:
        badgeColor = AppTheme.successGreen;
        break;
      case BookCondition.likeNew:
        badgeColor = AppTheme.accentGold;
        break;
      case BookCondition.good:
        badgeColor = Colors.blue;
        break;
      case BookCondition.used:
        badgeColor = AppTheme.subtleGray;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        book.condition.displayName,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
