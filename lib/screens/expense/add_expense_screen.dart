import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/controllers/transaction_controller.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/controllers/person_controller.dart';
import 'package:pocket_hisab/controllers/hisab_controller.dart';
import 'package:pocket_hisab/models/expense_model.dart';
import 'package:pocket_hisab/models/hisab_model.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';
import 'package:pocket_hisab/widgets/custom_button.dart';
import 'package:pocket_hisab/widgets/custome_textform_filed.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController(
    text:
        "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
  );

  String _selectedCategory = 'Food';
  String _selectedPaymentMethod = 'Wallet';
  String? _selectedPerson;

  final List<String> _categories = [
    'Food',
    'Transport',
    'Rent',
    'Shopping',
    'Entertainment',
    'Bills',
    'Medical',
    'Friend',
    'Others',
  ];

  final List<String> _paymentMethods = ['Wallet', 'Salary'];

  IconData _getPaymentMethodIcon(String method) {
    switch (method) {
      case 'Cash':
        return Icons.money;
      case 'Bank':
        return Icons.account_balance;
      case 'Wallet':
        return Icons.account_balance_wallet;
      case 'Salary':
        return Icons.payments_outlined;
      default:
        return Icons.payment;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: "Expense"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Expense Amount",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            CustomTextField(labelText: 'amount', controller: _amountController, keyboardType: .number),
            const SizedBox(height: 24),
            const Text(
              "Category",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.category_outlined),
              ),
              items: _categories
                  .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedCategory = value;
                  });
                }
              },
            ),
            if (_selectedCategory == 'Friend') ...[
              const SizedBox(height: 24),
              const Text(
                "Select Friend",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Obx(() {
                final personCtrl = Get.find<PersonController>();
                if (personCtrl.persons.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red.withOpacity(0.2)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.red, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "No friends found. Add them in the Hisab section first.",
                            style: TextStyle(color: Colors.red, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return DropdownButtonFormField<String>(
                  value: _selectedPerson,
                  hint: const Text("Select friend"),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.person_outline),
                  ),
                  items: personCtrl.persons
                      .map(
                        (p) => DropdownMenuItem(
                          value: p.personName,
                          child: Text(p.personName),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedPerson = value;
                    });
                  },
                );
              }),
            ],
            const SizedBox(height: 24),
            const Text(
              "Date",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            CustomTextField(
                labelText: '',
                controller: _dateController,
                readOnly: true,
                onTap: ()=>_selectDate(context),
            ),
            const SizedBox(height: 24),
            const Text(
              "Payment Method",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: _paymentMethods.map((method) {
                final isSelected = _selectedPaymentMethod == method;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = method;
                    });
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 5,
                            offset: const Offset(0, 4),
                          )
                        else
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPaymentMethodIcon(method),
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade600,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          method,
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade800,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              "Note (Optional)",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            CustomTextField(labelText: 'Add a note...',
              controller: _noteController,
              minLine: 3,
              maxLine: 3,),
            const SizedBox(height: 32),
            CustomButton(title: "Save Expense", onTap: ()async{
              final amountText = _amountController.text.trim();
              if (amountText.isEmpty) {
                Get.snackbar("Error", "Please enter amount");
                return;
              }

              final amount = double.tryParse(amountText);
              if (amount == null || amount <= 0) {
                Get.snackbar("Error", "Invalid amount entered");
                return;
              }

              final txCtrl = Get.find<TransactionController>();
              final walletCtrl = Get.find<WalletController>();
              final hisabCtrl = Get.find<HisabController>();

              // Validation for Friend category
              if (_selectedCategory == 'Friend' && _selectedPerson == null) {
                Get.snackbar("Error", "Please select a friend");
                return;
              }

              // 1. Save expense to database
              await txCtrl.addExpense(
                ExpenseModel(
                  category: _selectedCategory,
                  amount: amount,
                  note: _noteController.text.trim(),
                  date: _dateController.text,
                  createdAt: DateTime.now().toIso8601String(),
                  paymentMethod: _selectedPaymentMethod,
                ),
              );

              // 2. Record in Hisab if it's a friend expense
              if (_selectedCategory == 'Friend') {
                final personId = await hisabCtrl.getOrCreatePerson(_selectedPerson!);
                await hisabCtrl.addHisab(
                  HisabModel(
                    personId: personId,
                    personName: _selectedPerson!,
                    type: 'given',
                    amount: amount,
                    amountPaid: 0.0,
                    remainingAmount: amount,
                    status: 'pending',
                    note: _noteController.text.trim(),
                    createdAt: DateTime.now().toIso8601String(),
                  ),
                );
              }

              // 3. Conditional deduction from Wallet
              if (_selectedPaymentMethod == 'Wallet') {
                if (walletCtrl.wallets.isNotEmpty) {
                  final walletId = walletCtrl.wallets.first.id!;
                  await walletCtrl.debit(
                    walletId: walletId,
                    amount: amount,
                    source: _selectedCategory == 'Friend'
                        ? 'Lent to $_selectedPerson'
                        : 'Expense: $_selectedCategory',
                    note: _noteController.text.trim().isNotEmpty
                        ? _noteController.text.trim()
                        : 'Paid via Wallet',
                  );
                } else {
                  Get.snackbar(
                    "Info",
                    "Expense recorded, but no wallet found to update balance.",
                  );
                }
              }

              Get.back();
            }),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
