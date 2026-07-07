import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/group_service.dart';

class AddPaymentScreen extends StatefulWidget {
  final int? groupId;
  final int? friendId;
  final String groupName;
  final List<dynamic> members;
  final int currentUserId;

  const AddPaymentScreen({
    super.key,
    this.groupId,
    this.friendId,
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

  /// Returns the auto-calculated split for a member whose field is empty.
  /// Returns null if the field has a value, or if there's nothing to distribute.
  String? _getAutoSplitHint(int userId) {
    final totalAmount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (totalAmount <= 0) return null;

    // If this field already has a value, no hint needed
    if (_customSplitControllers[userId]!.text.trim().isNotEmpty) return null;

    // Sum of all filled fields
    double filledTotal = 0;
    int emptyCount = 0;
    for (var entry in _customSplitControllers.entries) {
      final val = entry.value.text.trim();
      if (val.isEmpty) {
        emptyCount++;
      } else {
        filledTotal += double.tryParse(val) ?? 0;
      }
    }

    if (emptyCount == 0) return null;

    final remaining = totalAmount - filledTotal;
    if (remaining <= 0) return null;

    final perPerson = remaining / emptyCount;
    return perPerson == perPerson.roundToDouble()
        ? perPerson.toInt().toString()
        : perPerson.toStringAsFixed(2);
  }

  /// Total of all manually entered splits (empty fields count as 0).
  double _getTotalSplits() {
    double total = 0;
    for (var controller in _customSplitControllers.values) {
      total += double.tryParse(controller.text.trim()) ?? 0;
    }
    return total;
  }

  bool _isOverSplit() {
    final totalAmount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (totalAmount <= 0) return false;
    return _getTotalSplits() > totalAmount + 0.01;
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
      customSplitsData = [];
      double splitSum = 0;

      for (var member in _allMembers) {
        final int userId = member['id'];
        final String inputVal = _customSplitControllers[userId]!.text.trim();

        // If field is empty, use the auto-calculated hint value
        double splitAmount;
        if (inputVal.isEmpty) {
          splitAmount = double.tryParse(_getAutoSplitHint(userId) ?? '0') ?? 0;
        } else {
          splitAmount = double.tryParse(inputVal) ?? 0;
        }

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
        friendId: widget.friendId,
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
            const Icon(Icons.error_outline_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Add Expense',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group name pill
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.groupId != null ? Icons.groups_rounded : Icons.person_rounded,
                      size: 18,
                      color: theme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      widget.groupName,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: theme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Amount Field
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                prefixText: 'Ŧ ',
                prefixStyle: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                labelText: 'Amount',
                labelStyle: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                floatingLabelBehavior: FloatingLabelBehavior.always,
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: theme.primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              ),
              enabled: !_isSaving,
            ),
            const SizedBox(height: 20),

            // Description Field
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'e.g., Dinner at Mario\'s',
                prefixIcon: Icon(
                  Icons.receipt_long_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(
                    color: theme.primaryColor,
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
              textCapitalization: TextCapitalization.sentences,
              enabled: !_isSaving,
            ),
            const SizedBox(height: 32),

            // Split Type Toggle (Segmented Control)
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  _buildSplitTypeButton(
                    label: 'Equal Split',
                    icon: Icons.pie_chart_outline_rounded,
                    isSelected: _divideEqually,
                    onTap: _isSaving
                        ? null
                        : () {
                      HapticFeedback.lightImpact();
                      setState(() => _divideEqually = true);
                    },
                  ),
                  _buildSplitTypeButton(
                    label: 'Custom Split',
                    icon: Icons.tune_rounded,
                    isSelected: !_divideEqually,
                    onTap: _isSaving
                        ? null
                        : () {
                      HapticFeedback.lightImpact();
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
              const SizedBox(height: 24),
              _buildCustomSplitsSection(theme),
            ],

            const SizedBox(height: 20),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving ? null : _isOverSplit() ? null : _savePayment,
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
        label: Text(
          _isSaving ? 'Saving...' : 'Save Expense',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSplitTypeButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? theme.primaryColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: isSelected
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomSplitsSection(ThemeData theme) {
    final totalAmount = double.tryParse(_amountController.text.trim()) ?? 0;
    final totalSplits = _getTotalSplits();
    final difference = totalAmount - totalSplits;
    final isBalanced = difference.abs() < 0.01 && totalAmount > 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Split Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Spacer(),
            if (totalAmount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isBalanced
                      ? Colors.green.withValues(alpha: 0.1)
                      : difference < 0
                      ? theme.colorScheme.errorContainer
                      : Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isBalanced
                      ? 'Balanced'
                      : difference < 0
                      ? 'Math = 👌'
                      : 'Remaining: Ŧ${difference.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isBalanced
                        ? Colors.green.shade700
                        : difference < 0
                        ? Colors.white
                        : Colors.orange.shade700,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        ..._allMembers.map((member) => _buildCustomSplitRow(member, theme)),
      ],
    );
  }

  Widget _buildCustomSplitRow(Map<String, dynamic> member, ThemeData theme) {
    final int userId = member['id'];
    final String name = member['name'];
    final bool isYou = name == 'You';
    final autoHint = _getAutoSplitHint(userId);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: isYou
                ? theme.primaryColor.withValues(alpha: 0.2)
                : theme.colorScheme.secondaryContainer,
            child: Text(
              name[0].toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isYou
                    ? theme.primaryColor
                    : theme.colorScheme.onSecondaryContainer,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isYou ? FontWeight.w700 : FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          SizedBox(
            width: 120,
            child: TextField(
              controller: _customSplitControllers[userId],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.end,
              onChanged: (_) => setState(() {}),
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: theme.colorScheme.onSurface,
              ),
              decoration: InputDecoration(
                prefixText: 'Ŧ ',
                prefixStyle: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
                hintText: autoHint != null ? autoHint : '0.0',
                hintStyle: TextStyle(
                  color: autoHint != null
                      ? theme.primaryColor.withValues(alpha: 0.6)
                      : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: theme.primaryColor,
                    width: 2,
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