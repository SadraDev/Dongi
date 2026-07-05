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
    final primaryColor = Theme.of(context).primaryColor;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final netBalance = totalOwed - totalOwe;

    String netText = netBalance == 0
        ? 'Settled up'
        : (netBalance > 0 ? 'You are owed overall' : 'You owe overall');

    final Color netColor = netBalance > 0
        ? Colors.green.shade600
        : netBalance < 0
        ? Colors.red.shade400
        : (isDark ? Colors.grey.shade400 : Colors.grey.shade600);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: isDark ? 0.12 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primaryColor.withValues(alpha: isDark ? 0.3 : 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: primaryColor.withValues(alpha: 0.7),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'Total Balance',
                style: TextStyle(
                  color: primaryColor.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            netBalance == 0
                ? 'Ŧ0'
                : '${netBalance > 0 ? '+' : '-'}Ŧ${netBalance.abs().toStringAsFixed(netBalance.abs() == netBalance.abs().toInt() ? 0 : 2)}',
            style: TextStyle(
              color: netColor,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            netText,
            style: TextStyle(
              color: isDark ? Colors.grey.shade400 : Colors.grey.shade500,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            height: 1,
            color: primaryColor.withValues(alpha: 0.15),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBreakdownItem(
                icon: Icons.arrow_upward_rounded,
                label: 'You are owed',
                amount: totalOwed,
                activeColor: Colors.green.shade600,
                isDark: isDark,
              ),
              Container(
                width: 1,
                height: 36,
                color: primaryColor.withValues(alpha: 0.15),
              ),
              _buildBreakdownItem(
                icon: Icons.arrow_downward_rounded,
                label: 'You owe',
                amount: totalOwe,
                activeColor: Colors.red.shade400,
                isDark: isDark,
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
    required bool isDark,
  }) {
    final bool hasAmount = amount > 0;
    final Color iconColor = hasAmount
        ? activeColor.withValues(alpha: 0.7)
        : (isDark ? Colors.grey.shade600 : Colors.grey.shade400);
    final Color amountColor = hasAmount
        ? activeColor
        : (isDark ? Colors.grey.shade500 : Colors.grey.shade400);

    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 16),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Ŧ${amount.toStringAsFixed(amount == amount.toInt() ? 0 : 2)}',
                style: TextStyle(
                  color: amountColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}