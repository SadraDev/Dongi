import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:dongi/widgets/user_avatar_display.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/friend_service.dart';
import '../../services/group_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen>
    with TickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  List<dynamic> _availableFriends = [];
  bool _isFetchingFriends = true;

  final Set<String> _selectedFriends = {};

  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
    _fetchFriendsFromBackend();
  }

  @override
  void dispose() {
    _nameController.dispose();
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

  Future<void> _fetchFriendsFromBackend() async {
    try {
      final friends = await FriendService.getFriends();
      if (mounted) {
        setState(() {
          _availableFriends = friends;
          _isFetchingFriends = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isFetchingFriends = false);
        _showErrorSnackBar('Failed to load friends: $e');
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

  Future<void> _createGroup() async {
    final groupName = _nameController.text.trim();

    if (groupName.isEmpty) {
      _showErrorSnackBar('Please enter a group name');
      return;
    }

    if (_selectedFriends.isEmpty) {
      _showErrorSnackBar('Please select at least one friend');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await GroupService.createGroup(groupName, _selectedFriends.toList());

      if (mounted) {
        HapticFeedback.mediumImpact();
        _showSuccessSnackBar('Group created successfully!');
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Error: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
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

          // Full-screen floating currencies (NO CIRCLES)
          ClipRect(
            child: Stack(
              children: _buildSmoothFloatingCurrencies(t.p1, t.p2, t.isDark),
            ),
          ),

          // Content (scrollable, sits on top of currencies)
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildNameInput(),
                      const SizedBox(height: 32),
                      Text(
                        'Add Members',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: t.subText,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildFriendsList(),
              const SliverToBoxAdapter(child: SizedBox(height: 100)),
            ],
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
          onPressed: _isLoading ? null : _createGroup,
          icon: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          )
              : const Icon(Icons.check_rounded),
          label: Text(
            _isLoading ? 'Creating...' : 'Create Group',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  SliverAppBar _buildSliverAppBar() {
    final t = _tokens;
    return SliverAppBar.large(
      pinned: true,
      stretch: true,
      expandedHeight: 140,
      backgroundColor: Colors.transparent, // Ensures no harsh lines
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
              'New Group',
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
    );
  }

  Widget _buildNameInput() {
    final t = _tokens;
    return TextField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
      style: GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: t.text,
      ),
      decoration: InputDecoration(
        labelText: 'Group Name',
        hintText: 'e.g., Weekend Trip',
        labelStyle: GoogleFonts.outfit(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: t.subText,
        ),
        prefixIcon: Icon(Icons.groups_rounded, color: t.subText),
        floatingLabelBehavior: FloatingLabelBehavior.always,
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
          horizontal: 24,
          vertical: 20,
        ),
      ),
      enabled: !_isLoading,
    );
  }

  Widget _buildFriendsList() {
    final t = _tokens;
    if (_isFetchingFriends) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator(color: t.p1)),
      );
    }

    if (_availableFriends.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildNoFriendsState(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final friendUsername = _availableFriends[index]['username'];
          final isSelected = _selectedFriends.contains(friendUsername);

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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _isLoading
                      ? null
                      : () {
                    HapticFeedback.lightImpact();
                    setState(() {
                      if (isSelected) {
                        _selectedFriends.remove(friendUsername);
                      } else {
                        _selectedFriends.add(friendUsername);
                      }
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 16,
                    ),
                    child: Row(
                      children: [
                        UserAvatarDisplay(
                          avatarIndex: _availableFriends[index]['avatar_index'] ?? 0,
                          isSuperuser: _availableFriends[index]['is_superuser'] ?? false,
                          radius: 22,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            friendUsername,
                            style: GoogleFonts.sora(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: t.text,
                            ),
                          ),
                        ),
                        AnimatedScale(
                          scale: isSelected ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: t.p1,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }, childCount: _availableFriends.length),
      ),
    );
  }

  Widget _buildNoFriendsState() {
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
            ),
            child: Icon(
              Icons.person_add_disabled_rounded,
              size: 56,
              color: t.p1.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No friends found',
            style: GoogleFonts.sora(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: t.text,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some friends first to create a group!',
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