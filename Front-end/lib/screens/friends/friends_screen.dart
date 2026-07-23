import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:dongi/widgets/user_avatar_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
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

class _FriendsScreenState extends State<FriendsScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  List<dynamic> _friends = [];
  List<dynamic> _pendingRequests = [];
  Timer? _debounce;
  bool _isSearching = false;
  bool _isLoadingFriends = true;

  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _loadData();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  // --- DESIGN TOKENS (shared visual language) ---
  ({
  bool isDark,
  Color p1,
  Color p2,
  Color success,
  Color warning,
  Color danger,
  Color bg,
  Color bg2,
  Color card,
  Color subtle,
  Color text,
  Color subText,
  Color border,
  })
  get _tokens {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const p1 = Color(0xFF00E5FF);
    const p2 = Color(0xFF7C3AED);
    const success = Color(0xFF00E676);
    const warning = Color(0xFFFFAB00);
    const danger = Color(0xFFFF3B5C);

    // Auth/Home Screen derived colors
    final bg = isDark ? const Color(0xFF050816) : const Color(0xFFF1F5F9);
    final bg2 = isDark ? const Color(0xFF0A0F1E) : const Color(0xFFDBEAFE);

    final card = isDark
        ? const Color(0xFF0D1321).withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.95);
    final subtle = isDark
        ? const Color(0xFF151C2C).withValues(alpha: 0.8)
        : const Color(0xFFE2E8F0).withValues(alpha: 0.6);
    final text = isDark ? const Color(0xFFE2E8F0) : const Color(0xFF020617);
    final subText = isDark ? const Color(0xFF64748B) : const Color(0xFF475569);
    final border = isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1);

    return (
    isDark: isDark,
    p1: p1,
    p2: p2,
    success: success,
    warning: warning,
    danger: danger,
    bg: bg,
    bg2: bg2,
    card: card,
    subtle: subtle,
    text: text,
    subText: subText,
    border: border,
    );
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
    final t = _tokens;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: t.border),
        ),
        title: Text(
          'Remove Friend',
          style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: t.text),
        ),
        content: Text(
          'Are you sure you want to remove $username from your friends list? This cannot be undone.',
          style: GoogleFonts.outfit(color: t.subText, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: t.subText),
            child: Text('Cancel', style: GoogleFonts.outfit()),
          ),
          Container(
            decoration: BoxDecoration(
              color: t.danger,
              borderRadius: BorderRadius.circular(12),
            ),
            child: FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                _removeFriend(id, username);
              },
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Remove',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
            ),
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
      final errorMessage = e
          .toString()
          .replaceFirst('Exception: ', '')
          .replaceAll('DioException [bad response]: ', '');
      _showErrorSnackBar(errorMessage);
    }
  }

  void _showGroupSelectionDialog(String username) {
    final screenContext = context;
    final t = _tokens;

    showDialog(
      context: screenContext,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: t.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: BorderSide(color: t.border),
          ),
          title: Text(
            'Add to Group',
            style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: t.text),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          content: SizedBox(
            width: double.maxFinite,
            child: FutureBuilder<List<dynamic>>(
              future: GroupService.fetchGroups(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(
                    height: 100,
                    child: Center(
                      child: CircularProgressIndicator(color: t.p1),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: t.danger.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 40,
                          color: t.danger,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load groups',
                        style: GoogleFonts.sora(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: t.text,
                        ),
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
                          color: t.subtle,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.group_off_rounded,
                          size: 40,
                          color: t.subText,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No groups available',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.sora(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: t.text,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Create a group first to invite friends.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.outfit(
                          fontSize: 14,
                          color: t.subText,
                        ),
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
                      style: GoogleFonts.outfit(fontSize: 14, color: t.subText),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 300),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: groups.length,
                        separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final group = groups[index];
                          final int groupId = group is Map
                              ? group['id']
                              : (group as dynamic).id;
                          final String groupName = group is Map
                              ? group['name']
                              : (group as dynamic).name;

                          return InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () async {
                              Navigator.pop(dialogContext);

                              showDialog(
                                context: screenContext,
                                barrierDismissible: false,
                                builder: (_) => Center(
                                  child: CircularProgressIndicator(color: t.p1),
                                ),
                              );

                              try {
                                await GroupService.inviteFriendToGroup(
                                  groupId,
                                  username,
                                );
                                if (screenContext.mounted) {
                                  Navigator.pop(screenContext);
                                  _showSuccessSnackBar(
                                    '$username invited to $groupName',
                                  );
                                }
                              } catch (e) {
                                if (screenContext.mounted) {
                                  Navigator.pop(screenContext);
                                  _showErrorSnackBar(
                                    e.toString().replaceFirst(
                                      'Exception: ',
                                      '',
                                    ),
                                  );
                                }
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                color: t.subtle,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: t.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: LinearGradient(
                                        colors: [t.p1, t.p2],
                                      ),
                                    ),
                                    child: CircleAvatar(
                                      radius: 16,
                                      backgroundColor: t.card,
                                      child: Icon(
                                        Icons.groups_rounded,
                                        color: t.p1,
                                        size: 16,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      groupName,
                                      style: GoogleFonts.outfit(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: t.text,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: t.subText,
                                  ),
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
          actionsPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(foregroundColor: t.subText),
              child: Text('Cancel', style: GoogleFonts.outfit()),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessSnackBar(String message) {
    final t = _tokens;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.outfit(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: t.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    final t = _tokens;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.outfit(color: Colors.white),
              ),
            ),
          ],
        ),
        backgroundColor: t.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = _tokens;

    return Scaffold(
      backgroundColor: t.bg,
      body: Stack(
        children: [
          // Cyber Background Base
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [t.bg, t.bg2, t.bg],
                ),
              ),
            ),
          ),

          // Background Ambient Glows
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    t.p1.withValues(alpha: t.isDark ? 0.15 : 0.20),
                    t.p1.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -120,
            left: -100,
            child: Container(
              width: 380,
              height: 380,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    t.p2.withValues(alpha: t.isDark ? 0.12 : 0.15),
                    t.p2.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          // Floating Currencies (NO CIRCLES)
          ClipRect(
            child: Stack(
              children: _buildSmoothFloatingCurrencies(t.p1, t.p2, t.isDark),
            ),
          ),

          // Content (scrollable, sits on top of currencies)
          RefreshIndicator(
            color: t.p1,
            backgroundColor: t.card,
            onRefresh: _loadData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [
                _buildSliverAppBar(theme),
                SliverToBoxAdapter(child: _buildSearchSection(theme)),
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
                            (context, index) => _buildSearchResultCard(
                          _searchResults[index],
                          theme,
                        ),
                        childCount: _searchResults.length,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      child: Divider(color: t.border),
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
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(ThemeData theme) {
    final t = _tokens;
    return SliverAppBar.large(
      pinned: true,
      stretch: true,
      expandedHeight: 140,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [t.p1, t.p2]),
              ),
              child: const Icon(
                Icons.people_alt_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Friends',
              style: GoogleFonts.sora(
                fontWeight: FontWeight.w800,
                color: t.text,
                fontSize: 20,
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
                t.p1.withValues(alpha: t.isDark ? 0.14 : 0.10),
                Colors.transparent,
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
              backgroundColor: t.danger,
              textColor: Colors.white,
              offset: const Offset(-4, 4),
              child: IconButton(
                icon: Icon(Icons.person_add_alt_1_rounded, color: t.text),
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
    final t = _tokens;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: GoogleFonts.outfit(fontWeight: FontWeight.w500, color: t.text),
        decoration: InputDecoration(
          hintText: 'Search by username...',
          hintStyle: GoogleFonts.outfit(
            color: t.subText,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: Icon(Icons.search_rounded, color: t.subText),
          suffixIcon: _isSearching
              ? Padding(
            padding: const EdgeInsets.all(14),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: t.p1,
              ),
            ),
          )
              : AnimatedScale(
            scale: _searchController.text.isNotEmpty ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: IconButton(
              icon: Icon(Icons.cancel_rounded, color: t.subText),
              onPressed: () {
                _searchController.clear();
                setState(() => _searchResults = []);
              },
            ),
          ),
          filled: true,
          fillColor: t.subtle,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide(color: t.p1, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required ThemeData theme,
    required String title,
    int? count,
  }) {
    final t = _tokens;
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Row(
          children: [
            Text(
              title,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: t.subText,
              ),
            ),
            const SizedBox(width: 8),
            if (count != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: t.p1.withValues(alpha: t.isDark ? 0.14 : 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: t.p1,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResultCard(dynamic user, ThemeData theme) {
    final t = _tokens;
    final username = user['username'] as String;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          color: t.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: t.border),
          boxShadow: [
            BoxShadow(
              color: t.isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 8,
          ),
          leading: UserAvatarDisplay(
            avatarIndex: user['avatar_index'] ?? 0,
            isSuperuser: user['is_superuser'] ?? false,
            radius: 20,
          ),
          title: Text(
            username,
            style: GoogleFonts.sora(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: t.text,
            ),
          ),
          trailing: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [t.p1, t.p2]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _sendRequest(username),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.person_add_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Add',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFriendsList(ThemeData theme) {
    final t = _tokens;
    if (_isLoadingFriends) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator(color: t.p1)),
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
    final t = _tokens;
    final username = friend['username'] as String;

    // Calculate balance layout based on the backend data
    final double balance = (friend['balance'] ?? 0).toDouble();
    final bool isZero = balance == 0;
    final bool isPositive = balance > 0;

    // Green when the friend owes you, red when you owe the friend.
    final Color balanceColor = isZero
        ? t.subText
        : (isPositive ? t.success : t.danger);

    final String balanceText = isZero
        ? 'Settled'
        : '${isPositive ? '+' : '-'}Ŧ${balance.abs().toStringAsFixed(balance.abs() == balance.abs().toInt() ? 0 : 2)}';

    return Dismissible(
      key: ValueKey(friend['id']),
      direction: DismissDirection.horizontal,
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        decoration: BoxDecoration(
          color: t.p1.withValues(alpha: t.isDark ? 0.18 : 0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long_rounded, color: t.p1),
            const SizedBox(width: 8),
            Text(
              'Add Expense',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: t.p1,
              ),
            ),
          ],
        ),
      ),
      secondaryBackground: Container(
        margin: const EdgeInsets.only(bottom: 12),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: t.danger.withValues(alpha: t.isDark ? 0.18 : 0.12),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Remove',
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.w700,
                color: t.danger,
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.delete_outline_rounded, color: t.danger),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          // Swipe right-to-left → Remove Friend
          _showRemoveDialog(friend['id'], username);
          return false;
        } else {
          // Swipe left-to-right → Add Expense
          await _addExpenseToFriend(friend, username);
          return false; // Don’t dismiss the card
        }
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          decoration: BoxDecoration(
            color: t.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: t.border),
            boxShadow: [
              BoxShadow(
                color: t.isDark
                    ? Colors.black.withValues(alpha: 0.25)
                    : const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => _navigateToFriendDetails(friend, username),
              onLongPress: () => _showFriendOptions(friend, username, theme),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    UserAvatarDisplay(
                      avatarIndex: friend['avatar_index'] ?? 0,
                      isSuperuser: friend['is_superuser'] ?? false,
                      radius: 22,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: GoogleFonts.sora(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: t.text,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Tap for options',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: t.subText,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Net Balance Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: balanceColor.withValues(
                          alpha: t.isDark ? 0.16 : 0.12,
                        ),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        balanceText,
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: balanceColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    InkWell(
                      child: Icon(Icons.more_vert_rounded, color: t.subText),
                      onTap: () => _showFriendOptions(friend, username, theme),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addExpenseToFriend(dynamic friend, String username) async {
    HapticFeedback.lightImpact();
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
                  {'id': friend['id'], 'name': username, 'status': 'accepted'},
                ],
                currentUserId: currentUserId,
              ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
  }

  Future<void> _navigateToFriendDetails(dynamic friend, String username) async {
    HapticFeedback.lightImpact();
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
  }

  void _showFriendOptions(dynamic friend, String username, ThemeData theme) {
    HapticFeedback.lightImpact();
    final t = _tokens;

    showModalBottomSheet(
      context: context,
      backgroundColor: t.card,
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
                  color: t.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              InkWell(
                onTap: () async {
                  Navigator.pop(context); // Close the bottom sheet
                  _navigateToFriendDetails(friend, username);
                },
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      UserAvatarDisplay(
                        avatarIndex: friend['avatar_index'] ?? 0,
                        isSuperuser: friend['is_superuser'] ?? false,
                        radius: 26,
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              username,
                              style: GoogleFonts.sora(
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                                color: t.text,
                              ),
                            ),
                            Text(
                              'Friend',
                              style: GoogleFonts.outfit(
                                color: t.subText,
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
              Divider(color: t.border, height: 1),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: t.p1.withValues(alpha: t.isDark ? 0.14 : 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.receipt_long_rounded, color: t.p1),
                ),
                title: Text(
                  'Add Expense',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: t.text,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                onTap: () async {
                  HapticFeedback.lightImpact();
                  Navigator.pop(context);
                  await _addExpenseToFriend(friend, username);
                },
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: t.p1.withValues(alpha: t.isDark ? 0.14 : 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.group_add_rounded, color: t.p1),
                ),
                title: Text(
                  'Add to Group',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: t.text,
                  ),
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
                    color: t.danger.withValues(alpha: t.isDark ? 0.16 : 0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.person_remove_rounded, color: t.danger),
                ),
                title: Text(
                  'Remove Friend',
                  style: GoogleFonts.outfit(
                    color: t.danger,
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
    final t = _tokens;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: t.p1.withValues(alpha: t.isDark ? 0.10 : 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_alt_rounded,
              size: 64,
              color: t.p1.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No friends yet',
            style: GoogleFonts.sora(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: t.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Search for users above\nand send friend requests',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(fontSize: 16, color: t.subText),
          ),
        ],
      ),
    );
  }

  // --- BACKGROUND FLOATING CURRENCIES (NO CIRCLES) ---
  List<Widget> _buildSmoothFloatingCurrencies(
      Color color1,
      Color color2,
      bool isDark,
      ) {
    final currencies = [
      {'symbol': '₮', 'x': 0.06, 'y': 0.10, 'size': 52.0, 'c': color1},
      {'symbol': '﷼', 'x': 0.90, 'y': 0.06, 'size': 60.0, 'c': color2},
      {'symbol': '💳', 'x': 0.94, 'y': 0.38, 'size': 44.0, 'c': color1},
      {'symbol': '₮', 'x': 0.03, 'y': 0.55, 'size': 48.0, 'c': color2},
      {'symbol': '﷼', 'x': 0.87, 'y': 0.72, 'size': 56.0, 'c': color1},
      {'symbol': '💳', 'x': 0.12, 'y': 0.88, 'size': 40.0, 'c': color2},
      {'symbol': '₮', 'x': 0.78, 'y': 0.94, 'size': 46.0, 'c': color1},
      {'symbol': '﷼', 'x': 0.50, 'y': 0.03, 'size': 36.0, 'c': color2},
      {'symbol': '💳', 'x': 0.42, 'y': 0.96, 'size': 42.0, 'c': color1},
      {'symbol': '₮', 'x': 0.95, 'y': 0.55, 'size': 34.0, 'c': color2},
      {'symbol': '﷼', 'x': 0.20, 'y': 0.20, 'size': 38.0, 'c': color1},
      {'symbol': '💳', 'x': 0.80, 'y': 0.20, 'size': 42.0, 'c': color2},
      {'symbol': '₮', 'x': 0.10, 'y': 0.80, 'size': 36.0, 'c': color1},
      {'symbol': '﷼', 'x': 0.70, 'y': 0.80, 'size': 40.0, 'c': color2},
      {'symbol': '💳', 'x': 0.30, 'y': 0.40, 'size': 34.0, 'c': color1},
    ];

    return List.generate(currencies.length, (index) {
      final c = currencies[index];
      final phaseOffset = index * 0.6;
      final floatDistance = 12.0 + (index % 3) * 4.0;

      return AnimatedBuilder(
        animation: _floatingController,
        builder: (context, child) {
          final t = _floatingController.value;
          final dx = math.sin((t * 2 * math.pi) + phaseOffset) * floatDistance;
          final dy =
              math.cos((t * 2 * math.pi) + phaseOffset * 0.7) * floatDistance;

          return Positioned(
            left: (c['x'] as double) * MediaQuery.of(context).size.width + dx,
            top: (c['y'] as double) * MediaQuery.of(context).size.height + dy,
            child: Opacity(
              opacity: isDark ? 0.06 : 0.04,
              child: Text(
                c['symbol'] as String,
                style: TextStyle(
                  fontSize: c['size'] as double,
                  fontWeight: FontWeight.bold,
                  color: c['c'] as Color,
                ),
              ),
            ),
          );
        },
      );
    });
  }
}