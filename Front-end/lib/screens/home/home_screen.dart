import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/group_model.dart';
import '../../services/group_service.dart';
import '../../services/friend_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/cumulative_balance_card.dart';
import '../friends/friends_screen.dart';
import '../friends/friend_detail_screen.dart';
import '../group/group_screen.dart';
import '../group/create_group_screen.dart';
import '../../services/auth_service.dart';
import '../auth/auth_screen.dart';
import '../notifications/notifications_screen.dart';
import '../settings/settings_screen.dart';
import '../../app_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  List<Group> _groups = [];
  List<dynamic> _friends = [];
  int _unreadCount = 0;
  int _currentUserId = 0;
  String? _currentUsername = '';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Load everything concurrently for better performance
      final results = await Future.wait([
        GroupService.fetchGroups(),
        NotificationService.getUnreadCount(),
        AuthService.getCurrentUserId(),
        AuthService.getCurrentUserName(),
        FriendService.getFriends(),
      ]);

      if (mounted) {
        setState(() {
          _groups = results[0] as List<Group>;
          _unreadCount = results[1] as int;
          _currentUserId = results[2] as int;
          _currentUsername = results[3] as String?;
          _friends = results[4] as List<dynamic>;
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

  Future<void> _refreshData() async {
    // Hidden refresh without full loading screen takeover
    try {
      final results = await Future.wait([
        GroupService.fetchGroups(),
        NotificationService.getUnreadCount(),
        FriendService.getFriends(),
      ]);
      if (mounted) {
        setState(() {
          _groups = results[0] as List<Group>;
          _unreadCount = results[1] as int;
          _friends = results[2] as List<dynamic>;
        });
      }
    } catch (e) {
      debugPrint('Refresh failed: $e');
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
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
        onRefresh: _refreshData,
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          HapticFeedback.lightImpact();
          final result = await Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
              const CreateGroupScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
              fullscreenDialog: true,
            ),
          );
          if (result == true) _refreshData();
        },
        icon: const Icon(Icons.group_add_rounded),
        label: const Text(
          'New Group',
          style: TextStyle(fontWeight: FontWeight.w600),
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
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${_getGreeting()},',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                letterSpacing: 0,
              ),
            ),
            Text(
              _currentUsername ?? 'User',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: Theme.of(context).colorScheme.onSurface,
                letterSpacing: -0.5,
              ),
            ),
          ],
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
      actions: [
        IconButton(
          icon: const Icon(Icons.people_alt_rounded),
          tooltip: 'Friends',
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                const FriendsScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            ).then((_) => _refreshData()); // Refresh balances when returning
          },
        ),
        Badge(
          isLabelVisible: _unreadCount > 0,
          label: Text('$_unreadCount'),
          offset: const Offset(-4, 4),
          child: IconButton(
            icon: const Icon(Icons.notifications_rounded),
            tooltip: 'Notifications',
            onPressed: () async {
              HapticFeedback.lightImpact();
              await Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                  const NotificationsScreen(),
                  transitionsBuilder:
                      (context, animation, secondaryAnimation, child) {
                    return FadeTransition(opacity: animation, child: child);
                  },
                  transitionDuration: const Duration(milliseconds: 300),
                ),
              );
              final count = await NotificationService.getUnreadCount();
              if (mounted) setState(() => _unreadCount = count);
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.settings_rounded),
          tooltip: 'Settings',
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                const SettingsScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            ).then((_) => setState(() {}));
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBodyContent() {
    // 1. Calculate Group Totals
    double groupOwed = 0;
    double groupOwe = 0;
    for (final group in _groups) {
      groupOwed += group.totalOwed;
      groupOwe += group.totalOwe;
    }

    // Combine sections for the SliverList
    final List<Widget> listItems = [];

    // Header & Cumulative Card
    listItems.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CumulativeBalanceCard(
            totalOwed: groupOwed,
            totalOwe: groupOwe,
          ),
          if (_friends.isNotEmpty && showFriendsNotifier.value)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 24, bottom: 12),
              child: Text(
                'Your Friends',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );

    // Friend Cards (Only add if toggle is ON)
    if (showFriendsNotifier.value) {
      for (final friend in _friends) {
        listItems.add(_buildFriendCard(friend));
      }
    }

    // Groups Header (Only add if toggle is ON)
    if (showGroupsNotifier.value) {
      listItems.add(
        Padding(
          padding: EdgeInsets.only(left: 4, top: (_friends.isEmpty || !showFriendsNotifier.value) ? 24 : 12, bottom: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Groups',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                _getFormattedDate(),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );

      // Group Cards or Empty State
      if (_groups.isEmpty) {
        listItems.add(
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: _buildEmptyState(),
          ),
        );
      } else {
        for (final group in _groups) {
          listItems.add(_buildGroupCard(group));
        }
      }
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) => listItems[index],
          childCount: listItems.length,
        ),
      ),
    );
  }

  Widget _buildFriendCard(dynamic friend) {
    final String name = friend['username'] ?? 'Unknown';
    final int friendId = friend['id'];
    final double balance = (friend['balance'] ?? 0).toDouble();

    final bool isZero = balance == 0;
    final bool isPositive = balance > 0;

    final String balanceText =
    isZero ? 'Settled' : (isPositive ? 'Owes you' : 'You owe');

    final Color balanceColor = isZero
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : (isPositive ? Colors.green.shade600 : Theme.of(context).colorScheme.error);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          HapticFeedback.lightImpact();
          // HALLUCINATED
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  FriendDetailScreen(
                    friendId: friendId,
                    friendName: name,
                    currentUserId: _currentUserId,
                  ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          ).then((_) => _refreshData());
          // HALLUCINATED
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      balanceText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: balanceColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: balanceColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  isZero
                      ? 'Settled'
                      : '${isPositive ? '+' : '-'}Ŧ${balance.abs().toStringAsFixed(balance.abs() == balance.abs().toInt() ? 0 : 2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: balanceColor,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupCard(Group group) {
    final bool isZero = group.balance == 0;
    final bool isPositive = group.balance > 0;

    String balanceText =
    isZero ? 'Settled' : (isPositive ? 'You are owed' : 'You owe');

    Color balanceColor = isZero
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : (isPositive ? Colors.green.shade600 : Theme.of(context).colorScheme.error);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
                  GroupScreen(
                    groupId: group.id,
                    groupName: group.name,
                    createdById: group.createdBy,
                    currentUserId: _currentUserId,
                  ),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 300),
            ),
          ).then((groupDeleted) {
            if (groupDeleted == true) {
              _fetchData(); // Hard refresh to clear deleted group
            } else {
              _refreshData(); // Soft refresh balances
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.groups_rounded,
                  color: Theme.of(context).primaryColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      balanceText,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: balanceColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: balanceColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Text(
                  isZero
                      ? 'Settled'
                      : '${isPositive ? '+' : '-'}Ŧ${group.balance.abs().toStringAsFixed(group.balance.abs() == group.balance.abs().toInt() ? 0 : 2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: balanceColor,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
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
              color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.group_add_rounded,
              size: 56,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No groups yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to create\nyour first expense group',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              height: 1.4,
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
              'Session Error',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Your session has expired. Please log in again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () async {
                await AuthService.logout();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                      const AuthScreen(),
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      transitionDuration: const Duration(milliseconds: 300),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Log out'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}