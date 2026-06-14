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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        margin: .symmetric(horizontal: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [const Color(0xFF0F766E), const Color(0xFF115E59)]
                : [AppColors.primary, AppColors.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: .circular(12),
          border: .all(color: Colors.blueGrey.shade50, width: 0.6),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(4),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Wallet Balance",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyHelper.format(totalWalletBalance),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  onPressed: () {
                    Get.bottomSheet(
                      _AddWalletBottomSheet(),
                      isScrollControlled: true,
                      backgroundColor: isDark
                          ? AppColors.darkCard
                          : Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.add_circle_outline, size: 16),
                  label: const Text(
                    "Add Wallet",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
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
                    note: "Received from friend",
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
