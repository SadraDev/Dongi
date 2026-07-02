import 'package:flutter/material.dart';
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

  // Helper to show consistent loading dialogs
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }

  // Helper for consistent Success SnackBars
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  // Helper for consistent Error SnackBars
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  // Simple date formatter without needing the intl package
  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      const months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return "${months[date.month - 1]} ${date.day}";
    } catch (e) {
      return dateString.split('T')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
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
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.notifications_none_rounded,
                    size: 56,
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'All caught up!',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'You have no new notifications right now.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
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
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade300,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshNotifications,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationCard(dynamic item) {
    final String type = item['type'] ?? '';
    final Color iconColor = _getIconColor(type);
    final IconData icon = _getIcon(type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _handleNotificationTap(item),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Modern Icon Box
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
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
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDate(item['created_at']?.toString() ?? ''),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ),

                // Subtle action indicator
                if (type == 'friend_request' || type == 'group_invite')
                  Icon(
                    Icons.check_circle_outline_rounded,
                    size: 20,
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.6),
                  )
                else
                  Icon(
                    Icons.close_rounded,
                    size: 20,
                    color: Colors.grey.shade400,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleNotificationTap(dynamic item) async {
    final String type = item['type'];

    // --- Friend Request Logic ---
    if (type == 'friend_request') {
      _showLoadingDialog();
      try {
        await FriendService.acceptFriendRequest(item['related_id']);
        await NotificationService.markAsRead(item['id']);
        if (mounted) {
          Navigator.pop(context); // Close loading
          _showSuccessSnackBar('Friend request accepted!');
          _refreshNotifications();
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          _showErrorSnackBar('Error: $e');
        }
      }
    }
    // --- Group Invite Logic ---
    else if (type == 'group_invite') {
      _showLoadingDialog();
      try {
        await GroupService.acceptGroupInvite(item['related_id']);
        await NotificationService.markAsRead(item['id']);
        if (mounted) {
          Navigator.pop(context); // Close loading
          _showSuccessSnackBar('Joined group successfully!');
          _refreshNotifications();
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          _showErrorSnackBar('Error: $e');
        }
      }
    }
    // --- Payment Reminder Logic ---
    else if (type == 'payment_reminder') {
      try {
        await NotificationService.markAsRead(item['id']);
        if (mounted) {
          _refreshNotifications();
        }
      } catch (e) {
        if (mounted) {
          _showErrorSnackBar('Error: $e');
        }
      }
    }
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
