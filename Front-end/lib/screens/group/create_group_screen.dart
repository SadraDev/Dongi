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
      setState(() {
        _availableFriends = friends;
        _isFetchingFriends = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load friends: $e'),
            behavior: SnackBarBehavior.floating,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _createGroup() async {
    final groupName = _nameController.text.trim();

    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a group name'),
          behavior: SnackBarBehavior.floating,
          elevation: 0,
        ),
      );
      return;
    }

    if (_selectedFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one friend'),
          behavior: SnackBarBehavior.floating,
          elevation: 0,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await GroupService.createGroup(groupName, _selectedFriends.toList());

      if (mounted) {
        HapticFeedback.mediumImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Group created successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group',
            style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        actions: [
          _isLoading
              ? const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
              : TextButton(
            onPressed: _createGroup,
            child: const Text(
              'Create',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Name Input
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                prefixIcon: const Icon(Icons.group_rounded, size: 20),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section header
            Text(
              'Add Members',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),

            // Friends List
            Expanded(
              child: _isFetchingFriends
                  ? const Center(child: CircularProgressIndicator())
                  : _availableFriends.isEmpty
                  ? _buildNoFriendsState()
                  : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _availableFriends.length,
                itemBuilder: (context, index) {
                  final friendUsername =
                  _availableFriends[index]['username'];
                  final isSelected =
                  _selectedFriends.contains(friendUsername);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context)
                            .primaryColor
                            .withValues(alpha: 0.1)
                            : Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Theme.of(context)
                              .dividerColor
                              .withValues(alpha: 0.3),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
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
                              horizontal: 16, vertical: 14,
                            ),
                            child: Row(
                              children: [
                                // Selection Indicator
                                AnimatedContainer(
                                  duration:
                                  const Duration(milliseconds: 250),
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Colors.transparent,
                                    borderRadius:
                                    BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : (isDark
                                          ? Colors.grey.shade600
                                          : Colors.grey.shade400),
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: isSelected
                                      ? Icon(Icons.check_rounded,
                                      size: 16,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary)
                                      : null,
                                ),
                                const SizedBox(width: 14),
                                // Avatar
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Theme.of(context)
                                        .primaryColor
                                        .withValues(alpha: 0.15)
                                        : (isDark
                                        ? Colors.grey.shade800
                                        : Colors.grey.shade100),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    friendUsername[0].toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : (isDark
                                          ? Colors.grey.shade400
                                          : Colors.grey.shade600),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                // Name
                                Expanded(
                                  child: Text(
                                    friendUsername,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isSelected
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                    ),
                                  ),
                                ),
                                // Check icon
                                if (isSelected)
                                  Icon(
                                    Icons.check_circle_rounded,
                                    color: Theme.of(context).primaryColor,
                                    size: 22,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoFriendsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade800
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(
              Icons.person_add_disabled_rounded,
              size: 40,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade600
                  : Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No friends found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add some friends first!',
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey.shade500
                  : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}