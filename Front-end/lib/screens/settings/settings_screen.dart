import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';
import '../auth/auth_screen.dart';
import '../../services/settings_service.dart';
import '../../app_state.dart';


class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to logout of your account?',
          style: TextStyle(height: 1.5),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Logout'),
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
            pageBuilder: (context, animation, secondaryAnimation) =>
            const AuthScreen(),
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          _buildSliverAppBar(theme),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 40),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSectionHeader('Appearance', theme),
                _buildAppearanceCard(theme),
                const SizedBox(height: 24),
                _buildSectionHeader('Dashboard Preferences', theme),
                _buildDashboardCard(theme),
                const SizedBox(height: 24),
                _buildSectionHeader('Account', theme),
                _buildAccountCard(context, theme),
              ]),
            ),
          ),
        ],
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
          'Settings',
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
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _buildCardWrapper(Widget child, ThemeData theme) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: child,
      ),
    );
  }

  Widget _buildThemeOption({
    required String title,
    required IconData icon,
    required ThemeMode value,
    required ThemeMode groupValue,
    required ThemeData theme,
  }) {
    final isSelected = value == groupValue;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.primaryColor.withValues(alpha: 0.15)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 20,
          color: isSelected ? theme.primaryColor : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: theme.colorScheme.onSurface,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_circle_rounded, color: theme.primaryColor)
          : null,
      onTap: () {
        HapticFeedback.lightImpact();
        themeNotifier.value = value;
        SettingsService.saveThemeMode(value);
      },
    );
  }

  Widget _buildAppearanceCard(ThemeData theme) {
    return _buildCardWrapper(
      ValueListenableBuilder<ThemeMode>(
        valueListenable: themeNotifier,
        builder: (context, currentMode, _) {
          return Column(
            children: [
              _buildThemeOption(
                title: 'System Default',
                icon: Icons.brightness_auto_rounded,
                value: ThemeMode.system,
                groupValue: currentMode,
                theme: theme,
              ),
              Divider(color: theme.dividerColor.withValues(alpha: 0.4), height: 1, indent: 64),
              _buildThemeOption(
                title: 'Light Mode',
                icon: Icons.light_mode_rounded,
                value: ThemeMode.light,
                groupValue: currentMode,
                theme: theme,
              ),
              Divider(color: theme.dividerColor.withValues(alpha: 0.4), height: 1, indent: 64),
              _buildThemeOption(
                title: 'Dark Mode',
                icon: Icons.dark_mode_rounded,
                value: ThemeMode.dark,
                groupValue: currentMode,
                theme: theme,
              ),
            ],
          );
        },
      ),
      theme,
    );
  }

  Widget _buildDashboardCard(ThemeData theme) {
    return _buildCardWrapper(
      Column(
        children: [
          ValueListenableBuilder<bool>(
            valueListenable: showFriendsNotifier,
            builder: (context, showFriends, _) {
              return SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                secondary: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.people_alt_rounded,
                    size: 20,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                title: const Text(
                  'Show Friends',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Display on the home screen',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                ),
                value: showFriends,
                activeThumbColor: Colors.white,
                activeTrackColor: theme.primaryColor,
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  showFriendsNotifier.value = val;
                  SettingsService.saveShowFriends(val);
                },
              );
            },
          ),
          Divider(color: theme.dividerColor.withValues(alpha: 0.4), height: 1, indent: 64),
          ValueListenableBuilder<bool>(
            valueListenable: showGroupsNotifier,
            builder: (context, showGroups, _) {
              return SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                secondary: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.groups_rounded,
                    size: 20,
                    color: theme.colorScheme.onSecondaryContainer,
                  ),
                ),
                title: const Text(
                  'Show Groups',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  'Display on the home screen',
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                ),
                value: showGroups,
                activeThumbColor: Colors.white, // Forces the thumb to be white
                activeTrackColor: theme.primaryColor, // Keeps the track purple/primary
                onChanged: (val) {
                  HapticFeedback.lightImpact();
                  showGroupsNotifier.value = val;
                  SettingsService.saveShowGroups(val);
                },
              );
            },
          ),
        ],
      ),
      theme,
    );
  }

  Widget _buildAccountCard(BuildContext context, ThemeData theme) {
    return _buildCardWrapper(
      ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: theme.colorScheme.errorContainer.withValues(alpha: 0.5),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.logout_rounded,
            size: 20,
            color: theme.colorScheme.error,
          ),
        ),
        title: Text(
          'Log out',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.error,
          ),
        ),
        onTap: () {
          HapticFeedback.lightImpact();
          _handleLogout(context);
        },
      ),
      theme,
    );
  }
}