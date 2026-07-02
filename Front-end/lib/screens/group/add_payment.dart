import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/group_service.dart';

class AddPaymentScreen extends StatefulWidget {
  final int groupId;
  final String groupName;
  final List<dynamic> members;
  final int currentUserId;

  const AddPaymentScreen({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.members,
    required this.currentUserId,
  });

  @override
  State<AddPaymentScreen> createState() => _AddPaymentScreenState();
}

class _AddPaymentScreenState extends State<AddPaymentScreen> {
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _divideEqually = true;
  bool _isSaving = false;

  List<Map<String, dynamic>> _allMembers = [];
  final Map<int, TextEditingController> _customSplitControllers = {};

  @override
  void initState() {
    super.initState();
    _allMembers = [
      {'id': widget.currentUserId, 'name': 'You'},
      ...widget.members
          .where((m) => m['status'] == 'accepted')
          .map((m) => {'id': m['id'], 'name': m['name']}),
    ];

    for (var member in _allMembers) {
      _customSplitControllers[member['id']] = TextEditingController();
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    _scrollController.dispose();
    for (var controller in _customSplitControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  double _getTotalSplits() {
    double total = 0;
    for (var controller in _customSplitControllers.values) {
      total += double.tryParse(controller.text.trim()) ?? 0;
    }
    return total;
  }

  int _getUnfilledSplitCount() {
    int count = 0;
    for (var controller in _customSplitControllers.values) {
      if (controller.text.trim().isEmpty) count++;
    }
    return count;
  }

  Future<void> _savePayment() async {
    if (_isSaving) return;

    HapticFeedback.lightImpact();

    final description = _descController.text.trim();
    final amountText = _amountController.text.trim();

    if (description.isEmpty) {
      _showError('Please enter a description');
      return;
    }

    if (amountText.isEmpty) {
      _showError('Please enter an amount');
      return;
    }

    final double? totalAmount = double.tryParse(amountText);
    if (totalAmount == null || totalAmount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    List<Map<String, dynamic>>? customSplitsData;

    if (!_divideEqually) {
      final unfilled = _getUnfilledSplitCount();
      if (unfilled > 0) {
        _showError('Please fill in all split amounts ($unfilled remaining)');
        return;
      }

      customSplitsData = [];
      double splitSum = 0;

      for (var member in _allMembers) {
        final int userId = member['id'];
        final String inputVal = _customSplitControllers[userId]!.text.trim();
        final double splitAmount = double.tryParse(inputVal) ?? 0;

        splitSum += splitAmount;
        customSplitsData.add({'user_id': userId, 'amount_owed': splitAmount});
      }

      if ((splitSum - totalAmount).abs() > 0.01) {
        _showError(
          'Splits total (Ŧ${splitSum.toStringAsFixed(2)}) doesn\'t match amount (Ŧ${totalAmount.toStringAsFixed(2)})',
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      await GroupService.addExpense(
        groupId: widget.groupId,
        description: description,
        totalAmount: totalAmount,
        divideEqually: _divideEqually,
        customSplits: customSplitsData,
      );

      if (mounted) {
        HapticFeedback.mediumImpact();
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showError('Failed to save: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        // Save button removed from here
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          80,
        ), // Added bottom padding for FAB
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.group_rounded,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.groupName,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Amount Field (Added onChanged for live UI updates)
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => setState(() {}), // <-- LIVE UPDATE TRIGGER
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
              decoration: InputDecoration(
                prefixText: 'Ŧ ',
                prefixStyle: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
                labelText: 'Amount',
                labelStyle: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
              enabled: !_isSaving,
            ),
            const SizedBox(height: 16),

            // Description Field
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Dinner at Mario\'s',
                prefixIcon: const Icon(Icons.receipt_long_outlined),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                filled: true,
                fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade50,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 2,
                  ),
                ),
              ),
              textCapitalization: TextCapitalization.sentences,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 20),

            // Split Type Toggle
            Container(
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _buildSplitTypeButton(
                    label: 'Equal Split',
                    icon: Icons.equalizer_rounded,
                    isSelected: _divideEqually,
                    onTap: _isSaving
                        ? null
                        : () => setState(() => _divideEqually = true),
                  ),
                  _buildSplitTypeButton(
                    label: 'Custom Split',
                    icon: Icons.tune_rounded,
                    isSelected: !_divideEqually,
                    onTap: _isSaving
                        ? null
                        : () {
                            setState(() => _divideEqually = false);
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () {
                                _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOut,
                                );
                              },
                            );
                          },
                  ),
                ],
              ),
            ),

            // Custom Splits
            if (!_divideEqually) ...[
              const SizedBox(height: 20),
              _buildCustomSplitsSection(),
            ],

            // Extra bottom space so the FAB doesn't cover the last input
            const SizedBox(height: 20),
          ],
        ),
      ),
      // Save button moved here as a FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _savePayment,
        icon: _isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.check_rounded),
        label: Text(_isSaving ? 'Saving...' : 'Save Expense'),
        elevation: 4,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildSplitTypeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).primaryColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).primaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomSplitsSection() {
    final totalAmount = double.tryParse(_amountController.text.trim()) ?? 0;
    final totalSplits = _getTotalSplits();
    final difference = totalAmount - totalSplits;
    final isBalanced = (difference).abs() < 0.01 && totalAmount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Custom Split',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            if (totalAmount > 0)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isBalanced
                      ? Colors.green.shade50
                      : Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isBalanced
                      ? 'Balanced ✓'
                      : 'Remaining: Ŧ${difference.abs().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isBalanced
                        ? Colors.green.shade700
                        : Colors.orange.shade700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ..._allMembers.map((member) => _buildCustomSplitRow(member)),
      ],
    );
  }

  Widget _buildCustomSplitRow(Map<String, dynamic> member) {
    final int userId = member['id'];
    final String name = member['name'];
    final bool isYou = name == 'You';

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          // Avatar
          Container(
            alignment: Alignment.center,
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isYou
                  ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                  : Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isYou
                    ? Theme.of(context).primaryColor
                    : Colors.grey.shade600,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Name
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isYou ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),

          // Amount Input (Added onChanged for live UI updates)
          SizedBox(
            width: 110,
            child: TextField(
              controller: _customSplitControllers[userId],
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              textAlign: TextAlign.end,
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              decoration: InputDecoration(
                prefixText: 'Ŧ ',
                prefixStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500,
                ),
                hintText: '0.0',
                hintStyle: TextStyle(color: Colors.grey.shade300),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey.shade800
                    : Colors.grey.shade50,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Colors.grey.shade200),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: Theme.of(context).primaryColor,
                    width: 1.5,
                  ),
                ),
              ),
              enabled: !_isSaving,
            ),
          ),
        ],
      ),
    );
  }
}
