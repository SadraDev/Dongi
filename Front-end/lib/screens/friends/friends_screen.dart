import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../../services/friend_service.dart';
import '../../services/group_service.dart';
import '../notifications/notifications_screen.dart';
import '../group/add_payment.dart';
import 'friend_detail_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  List<dynamic> _friends = [];
  List<dynamic> _pendingRequests = [];
  Timer? _debounce;
  bool _isSearching = false;
  bool _isLoadingFriends = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([_loadFriends(), _loadPendingRequests()]);
  }

  Future<void> _loadFriends() async {
    try {
      final friends = await FriendService.getFriends();
      if (mounted) {
        setState(() {
          _friends = friends;
          _isLoadingFriends = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoadingFriends = false);
    }
  }

  Future<void> _loadPendingRequests() async {
    try {
      final requests = await FriendService.getPendingRequests();
      if (mounted) setState(() => _pendingRequests = requests);
    } catch (e) {
      debugPrint('Error loading pending requests: $e');
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.isEmpty) {
        setState(() => _searchResults = []);
        return;
      }

      setState(() => _isSearching = true);
      try {
        final results = await FriendService.searchUsers(query);
        if (mounted) setState(() => _searchResults = results);
      } catch (e) {
        debugPrint('Search error: $e');
      } finally {
        if (mounted) setState(() => _isSearching = false);
      }
    });
  }

  Future<void> _sendRequest(String username) async {
    HapticFeedback.lightImpact();
    await FriendService.sendFriendRequest(username);
    if (mounted) {
      _showSuccessSnackBar('Request sent to $username');
      setState(() {
        _searchResults.removeWhere((u) => u['username'] == username);
      });
    }
  }

  void _showRemoveDialog(int id, String username) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Remove Friend',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Are you sure you want to remove $username from your friends list? This cannot be undone.',
          style: const TextStyle(height: 1.5),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _removeFriend(id, username);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> _removeFriend(int id, String username) async {
    try {
      await FriendService.removeFriend(id);
      _showSuccessSnackBar('$username removed');
      _loadFriends();
    } catch (e) {
      // Clean up the exception string to show our custom backend message
      final errorMessage = e.toString().replaceFirst('Exception: ', '').replaceAll('DioException [bad response]: ', '');
      _showErrorSnackBar(errorMessage);
    }
  }

  void _showGroupSelectionDialog(String username) {
    final screenContext = context;
    final theme = Theme.of(context);

    showDialog(
      context: screenContext,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Add to Group',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<List<dynamic>>(
              future: GroupService.fetchGroups(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox(
                    height: 100,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                if (snapshot.hasError) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.errorContainer,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.error_outline_rounded, size: 40, color: theme.colorScheme.error),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Failed to load groups',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.group_off_rounded, size: 40, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No groups available',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a group first to invite friends.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }

                final groups = snapshot.data!;

                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select a group to invite $username:',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: groups.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          final int groupId = group is Map ? group['id'] : (group as dynamic).id;
                          final String groupName = group is Map ? group['name'] : (group as dynamic).name;

                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              Navigator.pop(dialogContext);

                              showDialog(
                                context: screenContext,
                                barrierDismissible: false,
                                builder: (_) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );

                              try {
                                await GroupService.inviteFriendToGroup(groupId, username);
                                if (screenContext.mounted) {
                                  Navigator.pop(screenContext);
                                  _showSuccessSnackBar('$username invited to $groupName');
                                }
                              } catch (e) {
                                if (screenContext.mounted) {
                                  Navigator.pop(screenContext);
                                  _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: theme.dividerColor.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
                                    child: Icon(
                                      Icons.groups_rounded,
                                      color: theme.primaryColor,
                                      size: 18,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      groupName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.onSurfaceVariant,
              ),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: RefreshIndicator(
        color: theme.primaryColor,
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            _buildSliverAppBar(theme),
            SliverToBoxAdapter(
              child: _buildSearchSection(theme),
            ),
            if (_searchResults.isNotEmpty) ...[
              _buildSectionHeader(
                theme: theme,
                title: 'Search Results',
                count: _searchResults.length,
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildSearchResultCard(_searchResults[index], theme),
                    childCount: _searchResults.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Divider(color: theme.dividerColor.withValues(alpha: 0.3)),
                ),
              ),
            ],
            _buildSectionHeader(
              theme: theme,
              title: 'My Friends',
              count: _isLoadingFriends ? null : _friends.length,
            ),
            _buildFriendsList(theme),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar.large(
      pinned: true,
      stretch: true,
      expandedHeight: 140,
      backgroundColor: theme.colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Text(
          'Friends',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.primaryColor.withValues(alpha: 0.1),
                theme.colorScheme.surface,
              ],
            ),
          ),
        ),
      ),
      actions: [
        if (_pendingRequests.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Badge(
              label: Text('${_pendingRequests.length}'),
              offset: const Offset(-4, 4),
              child: IconButton(
                icon: const Icon(Icons.person_add_alt_1_rounded),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsScreen(),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSearchSection(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Search by username...',
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          suffixIcon: _isSearching
              ? Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: theme.primaryColor,
              ),
            ),
          )
              : AnimatedScale(
            scale: _searchController.text.isNotEmpty ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              icon: Icon(Icons.cancel_rounded, color: theme.colorScheme.onSurfaceVariant),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchResults = []);
              },
            ),
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(
              color: theme.primaryColor,
              width: 2,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required ThemeData theme,
    required String title,
    int? count,
  }) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Row(
          children: [
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: 8),
            if (count != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(dynamic user, ThemeData theme) {
    final username = user['username'] as String;
    final firstLetter = username.isNotEmpty ? username[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Card(
        elevation: 0,
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(
            color: theme.dividerColor.withValues(alpha: 0.4),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: CircleAvatar(
            radius: 22,
            backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
            child: Text(
              firstLetter,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.primaryColor,
                fontSize: 16,
              ),
            ),
          ),
          title: Text(
            username,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
            ),
          ),
          trailing: FilledButton.tonalIcon(
            onPressed: () => _sendRequest(username),
            icon: const Icon(Icons.person_add_rounded, size: 18),
            label: const Text("Add"),
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsList(ThemeData theme) {
    if (_isLoadingFriends) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_friends.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildEmptyState(theme),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) => _buildFriendCard(_friends[index], theme),
          childCount: _friends.length,
        ),
      ),
    );
  }

  Widget _buildFriendCard(dynamic friend, ThemeData theme) {
    final username = friend['username'] as String;
    final firstLetter = username.isNotEmpty ? username[0].toUpperCase() : '?';

    // Calculate balance layout based on the backend data
    final double balance = (friend['balance'] ?? 0).toDouble();
    final bool isZero = balance == 0;
    final bool isPositive = balance > 0;

    final Color balanceColor = isZero
        ? theme.colorScheme.onSurfaceVariant
        : (isPositive ? Colors.green.shade600 : theme.colorScheme.error);

    final String balanceText = isZero
        ? 'Settled'
        : '${isPositive ? '+' : '-'}Ŧ${balance.abs().toStringAsFixed(balance.abs() == balance.abs().toInt() ? 0 : 2)}';

    return Dismissible(
      key: ValueKey(friend['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: theme.colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
      ),
      confirmDismiss: (direction) async {
        _showRemoveDialog(friend['id'], username);
        return false;
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Card(
          elevation: 0,
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(
              color: theme.dividerColor.withValues(alpha: 0.4),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(24),
            onTap: () => _showFriendOptions(friend, username, theme),
            onLongPress: () => _showFriendOptions(friend, username, theme),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: theme.colorScheme.secondaryContainer,
                    child: Text(
                      firstLetter,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSecondaryContainer,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Tap for options',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Net Balance Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: balanceColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      balanceText,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: balanceColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  Icon(
                    Icons.more_vert_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showFriendOptions(dynamic friend, String username, ThemeData theme) {
    HapticFeedback.lightImpact();
    final firstLetter = username.isNotEmpty ? username[0].toUpperCase() : '?';

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              // Drag Handle
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              InkWell(
                onTap: () async {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context); // Close the bottom sheet

                  final currentUserId = await AuthService.getCurrentUserId();
                  if (mounted) {
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            FriendDetailScreen(
                              friendId: friend['id'],
                              friendName: username,
                              currentUserId: currentUserId,
                            ),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    ).then((_) => _loadData());
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.colorScheme.secondaryContainer,
                        child: Text(
                          firstLetter,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: theme.colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                            Text(
                              'Friend',
                              style: TextStyle(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Divider(color: theme.dividerColor.withValues(alpha: 0.4), height: 1),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.receipt_long_rounded, color: theme.primaryColor),
                ),
                title: const Text(
                  'Add Expense',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                onTap: () async {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);

                  final currentUserId = await AuthService.getCurrentUserId();

                  if (mounted) {
                    final result = await Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            AddPaymentScreen(
                              groupId: null,
                              friendId: friend['id'],
                              groupName: 'Direct with $username',
                              members: [
                                {'id': friend['id'], 'name': username, 'status': 'accepted'}
                              ],
                              currentUserId: currentUserId,
                            ),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                        fullscreenDialog: true,
                      ),
                    );

                    if (result == true) {
                      _loadData();
                    }
                  }
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.group_add_rounded, color: theme.primaryColor),
                ),
                title: const Text(
                  'Add to Group',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  _showGroupSelectionDialog(username);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_remove_rounded, color: theme.colorScheme.error),
                ),
                title: Text(
                  'Remove Friend',
                  style: TextStyle(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                onTap: () {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  _showRemoveDialog(friend['id'], username);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_alt_rounded,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No friends yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for users above\nand send friend requests',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}