import 'package:flutter/material.dart';
import '../../services/group_service.dart';
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Group?'),
        content: const Text(
          'Are you sure you want to delete this group? All expenses and balances will be permanently lost. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
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
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );

      try {
        await GroupService.deleteGroup(widget.groupId);

        if (mounted) {
          Navigator.pop(context); // Pop loading
          Navigator.pop(context, true); // Pop screen, signal refresh
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Group deleted successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  void _showInviteDialog(BuildContext context) {
    final TextEditingController usernameController = TextEditingController();
    bool isInviting = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Invite Friend'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Enter the username of the person you want to invite to this group.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      hintText: 'e.g., johndoe',
                      prefixIcon: const Icon(Icons.person_outline_rounded),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    enabled: !isInviting,
                    onSubmitted: (_) {
                      if (!isInviting) {
                        _performInvite(
                          ctx,
                          usernameController,
                          setState,
                          () => isInviting = true,
                          (val) => isInviting = val,
                        );
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: isInviting ? null : () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: isInviting
                      ? null
                      : () {
                          _performInvite(
                            ctx,
                            usernameController,
                            setState,
                            () => isInviting = true,
                            (val) => isInviting = val,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                  child: isInviting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Invite'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Extracted invite logic to handle both button press and enter key
  void _performInvite(
    BuildContext ctx,
    TextEditingController controller,
    StateSetter setState,
    bool Function() getInviting,
    void Function(bool) setInviting,
  ) async {
    final username = controller.text.trim();
    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a username'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => setInviting(true));
    try {
      await GroupService.inviteFriendToGroup(widget.groupId, username);

      if (ctx.mounted) Navigator.pop(ctx);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Invitation sent to $username!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
        _fetchGroupData();
      }
    } catch (e) {
      setState(() => setInviting(false));
      if (context.mounted) {
        // 1. Extract the clean error message without the "Exception: " prefix
        final String errorMessage = e.toString().replaceFirst(
          'Exception: ',
          '',
        );

        // 2. Determine the color based on the message
        final Color snackBarColor = errorMessage == 'User does not exist'
            ? Colors.red.shade700
            : Colors.orange.shade700;

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: snackBarColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.groupName,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'More Options',
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'delete') {
                _confirmDelete(context);
              } else if (value == 'invite') {
                _showInviteDialog(context);
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'invite',
                child: Row(
                  children: [
                    Icon(Icons.person_add_alt_1_rounded, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Invite Friend',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              if (widget.createdById == widget.currentUserId)
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                        size: 20,
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Delete Group',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : RefreshIndicator(
              color: Theme.of(context).primaryColor,
              onRefresh: _fetchGroupData,
              child: Column(
                children: [
                  _buildBalancesHeader(),
                  const Divider(height: 1),
                  Expanded(child: _buildExpensesList()),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddPaymentScreen(
                groupId: widget.groupId,
                groupName: widget.groupName,
                members: _memberBalances,
                currentUserId: widget.currentUserId,
              ),
              fullscreenDialog: true,
            ),
          );
          if (result == true) {
            _fetchGroupData();
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Expense'),
        elevation: 4,
      ),
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
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red.shade300,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load group',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchGroupData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalancesHeader() {
    if (_memberBalances.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(child: Text('No members found.')),
      );
    }

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        itemCount: _memberBalances.length,
        itemBuilder: (context, index) {
          final member = _memberBalances[index];

          final String name = member['name'] ?? 'Unknown';
          final double balance = (member['balance'] ?? 0).toDouble();
          final String status = member['status'] ?? 'pending';
          final bool isPending = status == 'pending';

          // Dynamic Colors
          final Color backgroundColor = isPending
              ? Theme.of(context).scaffoldBackgroundColor
              : Theme.of(context).cardColor;

          final Color balanceColor = isPending
              ? Colors.orange
              : balance == 0
              ? Colors.grey
              : (balance > 0 ? Colors.green.shade600 : Colors.red.shade600);

          final String balanceText = isPending
              ? 'Pending'
              : balance == 0
              ? 'Settled'
              : '${balance > 0 ? '+' : ''}${balance.toInt()}Ŧ';

          return Container(
            width: 140,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isPending
                    ? Colors.orange.withValues(alpha: 0.3)
                    : Theme.of(context).dividerColor.withValues(alpha: 0.4),
              ),
            ),
            child: Row(
              children: [
                // Avatar Circle
                CircleAvatar(
                  radius: 18,
                  backgroundColor: isPending
                      ? Colors.orange.withValues(alpha: 0.1)
                      : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  child: Icon(
                    isPending ? Icons.schedule_rounded : Icons.person_rounded,
                    size: 18,
                    color: isPending
                        ? Colors.orange.shade600
                        : Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          color: isPending ? Colors.orange.shade700 : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        balanceText,
                        style: TextStyle(
                          color: balanceColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpensesList() {
    if (_expenses.isEmpty) {
      return ListView(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      size: 56,
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No expenses yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to add one',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      itemCount: _expenses.length,
      itemBuilder: (context, index) {
        final expense = _expenses[index];
        final bool paidByMe = expense['paidByMe'] ?? false;
        final String payerName = expense['payerName'] ?? 'Someone';
        final String subtitle = paidByMe ? 'Paid by You' : 'Paid by $payerName';
        final double amount = (expense['amount'] ?? 0).toDouble();

        final List<dynamic> visibleSplits = (expense['splits'] ?? []).where((
          split,
        ) {
          final dynamic rawAmount = split['amount'];
          final int splitAmount = rawAmount is num ? rawAmount.toInt() : 0;
          return splitAmount > 0;
        }).toList();

        return Card(
          margin: const EdgeInsets.only(bottom: 16.0),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: paidByMe
                            ? Colors.green.shade50
                            : Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        paidByMe
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        color: paidByMe
                            ? Colors.green.shade600
                            : Colors.orange.shade600,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            expense['title'] ?? 'Expense',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        'Ŧ${amount.toInt()}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),

                // Splits List
                if (visibleSplits.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(top: 14, bottom: 10),
                    child: Divider(height: 1),
                  ),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: visibleSplits.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, splitIndex) => _buildSplitRow(
                      expense,
                      splitIndex,
                      paidByMe,
                      visibleSplits,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
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

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    // Clean modern badges
    final Color paidBgColor = Colors.green.withValues(
      alpha: isDark ? 0.15 : 0.1,
    );
    final Color pendingBgColor = Colors.orange.withValues(
      alpha: isDark ? 0.15 : 0.1,
    );

    final Color paidTextColor = isDark
        ? Colors.green.shade300
        : Colors.green.shade700;
    final Color pendingTextColor = isDark
        ? Colors.orange.shade300
        : Colors.orange.shade800;

    Widget statusBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPaid ? paidBgColor : pendingBgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isPaid ? 'Paid' : 'Pending',
        style: TextStyle(
          color: isPaid ? paidTextColor : pendingTextColor,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    return Row(
      children: [
        // Left Side: Avatar + Info
        Expanded(
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.1),
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
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
                    Text(
                      '${name == 'You' ? 'owe' : 'owes'} Ŧ${amount.toInt()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Right Side: Actions
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (paidByMe && !isPaid)
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: OutlinedButton(
                  onPressed: () async {
                    final int recipientId = split['user'];

                    if (recipientId == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Could not find user ID to send reminder.',
                          ),
                          behavior: SnackBarBehavior.floating,
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
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.green.shade600,
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Failed to send reminder: $e'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: Colors.red.shade700,
                          ),
                        );
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(
                        context,
                      ).primaryColor.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'Pay up!',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),

            // Status Badge (Tappable if paidByMe for optimistic UI update)
            if (paidByMe)
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () async {
                  setState(() {
                    split['isPaid'] = true;
                  });

                  try {
                    await GroupService.toggleExpenseSplitStatus(splitId, true);
                  } catch (e) {
                    setState(() {
                      split['isPaid'] = false;
                    });
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to update status'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
                child: statusBadge,
              )
            else
              statusBadge,
          ],
        ),
      ],
    );
  }
}
