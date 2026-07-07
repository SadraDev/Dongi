import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/friend_service.dart';
import '../../services/group_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isLoading = false;

  List<dynamic> _availableFriends = [];
  bool _isFetchingFriends = true;

  final Set<String> _selectedFriends = {};

  @override
  void initState() {
    super.initState();
    _fetchFriendsFromBackend();
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

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
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
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white),
                SizedBox(width: 12),
                Text('Group created successfully!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        );
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
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        slivers: [
          _buildSliverAppBar(theme),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildNameInput(theme),
                  const SizedBox(height: 32),
                  Text(
                    'Add Members',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildFriendsList(theme),
          // Add bottom padding for the FAB
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
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
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
          'New Group',
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

  Widget _buildNameInput(ThemeData theme) {
    return TextField(
      controller: _nameController,
      textCapitalization: TextCapitalization.words,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: 'Group Name',
        hintText: 'e.g., Weekend Trip',
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        prefixIcon: Icon(
          Icons.groups_rounded,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        floatingLabelBehavior: FloatingLabelBehavior.always,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      ),
      enabled: !_isLoading,
    );
  }

  Widget _buildFriendsList(ThemeData theme) {
    if (_isFetchingFriends) {
      return const SliverFillRemaining(
        hasScrollBody: false,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_availableFriends.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: _buildNoFriendsState(theme),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final friendUsername = _availableFriends[index]['username'];
            final isSelected = _selectedFriends.contains(friendUsername);

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                elevation: 0,
                color: isSelected
                    ? theme.primaryColor.withValues(alpha: 0.1)
                    : theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? theme.primaryColor.withValues(alpha: 0.5)
                        : theme.dividerColor.withValues(alpha: 0.4),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
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
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: isSelected
                              ? theme.primaryColor
                              : theme.colorScheme.secondaryContainer,
                          child: Text(
                            friendUsername[0].toUpperCase(),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: isSelected
                                  ? theme.colorScheme.onPrimary
                                  : theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // Name
                        Expanded(
                          child: Text(
                            friendUsername,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                          ),
                        ),

                        // Check Icon
                        AnimatedScale(
                          scale: isSelected ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Icon(
                            Icons.check_circle_rounded,
                            color: theme.primaryColor,
                            size: 26,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
          childCount: _availableFriends.length,
        ),
      ),
    );
  }

  Widget _buildNoFriendsState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_add_disabled_rounded,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No friends found',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some friends first to create a group!',
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