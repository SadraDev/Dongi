import 'package:flutter/material.dart';
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
    // Show a confirmation dialog before logging out
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
          MaterialPageRoute(builder: (context) => const AuthScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _currentUsername!,
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
        ),
        elevation: 0,
        actions: [
          // Friends
          IconButton(
            icon: const Icon(Icons.people_alt_outlined),
            tooltip: 'Friends',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FriendsScreen()),
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
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsScreen(),
                  ),
                );
                _loadUnreadCount();
              },
            ),
          ),

          // Logout Menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'logout') _handleLogout();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout_rounded, color: Colors.red),
                    SizedBox(width: 12),
                    Text('Logout', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        color: Theme.of(context).primaryColor,
        onRefresh: _refreshData,
        child: _buildGroupList(context),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
          );
          if (result == true) _refreshData();
        },
        icon: const Icon(Icons.group_add_rounded),
        label: const Text('New Group'),
        elevation: 4,
      ),
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

        // Calculate totals for the header card (SAME LOGIC)
        double totalOwed = groups
            .where((g) => g.balance > 0)
            .fold(0, (sum, g) => sum + g.balance);
        double totalOwe = groups
            .where((g) => g.balance < 0)
            .fold(0, (sum, g) => sum + g.balance.abs());

        return CustomScrollView(
          physics:
              const AlwaysScrollableScrollPhysics(), // Required for RefreshIndicator to work
          slivers: [
            // 1. Top Summary Card
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: CumulativeBalanceCard(
                  totalOwed: totalOwed,
                  totalOwe: totalOwe,
                ),
              ),
            ),

            // 2. Section Header
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  'Your Groups',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
              ),
            ),

            // 3. Group Cards List
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

  // --- Modern Group Card ---
  Widget _buildGroupCard(Group group) {
    // Determine colors and text based on balance (SAME LOGIC)
    final bool isZero = group.balance == 0;
    final bool isPositive = group.balance > 0;

    String balanceText = isZero
        ? 'Settled up'
        : (isPositive ? 'You are owed' : 'You owe');

    Color balanceColor = isZero
        ? Colors.grey
        : (isPositive ? Colors.green.shade600 : Colors.red.shade600);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        margin: EdgeInsets.zero, // Padding is handled by SliverPadding
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () async {
            final bool? groupDeleted = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GroupScreen(
                  groupId: group.id,
                  groupName: group.name,
                  createdById: group.createdBy,
                  currentUserId: _currentUserId,
                ),
              ),
            );

            if (groupDeleted == true) {
              _refreshData();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Group Icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.groups_rounded,
                    color: Theme.of(context).primaryColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),

                // Group Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
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

                // Balance Amount Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: balanceColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isZero ? 'Ŧ0' : 'Ŧ${group.balance.abs().toInt()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: balanceColor,
                      fontSize: 15,
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

  // --- Empty State ---
  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.5,
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
                    Icons.group_add_rounded,
                    size: 56,
                    color: Theme.of(
                      context,
                    ).primaryColor.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'No groups yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the button below to create\nyour first expense group',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
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

  // --- Error State ---
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
              'Something went wrong',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                await AuthService.logout();
                if (mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const AuthScreen()),
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log out'),
            ),
          ],
        ),
      ),
    );
  }
}
