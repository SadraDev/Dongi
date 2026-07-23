// screens/auth/auth_screen.dart
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../home/home_screen.dart';
import '../../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLogin = true;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  late AnimationController _floatingController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.03), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _animationController.forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    _floatingController.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    HapticFeedback.lightImpact();
    _animationController.reverse().then((_) {
      setState(() {
        _isLogin = !_isLogin;
        _formKey.currentState?.reset();
        _usernameController.clear();
        _passwordController.clear();
      });
      _animationController.forward();
    });
  }

  void _submitAuth() async {
    HapticFeedback.lightImpact();

    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      String? errorMessage;
      if (_isLogin) {
        errorMessage = await AuthService.login(username, password);
      } else {
        errorMessage = await AuthService.register(username, password);
      }

      if (mounted) {
        setState(() => _isLoading = false);

        if (errorMessage == null) {
          HapticFeedback.mediumImpact();
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        } else {
          HapticFeedback.heavyImpact();
          _showErrorSnackBar(errorMessage);
        }
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Theme.of(context).colorScheme.onError,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // --- SPECTACULAR MODERN CYBER THEME ---
    final primaryColor1 = const Color(0xFF00E5FF); // Neon Cyan
    final primaryColor2 = const Color(0xFF7C3AED); // Electric Violet

    // IMPROVED LIGHT MODE: Stronger gradients so it doesn't look washed out
    final bgColor1 = isDark ? const Color(0xFF050816) : const Color(0xFFF1F5F9);
    final bgColor2 = isDark
        ? const Color(0xFF0A0F1E)
        : const Color(0xFFDBEAFE); // More obvious blue tint in light

    final cardColor = isDark
        ? const Color(0xFF0D1321).withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.95); // More opaque in light mode
    final fieldFillColor = isDark
        ? const Color(0xFF151C2C).withValues(alpha: 0.8)
        : const Color(
      0xFFE2E8F0,
    ).withValues(alpha: 0.6); // Darker fill in light mode

    // IMPROVED LIGHT MODE: Pure dark text for maximum accuracy/readability
    final onSurface = isDark
        ? const Color(0xFFE2E8F0)
        : const Color(0xFF020617);
    final onSurfaceVariant = isDark
        ? const Color(0xFF64748B)
        : const Color(0xFF475569); // Darker subtle text for light mode

    // IMPROVED LIGHT MODE: Heavier borders so they are actually visible
    final borderColor = isDark
        ? const Color(0xFF1E293B)
        : const Color(0xFFCBD5E1);

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [bgColor1, bgColor2, bgColor1],
                ),
              ),
            ),
          ),

          // IMPROVED LIGHT MODE: Bumped glow opacity so it shows up nicely
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
                    primaryColor1.withValues(alpha: isDark ? 0.15 : 0.20),
                    primaryColor1.withValues(alpha: 0),
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
                    primaryColor2.withValues(alpha: isDark ? 0.12 : 0.15),
                    primaryColor2.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),

          // Match HomeScreen Floating Currencies Wrapper
          ClipRect(
            child: Stack(
              children: _buildSmoothFloatingCurrencies(
                primaryColor1,
                primaryColor2,
                isDark,
              ),
            ),
          ),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 28.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 48),

                        // --- PREMIUM TECH LOGO ---
                        Center(
                          child: Container(
                            height: 110,
                            width: 110,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: primaryColor1.withValues(
                                  alpha: isDark ? 0.3 : 0.5,
                                ), // Stronger border in light
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor1.withValues(
                                    alpha: isDark ? 0.4 : 0.35,
                                  ),
                                  blurRadius: 40,
                                  spreadRadius: 2,
                                ),
                                BoxShadow(
                                  color: primaryColor2.withValues(
                                    alpha: isDark ? 0.3 : 0.2,
                                  ),
                                  blurRadius: 40,
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                            child: Container(
                              margin: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? const Color(0xFF0F172A)
                                    : Colors.white,
                                border: Border.all(
                                  color: isDark
                                      ? const Color(0xFF1E293B)
                                      : borderColor,
                                  width: 1,
                                ),
                              ),
                              child: Center(
                                child: ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          Color(0xFF00E5FF),
                                          Color(0xFF7C3AED),
                                        ],
                                      ).createShader(bounds),
                                  child: const Text(
                                    'D',
                                    style: TextStyle(
                                      fontSize: 60,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: -2,
                                      height: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // --- DONGI TITLE (Sora Font for maximum premium look) ---
                        Text(
                          'Dongi',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.sora(
                            fontSize: 48,
                            fontWeight: FontWeight.w800,
                            color: onSurface,
                            letterSpacing: -2.5,
                            height: 1,
                          ),
                        ),
                        const SizedBox(height: 12),

                        Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _CurrencyChip(
                                symbol: '₮',
                                color: primaryColor1,
                                isDark: isDark,
                              ),
                              const SizedBox(width: 14),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 250),
                                transitionBuilder: (child, animation) =>
                                    FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                child: Text(
                                  _isLogin
                                      ? 'Split expenses, seamlessly.'
                                      : 'Join the modern way to share.',
                                  key: ValueKey(_isLogin),
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w500,
                                    color: onSurfaceVariant,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 14),
                              _CurrencyChip(
                                symbol: '﷼',
                                color: primaryColor2,
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 52),

                        // --- GLASSMORPHIC FORM CARD ---
                        Container(
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: isDark
                                  ? const Color(
                                0xFF1E293B,
                              ).withValues(alpha: 0.8)
                                  : const Color(0xFFCBD5E1).withValues(
                                alpha: 0.9,
                              ), // Visible border in light
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(
                                  alpha: isDark ? 0.5 : 0.08,
                                ),
                                blurRadius: 50,
                                offset: const Offset(0, 20),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(32),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  28,
                                  32,
                                  28,
                                  32,
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.stretch,
                                    children: [
                                      _buildTextField(
                                        controller: _usernameController,
                                        label: 'Username',
                                        hintText: 'Enter your username',
                                        icon: Icons.person_outline_rounded,
                                        fillColor: fieldFillColor,
                                        borderColor: borderColor,
                                        textColor: onSurface,
                                        subtleTextColor: onSurfaceVariant,
                                        primaryColor: primaryColor1,
                                        isDark: isDark,
                                        validator: (value) {
                                          if (value == null || value.isEmpty)
                                            return 'Username is required';
                                          if (value.length < 3)
                                            return 'Too short';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 18),

                                      _buildTextField(
                                        controller: _passwordController,
                                        label: 'Password',
                                        hintText: 'Enter your password',
                                        icon: Icons.lock_outline_rounded,
                                        fillColor: fieldFillColor,
                                        borderColor: borderColor,
                                        textColor: onSurface,
                                        subtleTextColor: onSurfaceVariant,
                                        primaryColor: primaryColor1,
                                        isDark: isDark,
                                        obscureText: !_isPasswordVisible,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _isPasswordVisible
                                                ? Icons.visibility_off_rounded
                                                : Icons.visibility_rounded,
                                            color: onSurfaceVariant.withValues(
                                              alpha: 0.8,
                                            ),
                                            size: 20,
                                          ),
                                          onPressed: () => setState(
                                                () => _isPasswordVisible =
                                            !_isPasswordVisible,
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty)
                                            return 'Password is required';
                                          if (value.length < 6)
                                            return 'At least 6 characters';
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 28),

                                      Container(
                                        height: 62,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            18,
                                          ),
                                          gradient: const LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF00E5FF),
                                              Color(0xFF7C3AED),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: primaryColor2.withValues(
                                                alpha: isDark ? 0.5 : 0.35,
                                              ),
                                              blurRadius: 30,
                                              offset: const Offset(0, 12),
                                            ),
                                          ],
                                        ),
                                        child: FilledButton(
                                          onPressed: _isLoading
                                              ? null
                                              : _submitAuth,
                                          style: FilledButton.styleFrom(
                                            backgroundColor: Colors.transparent,
                                            shadowColor: Colors.transparent,
                                            disabledBackgroundColor:
                                            Colors.transparent,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(18),
                                            ),
                                          ),
                                          child: _isLoading
                                              ? const SizedBox(
                                            width: 26,
                                            height: 26,
                                            child:
                                            CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                              : Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                _isLogin
                                                    ? 'Sign In'
                                                    : 'Create Account',
                                                style: GoogleFonts.outfit(
                                                  fontSize: 16,
                                                  fontWeight:
                                                  FontWeight.w700,
                                                  letterSpacing: 0.3,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Icon(
                                                _isLogin
                                                    ? Icons
                                                    .arrow_forward_rounded
                                                    : Icons.add_rounded,
                                                color: Colors.white
                                                    .withValues(
                                                  alpha: 0.9,
                                                ),
                                                size: 20,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        Center(
                          child: TextButton(
                            onPressed: _isLoading ? null : _switchAuthMode,
                            style: TextButton.styleFrom(
                              foregroundColor: primaryColor1,
                              splashFactory: NoSplash.splashFactory,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 28,
                                vertical: 14,
                              ),
                            ),
                            child: RichText(
                              text: TextSpan(
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  color: onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(
                                    text: _isLogin
                                        ? "Don't have an account? "
                                        : "Already registered? ",
                                  ),
                                  TextSpan(
                                    text: _isLogin ? "Sign up" : "Sign in",
                                    style: TextStyle(
                                      color: primaryColor1,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SMOOTH FLOATING CURRENCIES (HomeScreen Style) ---
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

  Widget _CurrencyChip({
    required String symbol,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(
          alpha: isDark ? 0.1 : 0.12,
        ), // Slightly stronger in light
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withValues(alpha: isDark ? 0.25 : 0.40),
          width: 1,
        ), // Visible border
      ),
      child: Text(
        symbol,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w800,
          color: color.withValues(
            alpha: isDark ? 0.9 : 1.0,
          ), // Full opacity in light
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    required Color fillColor,
    required Color borderColor,
    required Color textColor,
    required Color subtleTextColor,
    required Color primaryColor,
    required bool isDark, // Added to adjust light mode specifically
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      style: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: textColor,
        letterSpacing: 0.2,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: GoogleFonts.outfit(
          fontSize: 12.5,
          color: subtleTextColor.withValues(alpha: isDark ? 0.9 : 1.0),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        hintStyle: GoogleFonts.outfit(
          fontSize: 14,
          color: subtleTextColor.withValues(
            alpha: isDark ? 0.35 : 0.5,
          ), // Darker hint in light mode
          fontWeight: FontWeight.w400,
        ),
        prefixIcon: Icon(
          icon,
          color: subtleTextColor.withValues(
            alpha: isDark ? 0.6 : 0.8,
          ), // Darker icon in light mode
          size: 20,
        ),
        suffixIcon: suffixIcon,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        filled: true,
        fillColor: fillColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: borderColor.withValues(
              alpha: isDark ? 0.5 : 0.8,
            ), // Crisp border in light mode
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: primaryColor.withValues(alpha: isDark ? 0.6 : 0.8),
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.5),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.error,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 18,
        ),
      ),
    );
  }
}