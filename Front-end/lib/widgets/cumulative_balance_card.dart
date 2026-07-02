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
    final netBalance = totalOwed - totalOwe;

    // Determine text for net balance
    String netText = netBalance == 0
        ? 'Settled up'
        : (netBalance > 0 ? 'You are owed overall' : 'You owe overall');

    // Determine color for net balance
    final Color netColor = netBalance > 0
        ? const Color(0xFF69F0AE) // Bright Mint Green
        : netBalance < 0
        ? const Color(0xFFFF5252) // Bright Red
        : Colors.white;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor, primaryColor.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Label
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: Colors.white.withValues(alpha: 0.85),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Total Balance',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Main Net Balance (Colored)
          Text(
            'Ŧ${netBalance.abs().toInt()}',
            style: TextStyle(
              color: netColor,
              fontSize: 36,
              fontWeight: FontWeight.w800,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            netText,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 24),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 16),

          // Bottom Breakdown Row (Colored)
          Row(
            children: [
              _buildBreakdownItem(
                icon: Icons.arrow_upward_rounded,
                label: 'You are owed',
                amount: totalOwed,
                amountColor: totalOwed > 0
                    ? const Color(0xFF69F0AE)
                    : Colors.white.withValues(alpha: 0.7),
              ),
              Container(width: 1, height: 40, color: Colors.white24),
              _buildBreakdownItem(
                icon: Icons.arrow_downward_rounded,
                label: 'You owe',
                amount: totalOwe,
                amountColor: totalOwe > 0
                    ? const Color(0xFFFF5252)
                    : Colors.white.withValues(alpha: 0.7),
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
    required Color amountColor, // Added color parameter
  }) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: amountColor.withValues(
              alpha: 0.8,
            ), // Icon matches text color slightly faded
            size: 18,
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Ŧ${amount.toInt()}',
                style: TextStyle(
                  color: amountColor, // Applied dynamic color
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
