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
import 'package:pocket_hisab/widgets/custom_text.dart';
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
        margin: const .symmetric(horizontal: 16, vertical: 8),
        padding: const .all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF10B981), Color(0xFF059669)],
            begin: .topLeft,
            end: .bottomRight,
          ),
          borderRadius: .circular(24),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF059669).withValues(alpha: 0.25),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          spacing: 4,
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
            // ── Cash / UPI Summary Row ──────────────────────────
            Obx(() {
              final cash = walletCtrl.transactions
                  .where((t) => t.paymentType == 'Cash')
                  .fold(
                    0.0,
                    (s, t) => s + (t.type == 'credit' ? t.amount : -t.amount),
                  );
              final upi = walletCtrl.transactions
                  .where((t) => t.paymentType == 'UPI')
                  .fold(
                    0.0,
                    (s, t) => s + (t.type == 'credit' ? t.amount : -t.amount),
                  );

              return Row(
                children: [
                  Expanded(
                    child: _SummaryChip(
                      label: 'Cash',
                      amount: cash,
                      icon: Icons.wallet,
                      color: AppColors.background,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryChip(
                      label: 'Online',
                      amount: upi,
                      icon: Icons.mobile_friendly,
                      color: AppColors.background,
                    ),
                  ),
                ],
              );
            }),
            // ── Income / Expense Summary Row ──────────────────────────
            if (false)
              Obx(() {
                final credits = walletCtrl.transactions
                    .where((t) => t.type == 'credit')
                    .fold(0.0, (s, t) => s + t.amount);
                final debits = walletCtrl.transactions
                    .where((t) => t.type == 'debit')
                    .fold(0.0, (s, t) => s + t.amount);

                return Row(
                  children: [
                    Expanded(
                      child: _SummaryChip(
                        label: 'Total Income',
                        amount: credits,
                        icon: Icons.arrow_circle_down_rounded,
                        color: AppColors.background,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryChip(
                        label: 'Total Spent',
                        amount: debits,
                        icon: Icons.arrow_circle_up_rounded,
                        color: AppColors.background,
                      ),
                    ),
                  ],
                );
              }),

            // ── Income / Expense Summary Row ─────────────────────────          ],
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
  String _paymentType = 'Cash'; // Cash or UPI

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
              AppText("Add to Wallet", fontWeight: .bold, size: 18),
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
          AppText("Source", fontWeight: .w600),
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
            AppText("Select Friend", fontWeight: .w600),
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

          const SizedBox(height: 16),
          AppText("Wallet Type", fontWeight: .w600),
          const SizedBox(height: 8),
          Row(
            children: ['Cash', 'UPI'].map((type) {
              final isSelected = _paymentType == type;
              return Expanded(
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _paymentType = type;
                    });
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade300,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      type,
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.black87,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

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
              final success = await walletCtrl.credit(
                walletId: targetWalletId,
                amount: amount,
                source: _sourceController.text == 'Friend'
                    ? 'From Friend: $_selectedPerson'
                    : _sourceController.text,
                note: "Added from ${_sourceController.text}",
                paymentType: _paymentType,
              );

              if (!success) {
                return; // Stop here if credit failed (e.g. insufficient salary/savings)
              }

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
                    paymentType: _paymentType,
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

// ── Summary chip ──────────────────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;

  const _SummaryChip({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    AppText(label, size: 11, color: AppColors.background),
                    AppText(
                      CurrencyHelper.format(amount),
                      size: 14,
                      fontWeight: .bold,
                      color: color,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
