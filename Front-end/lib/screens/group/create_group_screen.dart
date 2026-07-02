import 'package:flutter/material.dart';
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

  // 1. Change from static list to dynamic list
  List<dynamic> _availableFriends = [];
  bool _isFetchingFriends = true; // Added loading state for the list

  final Set<String> _selectedFriends = {};

  @override
  void initState() {
    super.initState();
    _fetchFriendsFromBackend();
  }

  // 2. Fetch the real list
  Future<void> _fetchFriendsFromBackend() async {
    try {
      final friends = await FriendService.getFriends();
      setState(() {
        _availableFriends = friends;
        _isFetchingFriends = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to load friends: $e')));
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
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }

    if (_selectedFriends.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one friend')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Calling the service we defined earlier
      await GroupService.createGroup(groupName, _selectedFriends.toList());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Group created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        // Pop with 'true' to signal to the HomeScreen that it needs to refresh
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
        actions: [
          // This is the button that triggers the creation logic
          _isLoading
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                  ),
                )
              : TextButton(
                  onPressed: _createGroup,
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).brightness == Brightness.light
                        ? Colors.white
                        : Colors.white,
                  ),
                  child: const Text(
                    'Create',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextField stays the same
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Group Name',
                prefixIcon: const Icon(Icons.group),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Add Members',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            // 3. Conditional rendering for the friends list
            Expanded(
              child: _isFetchingFriends
                  ? const Center(child: CircularProgressIndicator())
                  : _availableFriends.isEmpty
                  ? const Center(
                      child: Text("No friends found. Add some first!"),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: _availableFriends.length,
                      itemBuilder: (context, index) {
                        final friendUsername =
                            _availableFriends[index]['username'];
                        final isSelected = _selectedFriends.contains(
                          friendUsername,
                        );

                        return AnimatedContainer(
                          duration: const Duration(
                            milliseconds: 250,
                          ), // Smooth transition
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Theme.of(
                                    context,
                                  ).primaryColor.withValues(alpha: 0.1)
                                : Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected
                                  ? Theme.of(context).primaryColor
                                  : Theme.of(
                                      context,
                                    ).dividerColor.withValues(alpha: 0.2),
                              width: isSelected ? 2.5 : 1.5,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Theme.of(
                                        context,
                                      ).primaryColor.withValues(alpha: 0.2),
                                      blurRadius: 8,
                                      offset: const Offset(0, 4),
                                    ),
                                  ]
                                : [],
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
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
                                  CircleAvatar(
                                    backgroundColor: isSelected
                                        ? Theme.of(context).primaryColor
                                        : Theme.of(
                                            context,
                                          ).dividerColor.withValues(alpha: 0.2),
                                    child: Icon(
                                      isSelected
                                          ? Icons.check
                                          : Icons.person_outline,
                                      color: isSelected
                                          ? Colors.white
                                          : Theme.of(context).iconTheme.color,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Text(
                                    friendUsername,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Theme.of(context).primaryColor
                                          : null,
                                    ),
                                  ),
                                  const Spacer(),
                                  if (isSelected)
                                    Icon(
                                      Icons.check_circle,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                ],
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
}
