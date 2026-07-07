import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

class _GroupScreenState extends State<GroupScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  List<dynamic> _memberBalances = [];
  List<dynamic> _expenses = [];

  @override
  void initState() {
    super.initState();
    _fetchGroupData();
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

  Future<void> _confirmDelete(BuildContext context) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Delete Group?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Are you sure you want to delete this group? All expenses and balances will be permanently lost. This action cannot be undone.',
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
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        await GroupService.deleteGroup(widget.groupId);

        if (mounted) {
          Navigator.pop(context); // close loading
          Navigator.pop(context, true); // go back
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Group deleted successfully'),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          );
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

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            // Initial fetch of my friends list
            if (isDialogLoading && myFriends.isEmpty) {
              FriendService.getFriends().then((friends) {
                if (ctx.mounted) {
                  setDialogState(() {
                    myFriends = friends;
                    isDialogLoading = false;
                  });
                }
              }).catchError((_) {
                if (ctx.mounted) {
                  setDialogState(() => isDialogLoading = false);
                }
              });
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: const Text(
                'Add to Group',
                style: TextStyle(fontWeight: FontWeight.bold),
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
                      decoration: InputDecoration(
                        hintText: 'Search by username...',
                        prefixIcon: const Icon(Icons.search_rounded),
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: Theme.of(context).primaryColor,
                            width: 2,
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      enabled: !isInviting,
                      onChanged: (val) {
                        if (debounce?.isActive ?? false) debounce!.cancel();
                        debounce = Timer(const Duration(milliseconds: 300), () async {
                          if (val.trim().isEmpty) {
                            setDialogState(() => firstFoundUser = null);
                            return;
                          }
                          try {
                            final results = await FriendService.searchUsers(val.trim());
                            setDialogState(() {
                              // Filter and strictly pick only the first match
                              firstFoundUser = results.isNotEmpty ? results.first : null;
                            });
                          } catch (_) {}
                        });
                      },
                    ),
                    const SizedBox(height: 16),

                    // Display Section: Dynamic Search Result or Friends List
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 220),
                      child: isDialogLoading
                          ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                      )
                          : SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (searchController.text.trim().isNotEmpty) ...[
                              Text(
                                'Search Result',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (firstFoundUser != null)
                                _buildListItem(
                                  username: firstFoundUser['username'],
                                  isFriend: myFriends.any((f) => f['username'] == firstFoundUser['username']),
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
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    'No matching user found.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                            ] else ...[
                              Text(
                                'My Friends',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (myFriends.isEmpty)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    'Your friends directory is empty.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                )
                              else
                                ListView.separated(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: myFriends.length,
                                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                                  itemBuilder: (context, idx) {
                                    final fName = myFriends[idx]['username'];
                                    return _buildListItem(
                                      username: fName,
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
              actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              actions: [
                TextButton(
                  onPressed: isInviting ? null : () => Navigator.pop(ctx),
                  child: const Text('Close'),
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
    required bool isFriend,
    required bool isInviting,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.2)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        leading: CircleAvatar(
          radius: 16,
          backgroundColor: theme.primaryColor.withValues(alpha: 0.15),
          child: Text(
            username[0].toUpperCase(),
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: theme.primaryColor),
          ),
        ),
        title: Text(
          username,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: FilledButton.tonal(
          onPressed: isInviting ? null : onTap,
          style: FilledButton.styleFrom(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(
            isFriend ? 'Invite' : 'Add & Invite',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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

    final bool isAlreadyFriend = myFriends.any((f) => f['username'] == username);
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(operationSummary)),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _fetchGroupData();
      }
    } catch (e) {
      setDialogState(() => setInviting(false));
      if (context.mounted) {
        final String errorMessage = e.toString().replaceFirst('Exception: ', '');
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : RefreshIndicator(
        color: Theme.of(context).primaryColor,
        onRefresh: _fetchGroupData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            _buildSliverAppBar(),
            SliverToBoxAdapter(
              child: _buildBalancesSection(),
            ),
            _buildExpensesSection(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
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
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  SliverAppBar _buildSliverAppBar() {
    return SliverAppBar.large(
      pinned: true,
      stretch: true,
      expandedHeight: 160,
      backgroundColor: Theme.of(context).colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Text(
          widget.groupName,
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Theme.of(context).colorScheme.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Theme.of(context).primaryColor.withValues(alpha: 0.1),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          tooltip: 'Invite Friend',
          icon: const Icon(Icons.person_add_alt_1_rounded),
          onPressed: () {
            HapticFeedback.lightImpact();
            _showInviteDialog(context);
          },
        ),
        if (widget.createdById == widget.currentUserId)
          IconButton(
            tooltip: 'Delete Group',
            icon: const Icon(Icons.delete_outline_rounded),
            color: Theme.of(context).colorScheme.error,
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Failed to load group',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'An unknown error occurred.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: _fetchGroupData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalancesSection() {
    if (_memberBalances.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text('No members found.'),
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
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                  ? Colors.orange.shade600
                  : balance == 0
                  ? Theme.of(context).colorScheme.onSurfaceVariant
                  : (balance > 0
                  ? Colors.green.shade600
                  : Theme.of(context).colorScheme.error);

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
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(24),
                  border: isPending
                      ? Border.all(color: Colors.orange.shade300, width: 1.5)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: isPending
                              ? Colors.orange.shade100
                              : Theme.of(context).primaryColor.withValues(alpha: 0.2),
                          child: Icon(
                            isPending ? Icons.hourglass_top_rounded : Icons.person_rounded,
                            size: 16,
                            color: isPending
                                ? Colors.orange.shade800
                                : Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
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
                      style: TextStyle(
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
    if (_expenses.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.receipt_long_rounded,
                size: 64,
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 24),
              Text(
                'No expenses yet',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the button below to add one',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 16),
                child: Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            final expenseIndex = index - 1;
            final expense = _expenses[expenseIndex];
            return _buildExpenseCard(expense);
          },
          childCount: _expenses.length + 1,
        ),
      ),
    );
  }

  Widget _buildExpenseCard(Map<String, dynamic> expense) {
    final bool paidByMe = expense['paidByMe'] ?? false;
    final String payerName = expense['payerName'] ?? 'Someone';
    final double amount = (expense['amount'] ?? 0).toDouble();

    final List<dynamic> visibleSplits = (expense['splits'] ?? []).where((split) {
      final dynamic rawAmount = split['amount'];
      final int splitAmount = rawAmount is num ? rawAmount.toInt() : 0;
      return splitAmount > 0;
    }).toList();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: paidByMe
                        ? Colors.green.shade100
                        : Colors.orange.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    paidByMe
                        ? Icons.arrow_upward_rounded
                        : Icons.arrow_downward_rounded,
                    color: paidByMe
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        paidByMe ? 'Paid by You' : 'Paid by $payerName',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Ŧ${amount.toInt()}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            // Splits Section
            if (visibleSplits.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(12),
                  itemCount: visibleSplits.length,
                  separatorBuilder: (context, index) => const Divider(height: 16),
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
    );
  }

  Widget _buildSplitRow(
      Map<String, dynamic> expense,
      int splitIndex,
      bool paidByMe,
      List<dynamic> splits,
      ) {
    final split = splits[splitIndex];
    final bool isPaid = split['isPaid'] ?? false;
    final String name = split['name'] ?? 'Unknown';
    final int amount = (split['amount'] ?? 0).toInt();
    final int splitId = split['id'] ?? 0;

    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSecondaryContainer,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  children: [
                    const TextSpan(text: 'owes '),
                    TextSpan(
                      text: 'Ŧ$amount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Actions / Status
        if (paidByMe && !isPaid)
          FilledButton.tonal(
            onPressed: () async {
              HapticFeedback.lightImpact();
              final int recipientId = split['user'];

              if (recipientId == 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Could not find user ID to send reminder.'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              try {
                await NotificationService.sendPaymentReminder(
                  recipientId: recipientId,
                  groupId: widget.groupId,
                );

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Reminded $name to Pay up!'),
                      backgroundColor: Colors.green.shade600,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to send reminder: $e'),
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                  );
                }
              }
            },
            style: FilledButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: const Text('Remind'),
          ),

        if (paidByMe)
          const SizedBox(width: 8),

        if (paidByMe)
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () async {
              HapticFeedback.lightImpact();
              final bool? confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  title: Text(isPaid ? 'Mark as Unpaid?' : 'Mark as Paid?'),
                  content: Text(
                    isPaid
                        ? 'Mark ${split['name'] ?? 'this member'}\'s share of Ŧ${(split['amount'] ?? 0)} as unpaid?'
                        : 'Mark ${split['name'] ?? 'this member'}\'s share of Ŧ${(split['amount'] ?? 0)} as paid?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: FilledButton.styleFrom(
                        backgroundColor: isPaid ? Colors.orange.shade600 : Colors.green.shade600,
                      ),
                      child: Text(isPaid ? 'Mark Unpaid' : 'Mark Paid'),
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
              } catch (e) {
                setState(() {
                  split['isPaid'] = isPaid; // Revert on failure
                });
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Failed to update status')),
                  );
                }
              }
            },
            child: _buildStatusBadge(isPaid, context),
          )
        else
          _buildStatusBadge(isPaid, context),
      ],
    );
  }

  Widget _buildStatusBadge(bool isPaid, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPaid
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaid
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        isPaid ? 'Paid' : 'Unpaid',
        style: TextStyle(
          color: isPaid ? Colors.green.shade700 : Colors.orange.shade800,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}