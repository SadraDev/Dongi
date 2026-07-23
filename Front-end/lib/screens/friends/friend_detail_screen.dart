import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:dongi/widgets/user_avatar_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/friend_service.dart';
import '../../services/group_service.dart';
import '../../services/notification_service.dart';
import '../group/add_payment.dart';

class FriendDetailScreen extends StatefulWidget {
  final int friendId;
  final String friendName;
  final int currentUserId;

  const FriendDetailScreen({
    super.key,
    required this.friendId,
    required this.friendName,
    required this.currentUserId,
  });

  @override
  State<FriendDetailScreen> createState() => _FriendDetailScreenState();
}

class _FriendDetailScreenState extends State<FriendDetailScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;

  double _netBalance = 0.0;
  int _friendAvatarIndex = 0;
  List<dynamic> _expenses = [];

  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _fetchFriendData();
  }

  @override
  void dispose() {
    _floatingController.dispose();
    super.dispose();
  }

  Future<void> _fetchFriendData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await FriendService.getFriendDetails(widget.friendId);

      if (mounted) {
        setState(() {
          _netBalance = (data['friend']['balance'] ?? 0).toDouble();
          _friendAvatarIndex = data['friend']['avatar_index'] ?? 0;
          _expenses = data['expenses'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  // --- SILENT REFRESH: Updates data in the background without showing a loading spinner ---
  Future<void> _silentRefresh() async {
    try {
      final data = await FriendService.getFriendDetails(widget.friendId);
      if (mounted) {
        setState(() {
          _netBalance = (data['friend']['balance'] ?? 0).toDouble();
          _friendAvatarIndex = data['friend']['avatar_index'] ?? 0;
          _expenses = data['expenses'] ?? [];
        });
      }
    } catch (e) {
      // Silently fail, keep the optimistic UI state so the user isn't interrupted
      debugPrint('Silent refresh failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final p1 = const Color(0xFF00E5FF);
    final p2 = const Color(0xFF7C3AED);
    final success = const Color(0xFF00E676);
    final warning = const Color(0xFFFFAB00);
    final danger = const Color(0xFFFF3B5C);

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

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          // Cyber Background Base
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [bg, bg2, bg],
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
                    p1.withValues(alpha: isDark ? 0.15 : 0.20),
                    p1.withValues(alpha: 0),
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
                    p2.withValues(alpha: isDark ? 0.12 : 0.15),
                    p2.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          // Background Floating Currencies (NO CIRCLES)
          ClipRect(
            child: Stack(
              children: _buildSmoothFloatingCurrencies(p1, p2, isDark),
            ),
          ),

          // Main Content
          _isLoading
              ? Center(
            child: CircularProgressIndicator(color: p1, strokeWidth: 3),
          )
              : _errorMessage != null
              ? _buildErrorState(isDark, bg, card, text, subText, p1, p2)
              : RefreshIndicator(
            color: p1,
            backgroundColor: card,
            onRefresh: _fetchFriendData,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              slivers: [

                _buildSliverAppBar(isDark, bg, text, p1, p2, border),
                SliverToBoxAdapter(
                  child: _buildBalanceHeader(
                    isDark,
                    card,
                    subtle,
                    text,
                    subText,
                    p1,
                    p2,
                    success,
                    warning,
                    danger,
                  ),
                ),
                _buildExpensesSection(
                  isDark,
                  card,
                  subtle,
                  text,
                  subText,
                  border,
                  p1,
                  p2,
                  success,
                  warning,
                  danger,
                ),
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
              color: p2.withValues(alpha: isDark ? 0.6 : 0.4),
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
                      groupId: null,
                      friendId: widget.friendId,
                      groupName: 'Direct with ${widget.friendName}',
                      members: [
                        {
                          'id': widget.friendId,
                          'name': widget.friendName,
                          'status': 'accepted',
                        },
                      ],
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
              _fetchFriendData();
            }
          },
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text(
            'Add Expense',
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

  // --- SLIVER APP BAR ---
  SliverAppBar _buildSliverAppBar(
      bool isDark,
      Color bg,
      Color text,
      Color p1,
      Color p2,
      Color border,
      ) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                p1.withValues(alpha: isDark ? 0.14 : 0.10),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          UserAvatarDisplay(
            avatarIndex: _friendAvatarIndex,
            radius: 16,
          ),
          const SizedBox(width: 12),
          Text(
            widget.friendName,
            style: GoogleFonts.sora(
              fontWeight: FontWeight.w800,
              color: text,
              fontSize: 20,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
      bool isDark,
      Color bg,
      Color card,
      Color text,
      Color subText,
      Color p1,
      Color p2,
      ) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.red.withValues(alpha: isDark ? 0.1 : 0.05),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load details',
              style: GoogleFonts.sora(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(color: subText),
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
                    color: p2.withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FilledButton.icon(
                onPressed: _fetchFriendData,
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

  Widget _buildBalanceHeader(
      bool isDark,
      Color card,
      Color subtle,
      Color text,
      Color subText,
      Color p1,
      Color p2,
      Color success,
      Color warning,
      Color danger,
      ) {
    final bool isZero = _netBalance == 0;
    final bool isPositive = _netBalance > 0;
    final Color balanceColor = isZero
        ? subText
        : (isPositive ? success : danger);

    final String statusText = isZero
        ? 'All settled up'
        : (isPositive
        ? '${widget.friendName} owes you'
        : 'You owe ${widget.friendName}');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              balanceColor.withValues(alpha: 0.6),
              balanceColor.withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            if (!isZero)
              BoxShadow(
                color: balanceColor.withValues(alpha: isDark ? 0.2 : 0.15),
                blurRadius: 30,
                spreadRadius: -5,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(26.5),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 24),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(26.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: balanceColor.withValues(
                        alpha: isDark ? 0.15 : 0.1,
                      ),
                      borderRadius: BorderRadius.circular(100),
                      border: Border.all(
                        color: balanceColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      statusText,
                      style: GoogleFonts.outfit(
                        color: balanceColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        isZero
                            ? 'Ŧ0'
                            : '${isPositive ? '+' : '-'}Ŧ${_netBalance.abs().toStringAsFixed(_netBalance.abs() == _netBalance.abs().toInt() ? 0 : 2)}',
                        style: GoogleFonts.sora(
                          color: isZero ? text : balanceColor,
                          fontSize: 44,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -2,
                          shadows: isDark && !isZero
                              ? [
                            Shadow(
                              color: balanceColor.withValues(alpha: 0.4),
                              blurRadius: 20,
                            ),
                          ]
                              : [],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExpensesSection(
      bool isDark,
      Color card,
      Color subtle,
      Color text,
      Color subText,
      Color border,
      Color p1,
      Color p2,
      Color success,
      Color warning,
      Color danger,
      ) {
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
                  shape: BoxShape.circle,
                  color: p1.withValues(alpha: isDark ? 0.08 : 0.1),
                  border: Border.all(color: p1.withValues(alpha: 0.2)),
                ),
                child: Icon(
                  Icons.receipt_long_rounded,
                  size: 48,
                  color: p1.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No shared expenses',
                style: GoogleFonts.sora(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: text,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the button below to add one',
                style: GoogleFonts.outfit(color: subText, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 16),
              child: Text(
                'Transactions',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: subText,
                  letterSpacing: 0.5,
                ),
              ),
            );
          }
          final expenseIndex = index - 1;
          final expense = _expenses[expenseIndex];
          return _buildExpenseCard(
            expense,
            isDark,
            card,
            subtle,
            text,
            subText,
            border,
            p1,
            p2,
            success,
            warning,
            danger,
          );
        }, childCount: _expenses.length + 1),
      ),
    );
  }

  Widget _buildExpenseCard(
      Map<String, dynamic> expense,
      bool isDark,
      Color card,
      Color subtle,
      Color text,
      Color subText,
      Color border,
      Color p1,
      Color p2,
      Color success,
      Color warning,
      Color danger,
      ) {
    final bool paidByMe = expense['paidByMe'] ?? false;
    final String payerName = expense['payerName'] ?? 'Someone';
    final double amount = (expense['amount'] ?? 0).toDouble();
    final String groupName = expense['groupName'] ?? 'Direct Expense';
    final accentColor = paidByMe ? success : danger;

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
            color: isDark
                ? Colors.black.withValues(alpha: 0.35)
                : accentColor.withValues(alpha: 0.12),
            blurRadius: isDark ? 20 : 24,
            spreadRadius: isDark ? 0 : -6,
            offset: const Offset(0, 10),
          ),
          if (!isDark)
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
              color: card,
              borderRadius: BorderRadius.circular(23),
              border: isDark
                  ? null
                  : Border.all(color: border.withValues(alpha: 0.7), width: 1),
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
                          alpha: isDark ? 0.15 : 0.1,
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
                              color: text,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            (paidByMe ? 'Paid by You' : 'Paid by $payerName') + dateStr,
                            style: GoogleFonts.outfit(
                              color: subText,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: p1.withValues(alpha: isDark ? 0.1 : 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: p1.withValues(alpha: isDark ? 0.25 : 0.35),
                        ),
                      ),
                      child: Text(
                        groupName,
                        style: GoogleFonts.outfit(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: p1,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
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

                if (visibleSplits.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: subtle,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: border.withValues(alpha: 0.3)),
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
                          color: border.withValues(alpha: 0.5),
                        ),
                      ),
                      itemBuilder: (context, splitIndex) => _buildSplitRow(
                        expense,
                        splitIndex,
                        paidByMe,
                        visibleSplits,
                        isDark,
                        card,
                        subtle,
                        text,
                        subText,
                        border,
                        p1,
                        p2,
                        success,
                        warning,
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
      bool isDark,
      Color card,
      Color subtle,
      Color text,
      Color subText,
      Color border,
      Color p1,
      Color p2,
      Color success,
      Color warning,
      ) {
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
                  color: text,
                ),
              ),
              RichText(
                text: TextSpan(
                  style: GoogleFonts.outfit(fontSize: 12, color: subText),
                  children: [
                    const TextSpan(text: 'owes '),
                    TextSpan(
                      text: 'Ŧ$amount',
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        color: text,
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
              gradient: LinearGradient(colors: [p1, p2]),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: p2.withValues(alpha: 0.4),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Could not find user ID to send reminder.',
                        ),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  try {
                    await NotificationService.sendPaymentReminder(
                      recipientId: recipientId,
                      expenseId: expense['id'],
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Reminded $name to Pay up!'),
                          backgroundColor: success,
                        ),
                      );
                    }
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to send reminder: $e'),
                          backgroundColor: Colors.redAccent,
                        ),
                      );
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

        if (paidByMe || expense['groupName'] == null)
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              HapticFeedback.lightImpact();
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: isDark
                      ? const Color(0xFF0D1321)
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                    side: BorderSide(color: border.withValues(alpha: 0.5)),
                  ),
                  title: Text(
                    isPaid ? 'Mark as Unpaid?' : 'Mark as Paid?',
                    style: GoogleFonts.sora(
                      fontWeight: FontWeight.w700,
                      color: text,
                    ),
                  ),
                  content: Text(
                    isPaid
                        ? 'Mark ${split['name'] ?? 'this member'}\'s share of Ŧ${(split['amount'] ?? 0)} as unpaid?'
                        : 'Mark ${split['name'] ?? 'this member'}\'s share of Ŧ${(split['amount'] ?? 0)} as paid?',
                    style: GoogleFonts.outfit(color: subText),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.outfit(color: subText),
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: isPaid
                              ? [warning, const Color(0xFFFF6D00)]
                              : [success, p1],
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
                if (paidByMe) {
                  if (newStatus) {
                    _netBalance -= amount.toDouble();
                  } else {
                    _netBalance += amount.toDouble();
                  }
                } else {
                  if (newStatus) {
                    _netBalance += amount.toDouble();
                  } else {
                    _netBalance -= amount.toDouble();
                  }
                }
              });

              try {
                await GroupService.toggleExpenseSplitStatus(splitId, newStatus);
                // SILENT BACKGROUND SYNC to ensure exact backend accuracy
                _silentRefresh();
              } catch (e) {
                // REVERT OPTIMISTIC UPDATE if backend fails
                setState(() {
                  split['isPaid'] = isPaid;
                  if (paidByMe) {
                    if (newStatus) {
                      _netBalance += amount.toDouble();
                    } else {
                      _netBalance -= amount.toDouble();
                    }
                  } else {
                    if (newStatus) {
                      _netBalance -= amount.toDouble();
                    } else {
                      _netBalance += amount.toDouble();
                    }
                  }
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Failed to update status'),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
              }
            },
            child: _buildStatusBadge(isPaid, isDark, success, warning),
          )
        else
          _buildStatusBadge(isPaid, isDark, success, warning),
      ],
    );
  }

  Widget _buildStatusBadge(
      bool isPaid,
      bool isDark,
      Color success,
      Color warning,
      ) {
    final color = isPaid ? success : warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(100),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.4 : 0.6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: isDark ? 0.3 : 0.2),
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