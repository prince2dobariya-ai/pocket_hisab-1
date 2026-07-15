import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/helpers/snackbar_helper.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/group_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';
import 'package:pocket_hisab/models/group_model.dart';
import 'package:pocket_hisab/widgets/custom_button.dart';
import 'package:pocket_hisab/widgets/custom_text.dart';
import 'package:pocket_hisab/widgets/custome_textform_filed.dart';

class AddGroupExpenseScreen extends StatefulWidget {
  final GroupModel group;

  const AddGroupExpenseScreen({super.key, required this.group});

  @override
  State<AddGroupExpenseScreen> createState() => _AddGroupExpenseScreenState();
}

class _AddGroupExpenseScreenState extends State<AddGroupExpenseScreen> {
  final groupCtrl = Get.find<GroupController>();

  final _titleController = TextEditingController();
  final _amountController = TextEditingController();

  int? _selectedPayerId;
  final Map<int, TextEditingController> _customSplitControllers = {};
  final Set<int> _selectedMembersForSplit = {};

  @override
  void initState() {
    super.initState();
    if (widget.group.members.isNotEmpty) {
      _selectedPayerId = widget.group.members.first.id;
      for (var member in widget.group.members) {
        _customSplitControllers[member.id!] = TextEditingController();
        _selectedMembersForSplit.add(member.id!);
      }
    }
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    setState(() {});
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _amountController.dispose();
    _titleController.dispose();
    for (var controller in _customSplitControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeBackground,
      appBar: AppBar(
        title: const AppText(
          "Add Expense",
          fontWeight: FontWeight.bold,
          size: 20,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomTextField(
              controller: _titleController,
              labelText: "What was this for?",
              hintText: "e.g., Dinner, Taxi",
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _amountController,
              labelText: "Amount",
              hintText: "0.0",
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
            ),

            const SizedBox(height: 24),
            const AppText("Who paid?", fontWeight: FontWeight.bold, size: 16),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedPayerId,
                  isExpanded: true,
                  items: widget.group.members.map((member) {
                    return DropdownMenuItem<int>(
                      value: member.id,
                      child: Text(member.name),
                    );
                  }).toList(),
                  onChanged: (val) {
                    setState(() {
                      _selectedPayerId = val;
                    });
                  },
                ),
              ),
            ),

            const SizedBox(height: 24),

            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: context.themePrimary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    spacing: 12,
                    children: [
                      Icon(Icons.pie_chart_rounded, color: context.themePrimary),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const AppText(
                                  "Split Equally",
                                  fontWeight: FontWeight.bold,
                                ),
                                if (_selectedMembersForSplit.isNotEmpty)
                                  AppText(
                                    "${CurrencyHelper.format((double.tryParse(_amountController.text.trim()) ?? 0.0) / _selectedMembersForSplit.length)} / person",
                                    fontWeight: FontWeight.bold,
                                    color: context.themePrimary,
                                  ),
                              ],
                            ),
                            const AppText(
                              "Uncheck members who didn't participate.",
                              size: 12,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ...widget.group.members.map((member) {
                  final isSelected = _selectedMembersForSplit.contains(
                    member.id,
                  );
                  return CheckboxListTile(
                    value: isSelected,
                    onChanged: (val) {
                      setState(() {
                        if (val == true) {
                          _selectedMembersForSplit.add(member.id!);
                        } else {
                          _selectedMembersForSplit.remove(member.id!);
                        }
                      });
                    },
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        AppText(member.name, fontWeight: FontWeight.bold),
                        if (isSelected)
                          AppText(
                            CurrencyHelper.format(
                              (double.tryParse(_amountController.text.trim()) ??
                                      0.0) /
                                  (_selectedMembersForSplit.isEmpty
                                      ? 1
                                      : _selectedMembersForSplit.length),
                            ),
                            color: Colors.grey.shade700,
                            size: 14,
                          ),
                      ],
                    ),
                    activeColor: context.themePrimary,
                    contentPadding: EdgeInsets.zero,
                    controlAffinity: ListTileControlAffinity.leading,
                  );
                }).toList(),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            height: 52,
            child: CustomButton(onTap: _saveExpense, title: "Save Expense"),
          ),
        ),
      ),
    );
  }

  Future<void> _saveExpense() async {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();

    if (title.isEmpty) {
      showCustomSnackbar("Error", "Please enter a title");
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      showCustomSnackbar("Error", "Please enter a valid amount");
      return;
    }

    if (_selectedPayerId == null) {
      showCustomSnackbar("Error", "Please select who paid");
      return;
    }

    Map<int, double> splits = {};

    if (_selectedMembersForSplit.isEmpty) {
      showCustomSnackbar("Error", "Please select at least one member for the split");
      return;
    }
    final splitAmount = amount / _selectedMembersForSplit.length;
    for (var member in widget.group.members) {
      splits[member.id!] = _selectedMembersForSplit.contains(member.id)
          ? splitAmount
          : 0.0;
    }

    await groupCtrl.addGroupExpense(
      groupId: widget.group.id!,
      title: title,
      totalAmount: amount,
      paidByMemberId: _selectedPayerId!,
      splits: splits,
    );

    Get.back();
    showCustomSnackbar("Success", "Expense added successfully");
  }
}
