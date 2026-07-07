import 'package:flutter/material.dart';

class CumulativeBalanceCard extends StatelessWidget {
  final double totalOwed;
  final double totalOwe;

  const CumulativeBalanceCard({
    super.key,
    required this.totalOwed,
    required this.totalOwe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final netBalance = totalOwed - totalOwe;

    final Color netColor = netBalance > 0
        ? Colors.green.shade600
        : netBalance < 0
        ? theme.colorScheme.error
        : theme.colorScheme.onSurfaceVariant;

    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: theme.colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Total Balance',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            netBalance == 0
                ? 'Ŧ0'
                : '${netBalance > 0 ? '+' : '-'}Ŧ${netBalance.abs().toStringAsFixed(netBalance.abs() == netBalance.abs().toInt() ? 0 : 2)}',
            style: TextStyle(
              color: netColor,
              fontSize: 38,
              fontWeight: FontWeight.w900,
              letterSpacing: -1.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            netBalance == 0
                ? 'Everything is settled'
                : (netBalance > 0 ? 'Overall, you are owed' : 'Overall, you owe'),
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          Divider(color: theme.dividerColor.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBreakdownItem(
                icon: Icons.arrow_upward_rounded,
                label: 'Owed to you',
                amount: totalOwed,
                activeColor: Colors.green.shade600,
                context: context,
              ),
              Container(
                width: 1,
                height: 40,
                color: theme.dividerColor.withValues(alpha: 0.5),
              ),
              _buildBreakdownItem(
                icon: Icons.arrow_downward_rounded,
                label: 'You owe',
                amount: totalOwe,
                activeColor: theme.colorScheme.error,
                context: context,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownItem({
    required IconData icon,
    required String label,
    required double amount,
    required Color activeColor,
    required BuildContext context,
  }) {
    final theme = Theme.of(context);
    final bool hasAmount = amount > 0;

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: hasAmount ? activeColor : theme.colorScheme.onSurfaceVariant,
            size: 18,
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Ŧ${amount.toStringAsFixed(amount == amount.toInt() ? 0 : 2)}',
                style: TextStyle(
                  color: hasAmount ? activeColor : theme.colorScheme.onSurface,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}