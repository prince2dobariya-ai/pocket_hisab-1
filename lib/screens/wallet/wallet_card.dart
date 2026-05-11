import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/salary_controller.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/controllers/emi_controller.dart';
import 'package:pocket_hisab/controllers/transaction_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';
import 'package:pocket_hisab/controllers/person_controller.dart';
import 'package:pocket_hisab/controllers/hisab_controller.dart';
import 'package:pocket_hisab/models/hisab_model.dart';
import 'package:pocket_hisab/widgets/custom_button.dart';
import 'package:pocket_hisab/widgets/custome_textform_filed.dart';

class WalletCard extends StatelessWidget {
  const WalletCard({super.key});

  @override
  Widget build(BuildContext context) {
    final salaryCtrl = Get.find<SalaryController>();
    final walletCtrl = Get.find<WalletController>();
    final emiCtrl = Get.find<EmiController>();
    final expenseCtrl = Get.find<TransactionController>();

    return Obx(() {
      final latestSalary = salaryCtrl.latestSalary?.amount ?? 0.0;
      final walletAdded = walletCtrl.totalAddedFromSalary;
      final totalWalletBalance = walletCtrl.totalBalance;
      final emiPaid = emiCtrl.totalMonthlyEmi;
      final salarySpent = expenseCtrl.totalSalaryExpenses;

      final salaryLeft = latestSalary - walletAdded - emiPaid - salarySpent;

      final percentage = latestSalary > 0 ? (salaryLeft / latestSalary) : 0.0;
      final displayPercent = (percentage * 100)
          .clamp(0, 100)
          .toStringAsFixed(0);

      return Container(
        padding: .all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primary.withValues(alpha: 0.8),
              AppColors.secondary.withValues(alpha: 0.8),
            ],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      "Wallet Balance",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      CurrencyHelper.format(totalWalletBalance),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                  ),
                  onPressed: () {
                    Get.bottomSheet(
                      _AddWalletBottomSheet(),
                      isScrollControlled: true,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.add, color: AppColors.primary, size: 24),
                  label: Text("Add to Wallet"),
                ),
              ],
            ),
            if (false)
              Container(
                margin: .only(top: 16.0),
                padding: .all(12.0),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 4,
                  children: [
                    Text(
                      "Current Wallet Balance",
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                    Text(
                      "₹${walletCtrl.totalBalance.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    LinearProgressIndicator(
                      value: percentage.clamp(0.0, 1.0),
                      color: percentage > 0.3 ? Colors.green : Colors.red,
                      minHeight: 12,
                      borderRadius: .circular(12),
                    ),
                    Text(
                      '$displayPercent% balance remaining',
                      style: TextStyle(fontSize: 14, color: Colors.white),
                    ),
                  ],
                ),
              ),
          ],
        ),
      );
    });
  }
}

class _AddWalletBottomSheet extends StatefulWidget {
  @override
  State<_AddWalletBottomSheet> createState() => _AddWalletBottomSheetState();
}

class _AddWalletBottomSheetState extends State<_AddWalletBottomSheet> {
  final _amountController = TextEditingController();
  final _sourceController = TextEditingController(text: "Salary");
  final walletCtrl = Get.find<WalletController>();
  String? _selectedPerson;

  @override
  void dispose() {
    _amountController.dispose();
    _sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 24.0,
        bottom: MediaQuery.of(context).padding.bottom + 16.0,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Add to Wallet",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            labelText: "Amount",
            hintText: "Enter amount",
          ),
          const SizedBox(height: 16),
          const Text(
            "Source",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final sources = ['Salary', 'Saving', 'Friend'];
              return Wrap(
                spacing: 12,
                children: sources.map((source) {
                  final isSelected = _sourceController.text == source;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _sourceController.text = source;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const .symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        source,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected ? .bold : .normal,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          if (_sourceController.text == 'Friend') ...[
            const SizedBox(height: 16),
            const Text(
              "Select Friend",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Obx(() {
              final personCtrl = Get.find<PersonController>();
              if (personCtrl.persons.isEmpty) {
                return Text(
                  "No friends found. Add them in the Hisab section first.",
                  style: TextStyle(color: Colors.red.shade400, fontSize: 12),
                );
              }
              return DropdownButtonFormField<String>(
                initialValue: _selectedPerson,
                hint: const Text("Select friend"),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
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
          CustomButton(
            title: "Add Money",
            onTap: () async {
              final amountText = _amountController.text.trim();
              if (amountText.isEmpty) {
                Get.snackbar('Error', 'Please enter amount');
                return;
              }
              final amount = double.tryParse(amountText);
              if (amount == null || amount <= 0) {
                Get.snackbar('Error', 'Invalid amount entered');
                return;
              }

              if (walletCtrl.wallets.isEmpty) {
                Get.snackbar('Error', 'No wallet found');
                return;
              }

              if (_sourceController.text == 'Friend' &&
                  _selectedPerson == null) {
                Get.snackbar('Error', 'Please select a friend');
                return;
              }

              final targetWalletId = walletCtrl.wallets.first.id!;

              // 1. Credit to wallet
              await walletCtrl.credit(
                walletId: targetWalletId,
                amount: amount,
                source: _sourceController.text == 'Friend'
                    ? 'From Friend: $_selectedPerson'
                    : _sourceController.text,
                note: "Added from ${_sourceController.text}",
              );

              // 2. Record in Hisab if it's from a friend (Borrowing)
              if (_sourceController.text == 'Friend') {
                final hisabCtrl = Get.find<HisabController>();
                final personId = await hisabCtrl.getOrCreatePerson(
                  _selectedPerson!,
                );
                await hisabCtrl.addHisab(
                  HisabModel(
                    personId: personId,
                    personName: _selectedPerson!,
                    type: 'borrowed',
                    amount: amount,
                    amountPaid: 0.0,
                    remainingAmount: amount,
                    status: 'pending',
                    note: "Borrowed from friend",
                    createdAt: DateTime.now().toIso8601String(),
                  ),
                );
              }

              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
