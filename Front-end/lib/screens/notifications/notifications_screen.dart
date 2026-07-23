import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/friend_service.dart';
import '../../services/group_service.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  List<dynamic> _notifications = [];

  final Set<int> _processingIds = {};

  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _fetchNotifications();
  }

  @override
  void dispose() {
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

  Future<void> _fetchNotifications() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final items = await NotificationService.fetchNotifications();
      if (mounted) {
        setState(() {
          _notifications = items;
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

  Future<void> _refreshNotifications() async {
    try {
      final items = await NotificationService.fetchNotifications();
      if (mounted) {
        setState(() {
          _notifications = items;
        });
      }
    } catch (e) {
      debugPrint('Refresh failed: $e');
    }
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final diff = now.difference(date);

      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';

      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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
        _showSuccessSnackBar(type == 'friend_request' ? 'Friend request accepted!' : 'Joined group successfully!');
        _refreshNotifications();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _processingIds.remove(id));
        _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
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
        _showSuccessSnackBar(type == 'friend_request' ? 'Friend request rejected.' : 'Group invite declined.');
        _refreshNotifications();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _processingIds.remove(id));
        _showErrorSnackBar(e.toString().replaceFirst('Exception: ', ''));
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
    final t = _tokens;
    return Scaffold(
      backgroundColor: t.bg,
      body: Stack(
        children: [
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
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [t.p1.withValues(alpha: t.isDark ? 0.15 : 0.20), t.p1.withValues(alpha: 0)],
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
                  colors: [t.p2.withValues(alpha: t.isDark ? 0.12 : 0.15), t.p2.withValues(alpha: 0)],
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
              ? Center(child: CircularProgressIndicator(color: t.p1, strokeWidth: 3))
              : _errorMessage != null
              ? _buildErrorState()
              : RefreshIndicator(
            color: t.p1,
            backgroundColor: t.card,
            onRefresh: _refreshNotifications,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
              slivers: [_buildSliverAppBar(), _buildBodyContent()],
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    final t = _tokens;
    return SliverAppBar.large(
      pinned: true,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [t.p1, t.p2]),
              ),
              child: const Icon(Icons.notifications_rounded, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text('Notifications', style: GoogleFonts.sora(fontWeight: FontWeight.w800, color: t.text, fontSize: 20, letterSpacing: -0.5)),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [t.p1.withValues(alpha: t.isDark ? 0.14 : 0.10), Colors.transparent],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBodyContent() {
    if (_notifications.isEmpty) {
      return SliverFillRemaining(hasScrollBody: false, child: _buildEmptyState());
    }
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) => _buildNotificationCard(_notifications[index]),
          childCount: _notifications.length,
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
          Icon(Icons.notifications_none_rounded, size: 64, color: t.subText.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Text('All caught up!', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: t.text)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    final t = _tokens;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline_rounded, size: 64, color: t.danger),
          const SizedBox(height: 16),
          Text('Failed to load', style: GoogleFonts.sora(fontSize: 20, fontWeight: FontWeight.w700, color: t.text)),
          const SizedBox(height: 32),
          FilledButton(onPressed: _fetchNotifications, child: const Text('Try Again')),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(dynamic item) {
    final t = _tokens;
    final int id = item['id'];
    final bool isProcessing = _processingIds.contains(id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: t.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: t.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(item['message'] ?? '', style: GoogleFonts.outfit(color: t.text)),
            ),
            if (isProcessing) const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
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