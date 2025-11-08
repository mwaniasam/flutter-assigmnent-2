import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookswap_app/config/app_theme.dart';
import 'package:bookswap_app/models/swap.dart';
import 'package:bookswap_app/providers/swap_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MyOffersScreen extends StatefulWidget {
  const MyOffersScreen({super.key});

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load swap data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final swapProvider = Provider.of<SwapProvider>(context, listen: false);
      swapProvider.loadSentSwaps();
      swapProvider.loadReceivedSwaps();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Offers'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentGold,
          labelColor: AppTheme.accentGold,
          unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
          tabs: const [
            Tab(text: 'Sent'),
            Tab(text: 'Received'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSentSwapsTab(),
          _buildReceivedSwapsTab(),
        ],
      ),
    );
  }

  Widget _buildSentSwapsTab() {
    return Consumer<SwapProvider>(
      builder: (context, swapProvider, child) {
        final swaps = swapProvider.sentSwaps;

        if (swapProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (swaps.isEmpty) {
          return _buildEmptyState('No sent offers yet', 'Initiate swap offers with other users');
        }

        return RefreshIndicator(
          onRefresh: () async {
            swapProvider.loadSentSwaps();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: swaps.length,
            itemBuilder: (context, index) {
              final swap = swaps[index];
              return _buildSwapCard(swap, isSent: true);
            },
          ),
        );
      },
    );
  }

  Widget _buildReceivedSwapsTab() {
    return Consumer<SwapProvider>(
      builder: (context, swapProvider, child) {
        final swaps = swapProvider.receivedSwaps;

        if (swapProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (swaps.isEmpty) {
          return _buildEmptyState('No received offers yet', 'Other users can send you swap offers');
        }

        return RefreshIndicator(
          onRefresh: () async {
            swapProvider.loadReceivedSwaps();
          },
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: swaps.length,
            itemBuilder: (context, index) {
              final swap = swaps[index];
              return _buildSwapCard(swap, isSent: false);
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(String title, String subtitle) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.swap_horiz,
            size: 80,
            color: (isDark ? AppTheme.darkSubtext : AppTheme.subtleGray).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: AppTheme.heading2.copyWith(
              color: isDark ? AppTheme.darkSubtext : AppTheme.subtleGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: AppTheme.caption.copyWith(
              color: isDark ? AppTheme.darkSubtext : AppTheme.subtleGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSwapCard(SwapOffer swap, {required bool isSent}) {
    final otherUserName = isSent ? swap.receiverName : swap.senderName;
    final statusColor = _getStatusColor(swap.status);
    
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Info
            Row(
              children: [
                // Book Image
                if (swap.bookImageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CachedNetworkImage(
                      imageUrl: swap.bookImageUrl!,
                      width: 60,
                      height: 90,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 60,
                        height: 90,
                        color: Colors.grey[300],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 60,
                        height: 90,
                        color: Colors.grey[300],
                        child: const Icon(Icons.book),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.book, size: 30),
                  ),
                
                const SizedBox(width: 12),
                
                // Book Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        swap.bookTitle,
                        style: AppTheme.bodyText.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        swap.bookAuthor,
                        style: AppTheme.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            isSent ? Icons.arrow_forward : Icons.arrow_back,
                            size: 16,
                            color: AppTheme.subtleGray,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              isSent ? 'To: $otherUserName' : 'From: $otherUserName',
                              style: AppTheme.caption.copyWith(fontSize: 13),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Status and Time
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: statusColor, width: 1),
                ),
                  child: Text(
                    swap.status.displayName,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  swap.timeAgo,
                  style: AppTheme.caption.copyWith(fontSize: 12),
                ),
              ],
            ),
            
            // Message if exists
            if (swap.message != null && swap.message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  swap.message!,
                  style: AppTheme.caption,
                ),
              ),
            ],
            
            // Action Buttons
            if (_shouldShowActions(swap, isSent)) ...[
              const SizedBox(height: 12),
              _buildActionButtons(swap, isSent),
            ],
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(SwapStatus status) {
    switch (status) {
      case SwapStatus.pending:
        return Colors.orange;
      case SwapStatus.accepted:
        return AppTheme.successGreen;
      case SwapStatus.rejected:
        return AppTheme.errorRed;
      case SwapStatus.cancelled:
        return Colors.grey;
    }
  }

  bool _shouldShowActions(SwapOffer swap, bool isSent) {
    if (isSent) {
      return swap.status == SwapStatus.pending;
    } else {
      return swap.status == SwapStatus.pending;
    }
  }

  Widget _buildActionButtons(SwapOffer swap, bool isSent) {
    final swapProvider = Provider.of<SwapProvider>(context, listen: false);

    if (isSent) {
      // For sent swaps - only cancel button
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: () async {
            final confirm = await _showConfirmDialog(
              'Cancel Swap Offer?',
              'This action cannot be undone.',
            );
            
            if (confirm == true) {
              final success = await swapProvider.cancelSwap(swap.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Swap offer cancelled' : 'Failed to cancel offer'),
                    backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
                  ),
                );
              }
            }
          },
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancel Offer'),
          style: OutlinedButton.styleFrom(
            foregroundColor: AppTheme.errorRed,
            side: const BorderSide(color: AppTheme.errorRed),
          ),
        ),
      );
    } else {
      // For received swaps - accept and reject buttons
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () async {
                final confirm = await _showConfirmDialog(
                  'Reject Swap Offer?',
                  'The sender will be notified.',
                );
                
                if (confirm == true) {
                  final success = await swapProvider.rejectSwap(swap.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Swap offer rejected' : 'Failed to reject offer'),
                        backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.close),
              label: const Text('Reject'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorRed,
                side: const BorderSide(color: AppTheme.errorRed),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () async {
                final confirm = await _showConfirmDialog(
                  'Accept Swap Offer?',
                  'You agree to swap this book with ${swap.senderName}.',
                );
                
                if (confirm == true) {
                  final success = await swapProvider.acceptSwap(swap.id);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(success ? 'Swap offer accepted!' : 'Failed to accept offer'),
                        backgroundColor: success ? AppTheme.successGreen : AppTheme.errorRed,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Accept'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successGreen,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    }
  }

  Future<bool?> _showConfirmDialog(String title, String content) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}
