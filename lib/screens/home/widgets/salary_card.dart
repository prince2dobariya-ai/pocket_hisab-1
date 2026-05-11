import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/monthly_reset_controller.dart';
import 'package:pocket_hisab/controllers/salary_controller.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/controllers/emi_controller.dart';
import 'package:pocket_hisab/controllers/transaction_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';
import 'package:pocket_hisab/models/salary_model.dart';
import 'package:pocket_hisab/controllers/saving_controller.dart';
import 'package:pocket_hisab/screens/emi/emi_screen.dart';
import 'package:pocket_hisab/widgets/custom_button.dart';
import 'package:pocket_hisab/widgets/custome_textform_filed.dart';

class SalaryCard extends StatelessWidget {
  const SalaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final salaryCtrl = Get.find<SalaryController>();
    final walletCtrl = Get.find<WalletController>();
    final emiCtrl = Get.find<EmiController>();
    final expenseCtrl = Get.find<TransactionController>();
    final savingCtrl = Get.find<SavingController>();

    return Obx(() {
      final latestSalary = salaryCtrl.latestSalary?.amount ?? 0.0;
      final month = salaryCtrl.latestSalary?.month == null
          ? DateFormat('MMM').format(DateTime.now())
          : salaryCtrl.latestSalary!.month;
      final walletAdded = walletCtrl.totalAddedFromSalary;
      final emiPaid = emiCtrl.totalMonthlyEmi;
      final salarySpent = expenseCtrl.totalSalaryExpenses;
      final savingAdded = savingCtrl.totalAddedFromSalary;

      final salaryLeft =
          latestSalary - walletAdded - emiPaid - salarySpent - savingAdded;

      final percentage = latestSalary > 0 ? (salaryLeft / latestSalary) : 0.0;
      final displayPercent = (percentage * 100)
          .clamp(0, 100)
          .toStringAsFixed(0);

      return Container(
        padding: .all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary.withValues(alpha: 0.8),
              AppColors.primary.withValues(alpha: 0.8),
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
                      "$month Salary",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      CurrencyHelper.format(latestSalary),
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
                      _AddSalaryBottomSheet(),
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
                  label: Text("Add to Salary"),
                ),
              ],
            ),
            Container(
              margin: .only(top: 16.0),
              padding: .all(12.0),
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(50),
                borderRadius: .circular(12),
                border: .all(color: Colors.blueGrey.shade50,width: 0.6),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05),blurRadius: 8,offset: Offset(0, 2))
                ]
              ),
              child: Column(
                crossAxisAlignment: .start,
                spacing: 4,
                children: [
                  Text(
                    "Salary Left",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Text(
                    CurrencyHelper.format(salaryLeft),
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
                    '$displayPercent% salary remaining',
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  // Cycle progress row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.timelapse_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Cycle: ${(Get.find<MonthlyResetController>().cycleProgress * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${Get.find<MonthlyResetController>().daysRemaining} days left',
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Row(
              spacing: 12,
              children: [
                Expanded(
                  child: Container(
                    margin: .only(top: 16.0),
                    padding: .all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: .start,
                      spacing: 4,
                      children: [
                        Text(
                          "Wallet Added",
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                        Text(
                          CurrencyHelper.format(
                            walletCtrl.totalAddedFromSalary,
                          ),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () => Get.to(() => const EmiScreen()),
                    child: Container(
                      margin: .only(top: 16.0),
                      padding: .all(12.0),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: .start,
                        spacing: 4,
                        children: [
                          Text(
                            "EMI Paid",
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          Text(
                            CurrencyHelper.format(emiCtrl.totalMonthlyEmi),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
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

class _AddSalaryBottomSheet extends StatefulWidget {
  @override
  State<_AddSalaryBottomSheet> createState() => _AddSalaryBottomSheetState();
}

class _AddSalaryBottomSheetState extends State<_AddSalaryBottomSheet> {
  final _amountController = TextEditingController();
  final _monthController = TextEditingController(text: _getCurrentMonth());

  static String _getCurrentMonth() {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    return months[DateTime.now().month - 1];
  }

  @override
  void dispose() {
    _amountController.dispose();
    _monthController.dispose();
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
                "Add Salary",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "Salary Amount",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          CustomTextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            labelText: "Amount",
            hintText: "Enter amount (e.g. 35000)",
          ),
          const SizedBox(height: 16),
          const Text(
            "Select Month",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            initialValue: _monthController.text,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            items:
                [
                      'January',
                      'February',
                      'March',
                      'April',
                      'May',
                      'June',
                      'July',
                      'August',
                      'September',
                      'October',
                      'November',
                      'December',
                    ]
                    .map(
                      (month) =>
                          DropdownMenuItem(value: month, child: Text(month)),
                    )
                    .toList(),
            onChanged: (value) {
              if (value != null) {
                _monthController.text = value;
              }
            },
          ),
          const SizedBox(height: 24),
          CustomButton(
            title: "Save Salary",
            onTap: () {
              final amountText = _amountController.text.trim();
              if (amountText.isEmpty) {
                Get.snackbar('Error', 'Please enter salary amount');
                return;
              }
              final amount = double.tryParse(amountText);
              if (amount == null || amount <= 0) {
                Get.snackbar('Error', 'Invalid amount entered');
                return;
              }

              final salaryCtrl = Get.find<SalaryController>();
              salaryCtrl.addSalary(
                SalaryModel(
                  amount: amount,
                  createdAt: DateTime.now().toString(),
                  month: _monthController.text,
                  year: DateTime.now().year,
                ),
              );

              Get.back();
            },
          ),
        ],
      ),
    );
  }
}
