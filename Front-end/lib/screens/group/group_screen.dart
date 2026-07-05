import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          child: Card(
            elevation: 0,
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
          Navigator.pop(context);
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Group deleted successfully'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              elevation: 0,
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
              backgroundColor: Colors.red.shade700,
              behavior: SnackBarBehavior.floating,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
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
                    enabled: !isInviting,
                    onSubmitted: (_) {
                      if (!isInviting) {
                        _performInvite(
                          ctx, usernameController, setState,
                              () => isInviting, (val) => isInviting = val,
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
                      ctx, usernameController, setState,
                          () => isInviting, (val) => isInviting = val,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isInviting
                      ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
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
          elevation: 0,
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
                Icon(Icons.check_circle_outline, color: Colors.white),
                SizedBox(width: 12),
                Text('Invitation sent to $username!'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        _fetchGroupData();
      }
    } catch (e) {
      setState(() => setInviting(false));
      if (context.mounted) {
        final String errorMessage = e.toString().replaceFirst('Exception: ', '');
        final Color snackBarColor = errorMessage == 'User does not exist'
            ? Colors.red.shade700
            : Colors.orange.shade700;

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white),
                SizedBox(width: 12),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: snackBarColor,
            behavior: SnackBarBehavior.floating,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        elevation: 0,
        actions: [
          PopupMenuButton<String>(
            tooltip: 'More Options',
            icon: const Icon(Icons.more_vert_rounded),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            onSelected: (value) {
              HapticFeedback.lightImpact();
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
                    Text('Invite Friend', style: TextStyle(fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
              if (widget.createdById == widget.currentUserId)
                const PopupMenuItem<String>(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                      SizedBox(width: 12),
                      Text('Delete Group', style: TextStyle(color: Colors.red, fontWeight: FontWeight.w500)),
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
            Container(
              height: 1,
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            ),
            Expanded(child: _buildExpensesList()),
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
        label: const Text('Add Expense'),
        elevation: 0,
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
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Icon(Icons.error_outline_rounded, size: 44, color: Colors.red.shade300),
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load group',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _fetchGroupData,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
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
          final isDark = Theme.of(context).brightness == Brightness.dark;

          final Color balanceColor = isPending
              ? Colors.orange
              : balance == 0
              ? (isDark ? Colors.grey.shade500 : Colors.grey.shade400)
              : (balance > 0 ? Colors.green.shade600 : Colors.red.shade400);

          final String balanceText = isPending
              ? 'Pending'
              : balance == 0
              ? 'Settled'
              : '${balance > 0 ? '+' : ''}${balance.toInt()}T';

          return Container(
            width: 130,
            margin: const EdgeInsets.symmetric(horizontal: 4.0),
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isPending
                    ? Colors.orange.withValues(alpha: 0.3)
                    : Theme.of(context).dividerColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: isPending
                        ? Colors.orange.withValues(alpha: 0.1)
                        : Theme.of(context).primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: isPending
                          ? Colors.orange.withValues(alpha: 0.2)
                          : Theme.of(context).primaryColor.withValues(alpha: 0.15),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    isPending ? Icons.schedule_rounded : Icons.person_rounded,
                    size: 16,
                    color: isPending
                        ? Colors.orange.shade600
                        : Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: isPending
                              ? Colors.orange.shade700
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        balanceText,
                        style: TextStyle(
                          color: balanceColor,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
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
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Icon(
                      Icons.receipt_long_rounded,
                      size: 48,
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No expenses yet',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the button below to add one',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey.shade500
                          : Colors.grey.shade500,
                      fontSize: 14,
                    ),
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

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
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
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: paidByMe
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: paidByMe
                                ? Colors.green.withValues(alpha: 0.2)
                                : Colors.orange.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Icon(
                          paidByMe
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          color: paidByMe
                              ? Colors.green.shade600
                              : Colors.orange.shade600,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              expense['title'] ?? 'Expense',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: Theme.of(context).primaryColor.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Text(
                          'T${amount.toInt()}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Splits List
                  if (visibleSplits.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.only(top: 14, bottom: 10),
                      child: Container(
                        height: 1,
                        color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: visibleSplits.length,
                      separatorBuilder: (context, index) =>
                      const SizedBox(height: 10),
                      itemBuilder: (context, splitIndex) => _buildSplitRow(
                        expense, splitIndex, paidByMe, visibleSplits,
                      ),
                    ),
                  ],
                ],
              ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Widget statusBadge = Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isPaid
            ? Colors.green.withValues(alpha: isDark ? 0.15 : 0.1)
            : Colors.orange.withValues(alpha: isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isPaid
              ? Colors.green.withValues(alpha: isDark ? 0.3 : 0.2)
              : Colors.orange.withValues(alpha: isDark ? 0.3 : 0.2),
        ),
      ),
      child: Text(
        isPaid ? 'Paid' : 'Unpaid',
        style: TextStyle(
          color: isPaid
              ? (isDark ? Colors.green.shade300 : Colors.green.shade700)
              : (isDark ? Colors.orange.shade300 : Colors.orange.shade800),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );

    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: TextStyle(
                    fontSize: 13,
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
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${name == 'You' ? 'owe' : 'owes'} T${amount.toInt()}',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
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
                    HapticFeedback.lightImpact();
                    final int recipientId = split['user'];

                    if (recipientId == 0) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Could not find user ID to send reminder.'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red,
                          elevation: 0,
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
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        );
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: Theme.of(context).primaryColor.withValues(alpha: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Pay up!',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ),

            // Status Badge
            if (paidByMe)
              InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  HapticFeedback.lightImpact();

                  final bool? confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      title: const Text(
                        'Mark as Paid?',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      content: Text(
                        'Mark ${split['name'] ?? 'this member'}\'s share of Ŧ${(split['amount'] ?? 0).toStringAsFixed(2)} as paid?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Mark Paid'),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;

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
                          elevation: 0,
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