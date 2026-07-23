import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../auth/auth_screen.dart';
import '../../services/settings_service.dart';
import '../../app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
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
  }

  @override
  void dispose() {
    _floatingController.dispose();
    _gradientController.dispose();
    super.dispose();
  }

  // --- DESIGN TOKENS ---
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

  Future<void> _handleLogout(BuildContext context) async {
    final t = _tokens;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: t.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: t.border),
        ),
        title: Text(
          'Logout',
          style: GoogleFonts.sora(fontWeight: FontWeight.w700, color: t.text),
        ),
        content: Text(
          'Are you sure you want to logout of your account?',
          style: GoogleFonts.outfit(color: t.subText, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text('Logout', style: GoogleFonts.outfit(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const AuthScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
              (route) => false,
        );
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

          // Floating Currencies (NO CIRCLES)
          ClipRect(
            child: Stack(
              children: _buildSmoothFloatingCurrencies(t.p1, t.p2, t.isDark),
            ),
          ),

          // Content
          CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              _buildSliverAppBar(),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _buildSectionHeader('Appearance'),
                    _buildAppearanceCard(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Dashboard Preferences'),
                    _buildDashboardCard(),
                    const SizedBox(height: 24),
                    _buildSectionHeader('Account'),
                    _buildAccountCard(context),
                  ]),
                ),
              ),
            ],
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(colors: [t.p1, t.p2]),
              ),
              child: const Icon(Icons.settings_rounded, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 10),
            Text(
              'Settings',
              style: GoogleFonts.sora(fontWeight: FontWeight.w800, color: t.text, fontSize: 20, letterSpacing: -0.5),
            ),
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

  Widget _buildSectionHeader(String title) {
    final t = _tokens;
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w700, color: t.subText),
      ),
    );
  }

  Widget _buildCardWrapper(Widget child) {
    final t = _tokens;
    return Container(
      decoration: BoxDecoration(
        color: t.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: t.border),
        boxShadow: [
          BoxShadow(
            color: t.isDark ? Colors.black.withValues(alpha: 0.25) : const Color(0xFF0F172A).withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: child),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required IconData icon,
    required ThemeMode value,
    required ThemeMode groupValue,
  }) {
    final t = _tokens;
    final isSelected = value == groupValue;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Icon(icon, size: 22, color: isSelected ? t.p1 : t.subText),
      title: Text(
        title,
        style: GoogleFonts.outfit(fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: t.text),
      ),
      trailing: isSelected ? Icon(Icons.check_circle_rounded, color: t.p1) : null,
      onTap: () {
        HapticFeedback.lightImpact();
        themeNotifier.value = value;
        SettingsService.saveThemeMode(value);
      },
    );
  }

  Widget _buildAppearanceCard() {
    return _buildCardWrapper(
      ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, currentMode, _) {
          return Column(
            children: [
              _buildThemeOption(title: 'System Default', icon: Icons.brightness_auto_rounded, value: ThemeMode.system, groupValue: currentMode),
              _buildThemeOption(title: 'Light Mode', icon: Icons.light_mode_rounded, value: ThemeMode.light, groupValue: currentMode),
              _buildThemeOption(title: 'Dark Mode', icon: Icons.dark_mode_rounded, value: ThemeMode.dark, groupValue: currentMode),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDashboardCard() {
    final t = _tokens;
    return _buildCardWrapper(
      Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: showFriendsNotifier,
            builder: (context, showFriends, _) {
              return SwitchListTile(
                title: Text('Show Friends', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: t.text)),
                value: showFriends,
                activeTrackColor: t.p1,
                onChanged: (val) {
                  showFriendsNotifier.value = val;
                  SettingsService.saveShowFriends(val);
                },
              );
            },
          ),
          ValueListenableBuilder<bool>(
            valueListenable: showGroupsNotifier,
            builder: (context, showGroups, _) {
              return SwitchListTile(
                title: Text('Show Groups', style: GoogleFonts.outfit(fontWeight: FontWeight.w600, color: t.text)),
                value: showGroups,
                activeTrackColor: t.p1,
                onChanged: (val) {
                  showGroupsNotifier.value = val;
                  SettingsService.saveShowGroups(val);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAccountCard(BuildContext context) {
    final t = _tokens;
    return _buildCardWrapper(
      ListTile(
        leading: Icon(Icons.logout_rounded, color: t.danger),
        title: Text('Log out', style: GoogleFonts.outfit(fontWeight: FontWeight.w700, color: t.danger)),
        onTap: () => _handleLogout(context),
      ),
    );
  }

  // --- BACKGROUND FLOATING CURRENCIES (NO CIRCLES) ---
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
              child: Text(
                c['symbol'] as String,
                style: TextStyle(fontSize: c['size'] as double, fontWeight: FontWeight.bold, color: c['c'] as Color),
              ),
            ),
          );
        },
      );
    });
  }
}