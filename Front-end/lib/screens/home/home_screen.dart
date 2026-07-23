import 'dart:async';
import 'dart:math' as math;
import 'package:dongi/widgets/global_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/group_model.dart';
import '../../services/group_service.dart';
import '../../services/friend_service.dart';
import '../../services/notification_service.dart';
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

class _Tokens {
  final bool isDark;
  final Color p1, p2, success, warning, danger;
  final Color bg, bg2, card, subtle, text, subText, border;

  _Tokens({
    required this.isDark,
    required this.p1,
    required this.p2,
    required this.success,
    required this.warning,
    required this.danger,
    required this.bg,
    required this.bg2,
    required this.card,
    required this.subtle,
    required this.text,
    required this.subText,
    required this.border,
  });
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;

  List<Group> _groups = [];
  List<dynamic> _friends = [];
  int _unreadCount = 0;
  int _currentUserId = 0;
  String? _currentUsername = '';

  late AnimationController _floatingController;
  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
    _fetchData();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  _Tokens get _tokens {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const p1 = Color(0xFF00E5FF);
    const p2 = Color(0xFF7C3AED);
    const success = Color(0xFF00E676);
    const warning = Color(0xFFFFAB00);
    const danger = Color(0xFFFF3B5C);

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

    return _Tokens(
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

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
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
    if (hour >= 5 && hour < 12) return 'Good morning';
    if (hour >= 12 && hour < 17) return 'Good afternoon';
    if (hour >= 17 && hour < 21) return 'Good evening';
    return 'Good night';
  }

  String _getFormattedDate() {
    final now = DateTime.now();
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
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final t = _tokens;

    return Scaffold(
      backgroundColor: t.bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _gradientController,
              builder: (context, child) {
                final value = _gradientController.value;
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [t.bg, t.bg2, t.bg],
                      stops: [0.0, 0.4 + value * 0.2, 1.0],
                    ),
                  ),
                );
              },
            ),
          ),

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

          ClipRect(
            child: Stack(
              children: _buildSmoothFloatingCurrencies(t.p1, t.p2, t.isDark),
            ),
          ),

          _isLoading
              ? Center(
            child: CircularProgressIndicator(color: t.p1, strokeWidth: 3),
          )
              : _errorMessage != null
              ? _buildErrorState()
              : RefreshIndicator(
            color: t.p1,
            backgroundColor: t.card,
            onRefresh: _refreshData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [_buildSliverAppBar(), _buildBodyContent()],
            ),
          ),
        ],
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF00E5FF), Color(0xFF7C3AED)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: t.p2.withValues(alpha: t.isDark ? 0.6 : 0.4),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
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
          icon: const Icon(Icons.group_add_rounded, color: Colors.white),
          label: Text(
            'New Group',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    final t = _tokens;
    return SliverAppBar.large(
      pinned: true,
      stretch: true,
      expandedHeight: 160,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const GlobalAvatar(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getGreeting()},',
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: t.subText,
                    ),
                  ),
                  Text(
                    _currentUsername ?? 'User',
                    style: GoogleFonts.sora(
                      fontWeight: FontWeight.w800,
                      color: t.text,
                      fontSize: 18,
                      letterSpacing: -0.5,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
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
        IconButton(
          icon: Icon(Icons.people_alt_rounded, color: t.text),
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
            ).then((_) => _refreshData());
          },
        ),
        Badge(
          isLabelVisible: _unreadCount > 0,
          label: Text('$_unreadCount'),
          backgroundColor: t.danger,
          textColor: Colors.white,
          offset: const Offset(-4, 4),
          child: IconButton(
            icon: Icon(Icons.notifications_rounded, color: t.text),
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
          icon: Icon(Icons.settings_rounded, color: t.text),
          tooltip: 'Settings',
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                const SettingsScreen(),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
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
    final t = _tokens;

    double correctNet = 0;
    for (final friend in _friends) {
      correctNet += (friend['balance'] ?? 0).toDouble();
    }

    double totalOwedSummary = 0;
    double totalOweSummary = 0;

    for (final group in _groups) {
      totalOwedSummary += group.totalOwed;
      totalOweSummary += group.totalOwe;
    }

    for (final friend in _friends) {
      final double bal = (friend['direct_balance'] ?? 0).toDouble();
      if (bal > 0) {
        totalOwedSummary += bal;
      } else if (bal < 0) {
        totalOweSummary += bal.abs();
      }
    }

    final List<Widget> listItems = [];

    listItems.add(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCumulativeBalanceCard(
            correctNet,
            totalOwedSummary,
            totalOweSummary,
          ),
          if (_friends.isNotEmpty && showFriendsNotifier.value)
            Padding(
              padding: const EdgeInsets.only(left: 4, top: 24, bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Friends',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: t.subText,
                    ),
                  ),
                  Text(
                    _getFormattedDate(),
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: t.subText,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );

    if (showFriendsNotifier.value) {
      for (final friend in _friends) {
        if (friend['balance'] != 0) {
          listItems.add(_buildFriendCard(friend));
        }
      }
    }

    if (showGroupsNotifier.value) {
      listItems.add(
        Padding(
          padding: EdgeInsets.only(
            left: 4,
            top: (_friends.isEmpty || !showFriendsNotifier.value) ? 24 : 12,
            bottom: 12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your Groups',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: t.subText,
                ),
              ),
              Text(
                _getFormattedDate(),
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: t.subText,
                ),
              ),
            ],
          ),
        ),
      );

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

  Widget _buildCumulativeBalanceCard(
      double netBalance,
      double totalOwed,
      double totalOwe,
      ) {
    final t = _tokens;
    final double net = netBalance;
    final bool isPositive = net > 0;
    final bool isZero = net == 0;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: t.border),
        boxShadow: [
          BoxShadow(
            color: t.isDark
                ? Colors.black.withValues(alpha: 0.25)
                : const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Net Balance',
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: t.subText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isZero
                      ? t.subText.withValues(alpha: t.isDark ? 0.12 : 0.08)
                      : (isPositive
                      ? t.success.withValues(
                    alpha: t.isDark ? 0.12 : 0.08,
                  )
                      : t.danger.withValues(
                    alpha: t.isDark ? 0.12 : 0.08,
                  )),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isZero
                        ? t.subText.withValues(alpha: t.isDark ? 0.3 : 0.4)
                        : (isPositive
                        ? t.success.withValues(
                      alpha: t.isDark ? 0.3 : 0.4,
                    )
                        : t.danger.withValues(
                      alpha: t.isDark ? 0.3 : 0.4,
                    )),
                  ),
                ),
                child: Text(
                  isZero ? 'Settled' : (isPositive ? 'You are up' : 'You owe'),
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isZero
                        ? t.subText
                        : (isPositive ? t.success : t.danger),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${isPositive ? '+' : ''}Ŧ${net.abs().toStringAsFixed(net.abs() == net.abs().toInt() ? 0 : 2)}',
            style: GoogleFonts.sora(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: isZero ? t.subText : (isPositive ? t.success : t.danger),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You are owed',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: t.subText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ŧ${totalOwed.toStringAsFixed(totalOwed == totalOwed.toInt() ? 0 : 2)}',
                      style: GoogleFonts.sora(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: t.success,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: t.border.withValues(alpha: 0.5),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You owe',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: t.subText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ŧ${totalOwe.toStringAsFixed(totalOwe == totalOwe.toInt() ? 0 : 2)}',
                      style: GoogleFonts.sora(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: t.danger,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFriendCard(dynamic friend) {
    final t = _tokens;
    final String name = friend['username'] ?? 'Unknown';
    final int friendId = friend['id'];
    final double balance = (friend['balance'] ?? 0).toDouble();

    final bool isZero = balance == 0;
    final bool isPositive = balance > 0;

    final String balanceText = isZero
        ? 'Settled'
        : (isPositive ? 'Owes you' : 'You owe');
    final Color balanceColor = isZero
        ? t.subText
        : (isPositive ? t.success : t.danger);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    FriendDetailScreen(
                      friendId: friendId,
                      friendName: name,
                      currentUserId: _currentUserId,
                    ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            ).then((_) => _refreshData());
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [t.p1, t.p2]),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: t.card,
                    child: Text(
                      name.isNotEmpty ? name[0].toUpperCase() : '?',
                      style: GoogleFonts.sora(
                        fontWeight: FontWeight.bold,
                        color: t.text,
                        fontSize: 18,
                      ),
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
                        style: GoogleFonts.sora(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: t.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        balanceText,
                        style: GoogleFonts.outfit(
                          color: t.subText,
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
                    color: balanceColor.withValues(
                      alpha: t.isDark ? 0.16 : 0.12,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: balanceColor.withValues(
                        alpha: t.isDark ? 0.3 : 0.4,
                      ),
                    ),
                  ),
                  child: Text(
                    isZero
                        ? 'Settled'
                        : '${isPositive ? '+' : '-'}Ŧ${balance.abs().toStringAsFixed(balance.abs() == balance.abs().toInt() ? 0 : 2)}',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      color: balanceColor,
                      fontSize: 13,
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

  Widget _buildGroupCard(Group group) {
    final t = _tokens;
    final bool isZero = group.balance == 0;
    final bool isPositive = group.balance > 0;

    String balanceText = isZero
        ? 'Settled'
        : (isPositive ? 'You are owed' : 'You owe');
    Color balanceColor = isZero
        ? t.subText
        : (isPositive ? t.success : t.danger);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                _fetchData();
              } else {
                _refreshData();
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
                    color: t.p1.withValues(alpha: t.isDark ? 0.10 : 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: t.p1.withValues(alpha: t.isDark ? 0.25 : 0.35),
                    ),
                  ),
                  child: Icon(Icons.groups_rounded, color: t.p1, size: 26),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        group.name,
                        style: GoogleFonts.sora(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: t.text,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        balanceText,
                        style: GoogleFonts.outfit(
                          color: t.subText,
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
                    color: balanceColor.withValues(
                      alpha: t.isDark ? 0.16 : 0.12,
                    ),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: balanceColor.withValues(
                        alpha: t.isDark ? 0.3 : 0.4,
                      ),
                    ),
                  ),
                  child: Text(
                    isZero
                        ? 'Settled'
                        : '${isPositive ? '+' : '-'}Ŧ${group.balance.abs().toStringAsFixed(group.balance.abs() == group.balance.abs().toInt() ? 0 : 2)}',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      color: balanceColor,
                      fontSize: 13,
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
    final t = _tokens;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: t.p1.withValues(alpha: t.isDark ? 0.10 : 0.08),
              shape: BoxShape.circle,
              border: Border.all(color: t.p1.withValues(alpha: 0.2)),
            ),
            child: Icon(
              Icons.group_add_rounded,
              size: 56,
              color: t.p1.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No groups yet',
            style: GoogleFonts.sora(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: t.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to create\nyour first expense group',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 16,
              color: t.subText,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final t = _tokens;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: t.danger.withValues(alpha: t.isDark ? 0.10 : 0.05),
                shape: BoxShape.circle,
                border: Border.all(
                  color: t.danger.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: t.danger.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Session Error',
              style: GoogleFonts.sora(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: t.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Your session has expired. Please log in again.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: t.subText),
            ),
            const SizedBox(height: 32),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00E5FF), Color(0xFF7C3AED)],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: t.p2.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FilledButton.icon(
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
                          return FadeTransition(
                            opacity: animation,
                            child: child,
                          );
                        },
                        transitionDuration: const Duration(milliseconds: 300),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded, color: Colors.white),
                label: Text(
                  'Log out',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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