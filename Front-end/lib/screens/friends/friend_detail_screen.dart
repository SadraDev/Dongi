import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/friend_service.dart';
import '../../services/group_service.dart';
import '../../services/notification_service.dart';
import '../group/add_payment.dart';

class FriendDetailScreen extends StatefulWidget {
  final int friendId;
  final String friendName;
  final int currentUserId;

  const FriendDetailScreen({
    super.key,
    required this.friendId,
    required this.friendName,
    required this.currentUserId,
  });

  @override
  State<FriendDetailScreen> createState() => _FriendDetailScreenState();
}

class _FriendDetailScreenState extends State<FriendDetailScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  double _netBalance = 0.0;
  List<dynamic> _expenses = [];

  @override
  void initState() {
    super.initState();
    _fetchFriendData();
  }

  Future<void> _fetchFriendData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final data = await FriendService.getFriendDetails(widget.friendId);

      if (mounted) {
        setState(() {
          _netBalance = (data['friend']['balance'] ?? 0).toDouble();
          _expenses = data['expenses'] ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString().replaceFirst('Exception: ', '');
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? _buildErrorState()
          : RefreshIndicator(
        color: theme.primaryColor,
        onRefresh: _fetchFriendData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          slivers: [
            _buildSliverAppBar(theme),
            SliverToBoxAdapter(
              child: _buildBalanceHeader(theme),
            ),
            _buildExpensesSection(theme),
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
                    groupId: null, // Direct expense
                    friendId: widget.friendId,
                    groupName: 'Direct with ${widget.friendName}',
                    members: [
                      {
                        'id': widget.friendId,
                        'name': widget.friendName,
                        'status': 'accepted'
                      }
                    ],
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
            _fetchFriendData();
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

  SliverAppBar _buildSliverAppBar(ThemeData theme) {
    return SliverAppBar.large(
      pinned: true,
      stretch: true,
      expandedHeight: 160,
      backgroundColor: theme.colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: theme.colorScheme.secondaryContainer,
              child: Text(
                widget.friendName.isNotEmpty ? widget.friendName[0].toUpperCase() : '?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              widget.friendName,
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
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
                theme.primaryColor.withValues(alpha: 0.1),
                theme.colorScheme.surface,
              ],
            ),
          ),
        ),
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
              'Failed to load details',
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
              onPressed: _fetchFriendData,
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

  Widget _buildBalanceHeader(ThemeData theme) {
    final bool isZero = _netBalance == 0;
    final bool isPositive = _netBalance > 0;

    final Color balanceColor = isZero
        ? theme.colorScheme.onSurfaceVariant
        : (isPositive ? Colors.green.shade600 : theme.colorScheme.error);

    final String statusText = isZero
        ? 'You and ${widget.friendName} are settled up'
        : (isPositive ? '${widget.friendName} owes you' : 'You owe ${widget.friendName}');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.dividerColor.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          children: [
            Text(
              statusText,
              style: TextStyle(
                color: theme.colorScheme.onSurfaceVariant,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isZero
                  ? 'Ŧ0'
                  : '${isPositive ? '+' : '-'}Ŧ${_netBalance.abs().toStringAsFixed(_netBalance.abs() == _netBalance.abs().toInt() ? 0 : 2)}',
              style: TextStyle(
                color: balanceColor,
                fontSize: 42,
                fontWeight: FontWeight.w900,
                letterSpacing: -1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesSection(ThemeData theme) {
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
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              const SizedBox(height: 24),
              Text(
                'No shared expenses',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the button below to add one',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
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
                  'Transaction History',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }
            final expenseIndex = index - 1;
            final expense = _expenses[expenseIndex];
            return _buildExpenseCard(expense, theme);
          },
          childCount: _expenses.length + 1,
        ),
      ),
    );
  }

  Widget _buildExpenseCard(Map<String, dynamic> expense, ThemeData theme) {
    final bool paidByMe = expense['paidByMe'] ?? false;
    final String payerName = expense['payerName'] ?? 'Someone';
    final double amount = (expense['amount'] ?? 0).toDouble();
    final String groupName = expense['groupName'] ?? 'Direct Expense';

    final List<dynamic> visibleSplits = (expense['splits'] ?? []).where((split) {
      final dynamic rawAmount = split['amount'];
      final int splitAmount = rawAmount is num ? rawAmount.toInt() : 0;
      return splitAmount > 0;
    }).toList();

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: theme.dividerColor.withValues(alpha: 0.4),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Context pill (shows which group this is from)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.fromLTRB(0, 0, 0, 12),
              decoration: BoxDecoration(
                color: theme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                groupName.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: theme.primaryColor,
                  letterSpacing: 0.5,
                ),
              ),
            ),
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
                          color: theme.colorScheme.onSurfaceVariant,
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
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),

            // Splits Section
            if (visibleSplits.isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
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
                    theme,
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
      ThemeData theme,
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
          backgroundColor: theme.colorScheme.secondaryContainer,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : '?',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSecondaryContainer,
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
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  children: [
                    const TextSpan(text: 'owes '),
                    TextSpan(
                      text: 'Ŧ$amount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
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
                  expenseId: expense['id'],
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
                      backgroundColor: theme.colorScheme.error,
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

        if (paidByMe) const SizedBox(width: 8),

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
                        backgroundColor: isPaid
                            ? Colors.orange.shade600
                            : Colors.green.shade600,
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
                _fetchFriendData(); // Refresh the net balance overview
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
            child: _buildStatusBadge(isPaid, theme),
          )
        else
          _buildStatusBadge(isPaid, theme),
      ],
    );
  }

  Widget _buildStatusBadge(bool isPaid, ThemeData theme) {
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