import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:dongi/widgets/user_avatar_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/group_service.dart';
import '../../services/friend_service.dart';
import 'add_payment.dart';
import '../../services/notification_service.dart';

class GroupScreen extends StatefulWidget {
  final int groupId;
  final String groupName;
  final int createdById;
  final int currentUserId;

  const GroupScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.createdById,
    required this.currentUserId,
  });

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;

  List<dynamic> _memberBalances = [];
  List<dynamic> _expenses = [];

  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _fetchGroupData();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

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

    return (isDark: isDark, p1: p1, p2: p2, success: success, warning: warning, danger: danger, bg: bg, bg2: bg2, card: card, subtle: subtle, text: text, subText: subText, border: border);
  }

  Future<void> _fetchGroupData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await GroupService.getGroupDetails(widget.groupId);

      if (mounted) {
        setState(() {
          _memberBalances = data['members'] ?? [];
          _expenses = data['expenses'] ?? [];
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

  Future<void> _confirmDelete(BuildContext context) async {
    final t = _tokens;
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: t.border),
        ),
        title: Text(
          'Delete Group?',
          style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: t.text),
        ),
        content: Text(
          'Are you sure you want to delete this group? All expenses and balances will be permanently lost. This action cannot be undone.',
          style: GoogleFonts.outfit(color: t.subText, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(foregroundColor: t.subText),
            child: Text('Cancel', style: GoogleFonts.outfit()),
          ),
          Container(
            decoration: BoxDecoration(
              color: t.danger,
              borderRadius: BorderRadius.circular(12),
            ),
            child: FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Delete',
                style: GoogleFonts.outfit(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => Center(child: CircularProgressIndicator(color: t.p1)),
      );

      try {
        await GroupService.deleteGroup(widget.groupId);

        if (mounted) {
          Navigator.pop(context); // close loading
          Navigator.pop(context, true); // go back
          _showSuccessSnackBar('Group deleted successfully');
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
        }
      }
    }
  }

  void _showInviteDialog(BuildContext context) {
    final TextEditingController searchController = TextEditingController();
    List<dynamic> myFriends = [];
    dynamic firstFoundUser;
    bool isDialogLoading = true;
    bool isInviting = false;
    Timer? debounce;
    final t = _tokens;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Initial fetch of my friends list
            if (isDialogLoading && myFriends.isEmpty) {
              FriendService.getFriends()
                  .then((friends) {
                    if (ctx.mounted) {
                      setDialogState(() {
                        myFriends = friends;
                        isDialogLoading = false;
                      });
                    }
                  })
                  .catchError((_) {
                    if (ctx.mounted) {
                      setDialogState(() => isDialogLoading = false);
                    }
                  });
            }

            return AlertDialog(
              backgroundColor: t.card,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: t.border),
              ),
              title: Text(
                'Add to Group',
                style: GoogleFonts.sora(
                  fontWeight: FontWeight.w700,
                  color: t.text,
                ),
              ),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.85,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Search Input Box
                    TextField(
                      controller: searchController,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w500,
                        color: t.text,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search by username...',
                        hintStyle: GoogleFonts.outfit(color: t.subText),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: t.subText,
                        ),
                        filled: true,
                        fillColor: t.subtle,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: t.p1, width: 2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 16,
                        ),
                      ),
                      enabled: !isInviting,
                      onChanged: (val) {
                        if (debounce?.isActive ?? false) debounce!.cancel();
                        debounce = Timer(
                          const Duration(milliseconds: 300),
                          () async {
                            if (val.trim().isEmpty) {
                              setDialogState(() => firstFoundUser = null);
                              return;
                            }
                            try {
                              final results = await FriendService.searchUsers(
                                val.trim(),
                              );
                              setDialogState(() {
                                // Filter and strictly pick only the first match
                                firstFoundUser = results.isNotEmpty
                                    ? results.first
                                    : null;
                              });
                            } catch (_) {}
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Display Section: Dynamic Search Result or Friends List
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: isDialogLoading
                        ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(color: t.p1),
                          ),
                        )
                        : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (searchController.text
                                  .trim()
                                  .isNotEmpty) ...[
                                Text(
                                  'Search Result',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: t.subText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (firstFoundUser != null)
                                  _buildListItem(
                                    username: firstFoundUser['username'],
                                    avatarIndex: firstFoundUser['avatar_index'] ?? 0,
                                    isSuperUser: firstFoundUser['is_superuser'],
                                    isFriend: myFriends.any(
                                      (f) =>
                                          f['username'] ==
                                          firstFoundUser['username'],
                                    ),
                                    isInviting: isInviting,
                                    onTap: () {
                                      _performInvite(
                                        ctx,
                                        firstFoundUser['username'],
                                        myFriends,
                                        setDialogState,
                                        (val) => isInviting = val,
                                      );
                                    },
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      'No matching user found.',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        color: t.subText,
                                      ),
                                    ),
                                  ),
                              ] else ...[
                                Text(
                                  'My Friends',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: t.subText,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (myFriends.isEmpty)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                    ),
                                    child: Text(
                                      'Your friends directory is empty.',
                                      style: GoogleFonts.outfit(
                                        fontSize: 14,
                                        color: t.subText,
                                      ),
                                    ),
                                  )
                                else
                                  ListView.separated(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: myFriends.length,
                                    separatorBuilder: (_, _) =>
                                        const SizedBox(height: 8),
                                    itemBuilder: (context, idx) {
                                      final fName =
                                          myFriends[idx]['username'];
                                      return _buildListItem(
                                        username: fName,
                                        avatarIndex: myFriends[idx]['avatar_index'] ?? 0,
                                        isSuperUser: myFriends[idx]['is_superuser'],
                                        isFriend: true,
                                        isInviting: isInviting,
                                        onTap: () {
                                          _performInvite(
                                            ctx,
                                            fName,
                                            myFriends,
                                            setDialogState,
                                            (val) => isInviting = val,
                                          );
                                        },
                                      );
                                    },
                                  ),
                              ],
                            ],
                          ),
                        ),
                    ),
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              actions: [
                TextButton(
                  onPressed: isInviting ? null : () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(foregroundColor: t.subText),
                  child: Text('Close', style: GoogleFonts.outfit()),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildListItem({
    required String username,
    required int avatarIndex,
    required bool isSuperUser,
    required bool isFriend,
    required bool isInviting,
    required VoidCallback onTap,
  }) {
    final t = _tokens;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: t.subtle,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: t.border),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: UserAvatarDisplay(
          avatarIndex: avatarIndex,
          isSuperuser: isSuperUser,
          radius: 16,
        ),
        title: Text(
          username,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: t.text,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [t.p1, t.p2]),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(8),
              onTap: isInviting ? null : onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: Text(
                  isFriend ? 'Invite' : 'Add & Invite',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _performInvite(
    BuildContext dialogCtx,
    String username,
    List<dynamic> myFriends,
    StateSetter setDialogState,
    void Function(bool) setInviting,
  ) async {
    setDialogState(() => setInviting(true));

    final bool isAlreadyFriend = myFriends.any(
      (f) => f['username'] == username,
    );
    String operationSummary = 'Invitation sent to $username!';

    try {
      // 1. If not friend yet, simultaneously dispatch friend request
      if (!isAlreadyFriend) {
        await FriendService.sendFriendRequest(username);
        operationSummary = 'Friend request & Invitation sent to $username!';
      }

      // 2. Dispatch group invitation
      await GroupService.inviteFriendToGroup(widget.groupId, username);

      if (dialogCtx.mounted) Navigator.pop(dialogCtx);
      if (context.mounted) {
        _showSuccessSnackBar(operationSummary);
        _fetchGroupData();
      }
    } catch (e) {
      setDialogState(() => setInviting(false));
      if (context.mounted) {
        final String errorMessage = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
        _showErrorSnackBar(errorMessage);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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

          // Background Floating Currencies
          ClipRect(
            child: Stack(
              children: _buildSmoothFloatingCurrencies(t.p1, t.p2, t.isDark),
            ),
          ),

          // Content (scrollable, sits on top of currencies)
          _isLoading
              ? Center(child: CircularProgressIndicator(color: t.p1))
              : _errorMessage != null
              ? _buildErrorState()
              : RefreshIndicator(
                  color: t.p1,
                  backgroundColor: t.card,
                  onRefresh: _fetchGroupData,
                  child: CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    slivers: [
                      _buildSliverAppBar(),
                      SliverToBoxAdapter(child: _buildBalancesSection()),
                      _buildExpensesSection(),
                    ],
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
                    AddPaymentScreen(
                      groupId: widget.groupId,
                      groupName: widget.groupName,
                      members: _memberBalances,
                      currentUserId: widget.currentUserId,
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
              _fetchGroupData();
            }
          },
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            'Add Expense',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w600,
              color: Colors.white,
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
                Icons.groups_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.groupName,
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
        IconButton(
          tooltip: 'Invite Friend',
          icon: Icon(Icons.person_add_alt_1_rounded, color: t.text),
          onPressed: () {
            HapticFeedback.lightImpact();
            _showInviteDialog(context);
          },
        ),
        if (widget.createdById == widget.currentUserId)
          IconButton(
            tooltip: 'Delete Group',
            icon: Icon(Icons.delete_outline_rounded, color: t.danger),
            onPressed: () {
              HapticFeedback.lightImpact();
              _confirmDelete(context);
            },
          ),
        const SizedBox(width: 8),
      ],
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
                color: t.danger.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: t.danger.withValues(alpha: 0.3)),
                boxShadow: [
                  BoxShadow(
                    color: t.danger.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: t.danger,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load group',
              style: GoogleFonts.sora(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: t.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unknown error occurred.',
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
                onPressed: _fetchGroupData,
                icon: const Icon(Icons.refresh_rounded, color: Colors.white),
                label: Text(
                  'Try Again',
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

  Widget _buildBalancesSection() {
    final t = _tokens;
    if (_memberBalances.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            'No members found.',
            style: GoogleFonts.outfit(color: t.subText),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Text(
            'Balances',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: t.subText,
            ),
          ),
        ),
        SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            itemCount: _memberBalances.length,
            itemBuilder: (context, index) {
              final member = _memberBalances[index];
              final String name = member['name'] ?? 'Unknown';
              final double balance = (member['balance'] ?? 0).toDouble();
              final String status = member['status'] ?? 'pending';
              final bool isPending = status == 'pending';

              final Color balanceColor = isPending
                  ? t.warning
                  : balance == 0
                  ? t.subText
                  : (balance > 0 ? t.success : t.danger);

              final String balanceText = isPending
                  ? 'Pending'
                  : balance == 0
                  ? 'Settled'
                  : '${balance > 0 ? '+' : ''}${balance.toInt()}Ŧ';

              return Container(
                width: 140,
                margin: const EdgeInsets.only(right: 12.0, bottom: 8),
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: t.subtle,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isPending
                        ? t.warning.withValues(alpha: 0.4)
                        : t.border,
                    width: isPending ? 1.5 : 1,
                  ),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        UserAvatarDisplay(
                          avatarIndex: member['avatar_index'] ?? 0,
                          isSuperuser: member['is_superuser'] ?? false,
                          radius: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            name,
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: t.text,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      balanceText,
                      style: GoogleFonts.sora(
                        color: balanceColor,
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildExpensesSection() {
    final t = _tokens;
    if (_expenses.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: t.p1.withValues(alpha: t.isDark ? 0.08 : 0.1),
                  shape: BoxShape.circle,
                  border: Border.all(color: t.p1.withValues(alpha: 0.2)),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 48,
                  color: t.p1.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No expenses yet',
                style: GoogleFonts.sora(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: t.text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the button below to add one',
                style: GoogleFonts.outfit(color: t.subText, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 16),
              child: Text(
                'Recent Activity',
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: t.subText,
                ),
              ),
            );
          }
          final expenseIndex = index - 1;
          final expense = _expenses[expenseIndex];
          return _buildExpenseCard(expense);
        }, childCount: _expenses.length + 1),
      ),
    );
  }

  Widget _buildExpenseCard(Map<String, dynamic> expense) {
    final t = _tokens;
    final bool paidByMe = expense['paidByMe'] ?? false;
    final String payerName = expense['payerName'] ?? 'Someone';
    final double amount = (expense['amount'] ?? 0).toDouble();
    final accentColor = paidByMe ? t.success : t.danger;

    final String? rawDate = expense['created_at']?.toString();
    String dateStr = '';
    if (rawDate != null && rawDate.isNotEmpty) {
      try {
        final d = DateTime.parse(rawDate).toLocal();
        dateStr = ' • ${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      } catch (_) {
        dateStr = ' • $rawDate';
      }
    }

    final List<dynamic> visibleSplits = (expense['splits'] ?? []).where((
      split,
    ) {
      final dynamic rawAmount = split['amount'];
      final int splitAmount = rawAmount is num ? rawAmount.toInt() : 0;
      return splitAmount > 0;
    }).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            accentColor.withValues(alpha: 0.5),
            accentColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: t.isDark
                ? Colors.black.withValues(alpha: 0.35)
                : accentColor.withValues(alpha: 0.12),
            blurRadius: t.isDark ? 20 : 24,
            spreadRadius: t.isDark ? 0 : -6,
            offset: const Offset(0, 10),
          ),
          if (!t.isDark)
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(23),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(23),
              border: t.isDark
                  ? null
                  : Border.all(
                      color: t.border.withValues(alpha: 0.7),
                      width: 1,
                    ),
            ),
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(
                          alpha: t.isDark ? 0.15 : 0.1,
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.4),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        paidByMe
                            ? Icons.north_east_rounded
                            : Icons.south_west_rounded,
                        color: accentColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense['title'] ?? 'Expense',
                            style: GoogleFonts.sora(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                              color: t.text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (paidByMe ? 'Paid by You' : 'Paid by $payerName') + dateStr,
                            style: GoogleFonts.outfit(
                              color: t.subText,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Ŧ${amount.toInt()}',
                      style: GoogleFonts.sora(
                        fontWeight: FontWeight.w900,
                        fontSize: 20,
                        color: accentColor,
                      ),
                    ),
                  ],
                ),

                // Splits Section
                if (visibleSplits.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: t.subtle,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: t.border.withValues(alpha: 0.3),
                      ),
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(12),
                      itemCount: visibleSplits.length,
                      separatorBuilder: (context, index) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Divider(
                          height: 1,
                          color: t.border.withValues(alpha: 0.5),
                        ),
                      ),
                      itemBuilder: (context, splitIndex) => _buildSplitRow(
                        expense,
                        splitIndex,
                        paidByMe,
                        visibleSplits,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSplitRow(
    Map<String, dynamic> expense,
    int splitIndex,
    bool paidByMe,
    List<dynamic> splits,
  ) {
    final t = _tokens;
    final split = splits[splitIndex];
    final bool isPaid = split['isPaid'] ?? false;
    final String name = split['name'] ?? 'Unknown';
    final int amount = (split['amount'] ?? 0).toInt();
    final int splitId = split['id'] ?? 0;

    return Row(
      children: [
        UserAvatarDisplay(
          avatarIndex: split['avatar_index'] ?? 0,
          isSuperuser: split['is_superuser'] ?? false,
          radius: 16,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: t.text,
                ),
              ),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.outfit(fontSize: 12, color: t.subText),
                  children: [
                    const TextSpan(text: 'owes '),
                    TextSpan(
                      text: 'Ŧ$amount',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: t.text,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        if (paidByMe && !isPaid)
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [t.p1, t.p2]),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: t.p2.withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  HapticFeedback.lightImpact();
                  final int recipientId = split['user'];

                  if (recipientId == 0) {
                    _showErrorSnackBar(
                      'Could not find user ID to send reminder.',
                    );
                    return;
                  }

                  try {
                    await NotificationService.sendPaymentReminder(
                      recipientId: recipientId,
                      expenseId: expense['id'],
                    );
                    if (mounted) {
                      _showSuccessSnackBar('Reminded $name to Pay up!');
                    }
                  } catch (e) {
                    if (mounted) {
                      _showErrorSnackBar('Failed to send reminder: $e');
                    }
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    'Remind',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),
          ),

        if (paidByMe && !isPaid) const SizedBox(width: 8),

        if (paidByMe)
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              HapticFeedback.lightImpact();
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: t.card,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: t.border),
                  ),
                  title: Text(
                    isPaid ? 'Mark as Unpaid?' : 'Mark as Paid?',
                    style: GoogleFonts.sora(
                      fontWeight: FontWeight.w700,
                      color: t.text,
                    ),
                  ),
                  content: Text(
                    isPaid
                        ? 'Mark ${split['name'] ?? 'this member'}\'s share of Ŧ${(split['amount'] ?? 0)} as unpaid?'
                        : 'Mark ${split['name'] ?? 'this member'}\'s share of Ŧ${(split['amount'] ?? 0)} as paid?',
                    style: GoogleFonts.outfit(color: t.subText),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: TextButton.styleFrom(foregroundColor: t.subText),
                      child: Text('Cancel', style: GoogleFonts.outfit()),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isPaid
                              ? [t.warning, const Color(0xFFFF6D00)]
                              : [t.success, t.p1],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: FilledButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                        ),
                        child: Text(
                          isPaid ? 'Mark Unpaid' : 'Mark Paid',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm != true) return;
              final bool newStatus = !isPaid;

              setState(() {
                split['isPaid'] = newStatus;
              });

              try {
                await GroupService.toggleExpenseSplitStatus(splitId, newStatus);
                _fetchGroupData();
              } catch (e) {
                setState(() {
                  split['isPaid'] = isPaid;
                });
                if (mounted) {
                  _showErrorSnackBar('Failed to update status');
                }
              }
            },
            child: _buildStatusBadge(isPaid),
          )
        else
          _buildStatusBadge(isPaid),
      ],
    );
  }

  Widget _buildStatusBadge(bool isPaid) {
    final t = _tokens;
    final color = isPaid ? t.success : t.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: t.isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: color.withValues(alpha: t.isDark ? 0.4 : 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: t.isDark ? 0.3 : 0.2),
            blurRadius: 8,
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color,
              boxShadow: [BoxShadow(color: color, blurRadius: 4)],
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isPaid ? 'Paid' : 'Unpaid',
            style: GoogleFonts.outfit(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSmoothFloatingCurrencies(Color color1, Color color2, bool isDark) {
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
          final dy = math.cos((t * 2 * math.pi) + phaseOffset * 0.7) * floatDistance;

          return Positioned(
            left: (c['x'] as double) * MediaQuery.of(context).size.width + dx,
            top: (c['y'] as double) * MediaQuery.of(context).size.height + dy,
            child: Opacity(
              opacity: isDark ? 0.06 : 0.04,
              child: Text(c['symbol'] as String, style: TextStyle(fontSize: c['size'] as double, fontWeight: FontWeight.bold, color: c['c'] as Color)),
            ),
          );
        },
      );
    });
  }
}
