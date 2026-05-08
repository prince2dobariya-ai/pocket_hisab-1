import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/dashboard_controller.dart';
import 'package:pocket_hisab/controllers/hisab_controller.dart';
import 'package:pocket_hisab/controllers/person_controller.dart';
import 'package:pocket_hisab/controllers/salary_controller.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/models/hisab_model.dart';
import 'package:pocket_hisab/widgets/custom_button.dart';
import 'package:pocket_hisab/widgets/custome_textform_filed.dart';

class SavingCard extends StatelessWidget {
  const SavingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final dashCtrl = Get.find<DashboardController>();
    final salaryCtrl = Get.find<SalaryController>();

    return InkWell(
      onTap: () {
        // Navigator.push(
        // context,
        // MaterialPageRoute(builder: (context) => WalletScreen()),
        // );
      },
      child: Card(
        color: Colors.green.shade50,
        shape: RoundedRectangleBorder(borderRadius: .circular(16)),
        child: Padding(
          padding: .all(16.0),
          child: Obx(() {
            final savings = dashCtrl.netSavings;
            final latestSalary = salaryCtrl.latestSalary?.amount ?? 0.0;
            final percentage = latestSalary > 0
                ? (savings / latestSalary).clamp(0.0, 1.0)
                : 0.0;
            final displayPercent = (percentage * 100).toStringAsFixed(0);

            return Column(
              spacing: 8,
              crossAxisAlignment: .start,
              children: [
                Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    Column(
                      children: [
                        const Row(
                          spacing: 5,
                          children: [
                            Icon(Icons.savings, color: Colors.green),
                            Text(
                              "Savings",
                              style: TextStyle(color: Colors.green),
                            ),
                          ],
                        ),
                        Text(
                          "₹${savings.toStringAsFixed(0)}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.green,
                      ),
                      onPressed: () {
                        Get.bottomSheet(
                          _AddSavingBottomSheet(),
                          isScrollControlled: true,
                          backgroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                        );
                      },
                      icon: Icon(Icons.add, color: Colors.green, size: 24),
                      label: Text("Add to Saving"),
                    ),
                  ],
                ),
                LinearProgressIndicator(
                  value: percentage,
                  color: percentage > 0.2 ? Colors.green : Colors.orange,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(12),
                ),
                Text(
                  '$displayPercent% Saved',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class _AddSavingBottomSheet extends StatefulWidget {
  @override
  State<_AddSavingBottomSheet> createState() => _AddSavingBottomSheetState();
}

class _AddSavingBottomSheetState extends State<_AddSavingBottomSheet> {
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
                "Add to Saving",
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
              final sources = ['Salary', 'Wallet', 'Friend'];
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
                await hisabCtrl.addHisab(
                  HisabModel(
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
