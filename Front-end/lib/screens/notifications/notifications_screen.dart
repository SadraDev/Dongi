import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/friend_service.dart';
import '../../services/group_service.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _notifications = [];

  final Set<int> _processingIds = {};

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await NotificationService.fetchNotifications();
      if (mounted) {
        setState(() {
          _notifications = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshNotifications() async {
    // Hidden refresh without triggering the full loading state
    try {
      final items = await NotificationService.fetchNotifications();
      if (mounted) {
        setState(() {
          _notifications = items;
        });
      }
    } catch (e) {
      debugPrint('Refresh failed: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';

      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return "${months[date.month - 1]} ${date.day}";
    } catch (e) {
      return dateString.split('T')[0];
    }
  }

  Future<void> _handleAccept(dynamic item) async {
    final int id = item['id'];
    final String type = item['type'];

    setState(() => _processingIds.add(id));

    try {
      if (type == 'friend_request') {
        await FriendService.acceptFriendRequest(item['related_id']);
      } else if (type == 'group_invite') {
        await GroupService.acceptGroupInvite(item['related_id']);
      }
      await NotificationService.markAsRead(id);
      if (mounted) {
        setState(() => _processingIds.remove(id));
        _showSuccessSnackBar(
          type == 'friend_request'
              ? 'Friend request accepted!'
              : 'Joined group successfully!',
        );
        _refreshNotifications();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _processingIds.remove(id));
        final errorMsg = e.toString().replaceFirst('Exception: ', '');
        if (errorMsg == 'group is deleted') {
          _showErrorSnackBar('This group has been deleted by the owner.');
        } else {
          _showErrorSnackBar(errorMsg);
        }
        _refreshNotifications();
      }
    }
  }

  Future<void> _handleReject(dynamic item) async {
    final int id = item['id'];
    final String type = item['type'];

    setState(() => _processingIds.add(id));

    try {
      if (type == 'friend_request') {
        await FriendService.rejectFriendRequest(item['related_id']);
      } else if (type == 'group_invite') {
        await GroupService.rejectGroupInvite(item['related_id']);
      }
      await NotificationService.markAsRead(id);
      if (mounted) {
        setState(() => _processingIds.remove(id));
        _showSuccessSnackBar(
          type == 'friend_request'
              ? 'Friend request rejected.'
              : 'Group invite declined.',
        );
        _refreshNotifications();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _processingIds.remove(id));
        final errorMsg = e.toString().replaceFirst('Exception: ', '');
        if (errorMsg == 'group is deleted') {
          _showErrorSnackBar('This group has been deleted by the owner.');
        } else {
          _showErrorSnackBar(errorMsg);
        }
        _refreshNotifications();
      }
    }
  }

  Future<void> _handleDismiss(dynamic item) async {
    final int id = item['id'];
    setState(() => _processingIds.add(id));
    try {
      await NotificationService.markAsRead(id);
      if (mounted) {
        setState(() => _processingIds.remove(id));
        _refreshNotifications();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _processingIds.remove(id));
        _showErrorSnackBar('Error: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : RefreshIndicator(
        color: Theme.of(context).primaryColor,
        onRefresh: _refreshNotifications,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            _buildSliverAppBar(),
            _buildBodyContent(),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar.large(
      pinned: true,
      stretch: true,
      expandedHeight: 140,
      backgroundColor: Theme.of(context).colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.1),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_notifications.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyState(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            return _buildNotificationCard(_notifications[index]);
          },
          childCount: _notifications.length,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 56,
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'All caught up!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no new notifications right now.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Something went wrong.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _fetchNotifications,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(dynamic item) {
    final String type = item['type'] ?? '';
    final int id = item['id'];
    final bool isProcessing = _processingIds.contains(id);
    final Color iconColor = _getIconColor(type);
    final IconData icon = _getIcon(type);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool isActionable = type == 'friend_request' || type == 'group_invite';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isProcessing ? 0.5 : 1.0,
        child: Card(
          elevation: 0,
          color: Theme.of(context).colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Colored Icon Box
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 16),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['message'] ?? 'New notification',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(item['created_at']?.toString() ?? ''),
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                if (isActionable) ...[
                  const SizedBox(width: 12),
                  _ActionButton(
                    icon: Icons.close_rounded,
                    color: Theme.of(context).colorScheme.error,
                    bgColor: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.5),
                    isLoading: isProcessing,
                    onTap: isProcessing ? null : () {
                      HapticFeedback.lightImpact();
                      _handleReject(item);
                    },
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.check_rounded,
                    color: Colors.green.shade700,
                    bgColor: Colors.green.withValues(alpha: isDark ? 0.2 : 0.15),
                    isLoading: isProcessing,
                    onTap: isProcessing ? null : () {
                      HapticFeedback.lightImpact();
                      _handleAccept(item);
                    },
                  ),
                ] else ...[
                  const SizedBox(width: 12),
                  _ActionButton(
                    icon: Icons.close_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    bgColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    isLoading: isProcessing,
                    onTap: isProcessing ? null : () {
                      HapticFeedback.lightImpact();
                      _handleDismiss(item);
                    },
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'friend_request':
        return Icons.person_add_rounded;
      case 'group_invite':
        return Icons.group_add_rounded;
      case 'payment_reminder':
        return Icons.notifications_active_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'friend_request':
        return Colors.blue.shade600;
      case 'group_invite':
        return Colors.green.shade600;
      case 'payment_reminder':
        return Colors.orange.shade600;
      default:
        return Colors.grey.shade600;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
          ),
          child: isLoading
              ? Padding(
            padding: const EdgeInsets.all(12),
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: color,
            ),
          )
              : Icon(icon, size: 20, color: color),
        ),
      ),
    );
  }
}