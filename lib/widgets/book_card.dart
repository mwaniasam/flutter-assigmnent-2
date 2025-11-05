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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppTheme.darkText : AppTheme.primaryNavy,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? AppTheme.darkSubtext : AppTheme.subtleGray,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    _buildConditionBadge(isDark),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: isDark ? AppTheme.darkSubtext : AppTheme.subtleGray,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          book.timeAgo,
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? AppTheme.darkSubtext : AppTheme.subtleGray,
                          ),
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
                    color: book.isLiked 
                        ? Colors.red 
                        : (isDark ? AppTheme.darkSubtext : AppTheme.subtleGray),
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

  Widget _buildConditionBadge(bool isDark) {
    Color badgeColor;
    switch (book.condition) {
      case BookCondition.brandNew:
        badgeColor = isDark ? AppTheme.darkAccent : AppTheme.successGreen;
        break;
      case BookCondition.likeNew:
        badgeColor = isDark ? AppTheme.accentGold : AppTheme.accentGold;
        break;
      case BookCondition.good:
        badgeColor = Colors.blue;
        break;
      case BookCondition.used:
        badgeColor = isDark ? AppTheme.darkSubtext : AppTheme.subtleGray;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(isDark ? 0.3 : 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: badgeColor,
          width: 1.5,
        ),
      ),
      child: Text(
        book.condition.displayName,
        style: TextStyle(
          color: badgeColor,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
