import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../main.dart';
import '../../models/group_model.dart';
import '../../services/group_service.dart';
import '../../services/notification_service.dart';
import '../../widgets/cumulative_balance_card.dart';
import '../friends/friends_screen.dart';
import '../group/group_screen.dart';
import '../group/create_group_screen.dart';
import '../../services/auth_service.dart';
import '../auth/auth_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Group>> _groupsFuture;
  int _unreadCount = 0;
  int _currentUserId = 0;
  String? _currentUsername = '';

  @override
  void initState() {
    super.initState();
    _groupsFuture = GroupService.fetchGroups();
    _loadUnreadCount();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    try {
      final userId = await AuthService.getCurrentUserId();
      final username = await AuthService.getCurrentUserName();

      if (mounted) {
        setState(() {
          _currentUserId = userId;
          _currentUsername = username;
        });
      }
    } catch (e) {
      debugPrint('Could not load user ID: $e');
    }
  }

  Future<void> _loadUnreadCount() async {
    final count = await NotificationService.getUnreadCount();
    if (mounted) setState(() => _unreadCount = count);
  }

  Future<void> _refreshData() async {
    setState(() {
      _groupsFuture = GroupService.fetchGroups();
      _loadUnreadCount();
      _loadCurrentUser();
    });
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true) {
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
            transitionDuration: const Duration(milliseconds: 100),
          ),
        );
      }
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
      appBar: AppBar(
        title: Text(
          _currentUsername ?? '',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
        elevation: 0,
        actions: [
          // Friends
          IconButton(
            icon: const Icon(Icons.people_alt_outlined),
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
                  transitionDuration: const Duration(milliseconds: 100),
                ),
              );
            },
          ),

          // Theme Toggle
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, currentMode, _) {
              final bool isCurrentlyDark =
                  currentMode == ThemeMode.dark ||
                      (currentMode == ThemeMode.system &&
                          MediaQuery.platformBrightnessOf(context) ==
                              Brightness.dark);

              return IconButton(
                icon: Icon(
                  isCurrentlyDark
                      ? Icons.light_mode_outlined
                      : Icons.dark_mode_outlined,
                ),
                tooltip: 'Toggle Theme',
                onPressed: () {
                  HapticFeedback.lightImpact();
                  themeNotifier.value = isCurrentlyDark
                      ? ThemeMode.light
                      : ThemeMode.dark;
                },
              );
            },
          ),

          // Notifications
          Badge(
            isLabelVisible: _unreadCount > 0,
            label: Text('$_unreadCount'),
            offset: const Offset(-3, 3),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_rounded),
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
                    transitionDuration: const Duration(milliseconds: 100),
                  ),
                );
                _loadUnreadCount();
              },
            ),
          ),

          // Logout Menu
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.red,
            ),
            tooltip: 'Logout',
            onPressed: _handleLogout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _buildBody(),
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
              transitionDuration: const Duration(milliseconds: 100),
            ),
          );
          if (result == true) _refreshData();
        },
        icon: const Icon(Icons.group_add_rounded),
        label: const Text('New Group'),
        elevation: 0,
      ),
    );
  }

  Widget _buildBody() {
    return RefreshIndicator(
      color: Theme.of(context).primaryColor,
      onRefresh: _refreshData,
      child: _buildGroupList(context),
    );
  }

  Widget _buildGroupList(BuildContext context) {
    return FutureBuilder<List<Group>>(
      future: _groupsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState();
        }

        final groups = snapshot.data!;

        double totalOwed = 0;
        double totalOwe = 0;
        for (final group in groups) {
          totalOwed += group.totalOwed;
          totalOwe += group.totalOwe;
        }

        return CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Sliver 1: Greeting Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_getGreeting()}, ${_currentUsername ?? ''}',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getFormattedDate(),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.grey.shade500
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Sliver 2: Cumulative Balance Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: CumulativeBalanceCard(
                  totalOwed: totalOwed,
                  totalOwe: totalOwe,
                ),
              ),
            ),

            // Sliver 3: "Your Groups" header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Your Groups',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600,
                  ),
                ),
              ),
            ),

            // Sliver 4: Group Cards List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _buildGroupCard(groups[index]),
                  childCount: groups.length,
                ),
              ),
            ),

            // Bottom spacing for FAB
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _buildGroupCard(Group group) {
    final bool isZero = group.balance == 0;
    final bool isPositive = group.balance > 0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    String balanceText =
    isZero ? 'Settled' : (isPositive ? 'You are owed' : 'You owe');

    Color balanceColor = isZero
        ? (isDark ? Colors.grey.shade500 : Colors.grey.shade400)
        : (isPositive ? Colors.green.shade600 : Colors.red.shade400);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
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
                transitionDuration: const Duration(milliseconds: 100),
              ),
            ).then((groupDeleted) {
              if (groupDeleted == true) {
                _refreshData();
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                // Group Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context).primaryColor
                          .withValues(alpha: 0.15),
                    ),
                  ),
                  child: Icon(
                    Icons.groups_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // Group Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        balanceText,
                        style: TextStyle(
                          color: balanceColor,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Balance Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: balanceColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: balanceColor.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Text(
                    isZero
                        ? 'Settled'
                        : '${isPositive ? '+' : '-'}Ŧ${group.balance.abs().toStringAsFixed(group.balance.abs() == group.balance.abs().toInt() ? 0 : 2)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: balanceColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor
                        .withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Theme.of(context).primaryColor
                          .withValues(alpha: 0.15),
                    ),
                  ),
                  child: Icon(
                    Icons.group_add_rounded,
                    size: 48,
                    color: Theme.of(context).primaryColor
                        .withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'No groups yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the button below to create\nyour first expense group',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade500
                        : Colors.grey.shade500,
                    height: 1.4,
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
                border: Border.all(
                  color: Colors.red.shade200,
                ),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 44,
                color: Colors.red.shade300,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Session expired',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your session has expired. Please log in again.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade500
                    : Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
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
                      transitionDuration: const Duration(milliseconds: 100),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.logout, size: 18),
              label: const Text('Log out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}