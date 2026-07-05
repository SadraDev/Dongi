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
  late Future<List<dynamic>> _notificationsFuture;
  final Set<int> _processingIds = {};

  @override
  void initState() {
    super.initState();
    _refreshNotifications();
  }

  void _refreshNotifications() {
    setState(() {
      _notificationsFuture = NotificationService.fetchNotifications();
    });
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
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
            Icon(Icons.error_outline, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        elevation: 0,
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
        _showErrorSnackBar('Error: $e');
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
        _showErrorSnackBar('Error: $e');
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
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
      ),
      body: RefreshIndicator(
        color: Theme.of(context).primaryColor,
        onRefresh: () async => _refreshNotifications(),
        child: FutureBuilder<List<dynamic>>(
          future: _notificationsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            final items = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _buildNotificationCard(items[index]);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade800
                        : Colors.grey.shade100,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 52,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'All caught up!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have no new notifications right now.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade500
                        : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: Colors.red.shade300,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshNotifications,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
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
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isProcessing ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Colored Icon Box
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: isDark ? 0.15 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: iconColor.withValues(alpha: isDark ? 0.25 : 0.15),
                    ),
                  ),
                  child: Icon(icon, color: iconColor, size: 22),
                ),
                const SizedBox(width: 14),

                // Text Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['message'] ?? 'New notification',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          height: 1.3,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDate(item['created_at']?.toString() ?? ''),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Buttons
                if (isActionable) ...[
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.close_rounded,
                    color: Colors.red.shade400,
                    bgColor: isDark
                        ? Colors.red.shade900.withValues(alpha: 0.2)
                        : Colors.red.shade50,
                    borderColor: isDark
                        ? Colors.red.shade800.withValues(alpha: 0.3)
                        : Colors.red.shade200,
                    isLoading: isProcessing,
                    onTap: isProcessing ? null : () {
                      HapticFeedback.lightImpact();
                      _handleReject(item);
                    },
                  ),
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.check_rounded,
                    color: Colors.green.shade600,
                    bgColor: isDark
                        ? Colors.green.shade900.withValues(alpha: 0.2)
                        : Colors.green.shade50,
                    borderColor: isDark
                        ? Colors.green.shade800.withValues(alpha: 0.3)
                        : Colors.green.shade200,
                    isLoading: isProcessing,
                    onTap: isProcessing ? null : () {
                      HapticFeedback.lightImpact();
                      _handleAccept(item);
                    },
                  ),
                ] else ...[
                  const SizedBox(width: 8),
                  _ActionButton(
                    icon: Icons.close_rounded,
                    color: Colors.grey.shade400,
                    bgColor: isDark ? Colors.grey.shade700 : Colors.grey.shade100,
                    borderColor: isDark ? Colors.grey.shade600 : Colors.grey.shade300,
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
        return Colors.blue;
      case 'group_invite':
        return Colors.green.shade600;
      case 'payment_reminder':
        return Colors.orange.shade700;
      default:
        return Colors.grey;
    }
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bgColor;
  final Color borderColor;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.borderColor,
    required this.isLoading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor),
          ),
          child: isLoading
              ? Padding(
            padding: const EdgeInsets.all(10),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: color,
              ),
            ),
          )
              : Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}