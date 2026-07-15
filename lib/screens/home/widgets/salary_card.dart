import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/helpers/snackbar_helper.dart';
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
import 'package:pocket_hisab/widgets/custom_text.dart';
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
          color: context.themePrimary.withAlpha(222),
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
                  crossAxisAlignment: .start,
                  children: [
                    Text(
                      "$month Income",
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
                    foregroundColor: context.themePrimary,
                  ),
                  onPressed: () {
                    Get.bottomSheet(
                      const AddSalaryBottomSheet(),
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                    );
                  },
                  icon: Icon(Icons.add, color: context.themePrimary, size: 24),
                  label: Text("Add to Income"),
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
                crossAxisAlignment: .start,
                spacing: 4,
                children: [
                  Text(
                    "Balance Left",
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
                    '$displayPercent% remaining',
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
                      color: Colors.white.withAlpha(50),
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
                        color: Colors.white.withAlpha(50),
                        borderRadius: .circular(12),
                        border: .all(
                          color: Colors.blueGrey.shade50,
                          width: 0.6,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(4),
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
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

class AddSalaryBottomSheet extends StatefulWidget {
  const AddSalaryBottomSheet({super.key});

  @override
  State<AddSalaryBottomSheet> createState() => AddSalaryBottomSheetState();
}

class AddSalaryBottomSheetState extends State<AddSalaryBottomSheet> {
  final _amountController = TextEditingController();
  late final TextEditingController _dateController;
  DateTime _selectedDate = DateTime.now();

  static String _getMonthName(int monthNum) {
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
    return months[monthNum - 1];
  }

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(
      text: "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}",
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final firstDayOfCurrentMonth = DateTime(now.year, now.month, 1);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: firstDayOfCurrentMonth,
      lastDate: now,
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dateController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.bottomSheetDark : AppColors.bottomSheet,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        top: 8.0,
        bottom: MediaQuery.of(context).padding.bottom + 16.0,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(bottom: 12),
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: isDark ? Colors.grey[700] : Colors.grey[300],
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const AppText(
                  "Add Income",
                  fontWeight: FontWeight.bold,
                  size: 20,
                ),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
                    padding: const EdgeInsets.all(4),
                  ),
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.close_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const AppText(
              "Income Amount & Date",
              fontWeight: FontWeight.bold,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: CustomTextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    labelText: "Amount",
                    hintText: "Enter amount (e.g. 35000)",
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: CustomTextField(
                    controller: _dateController,
                    labelText: "Date",
                    readOnly: true,
                    onTap: () => _selectDate(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomButton(
              title: "Save Salary",
              onTap: () {
                final amountText = _amountController.text.trim();
                if (amountText.isEmpty) {
                  showCustomSnackbar('Error', 'Please enter salary amount');
                  return;
                }
                final amount = double.tryParse(amountText);
                if (amount == null || amount <= 0) {
                  showCustomSnackbar('Error', 'Invalid amount entered');
                  return;
                }

                final salaryCtrl = Get.find<SalaryController>();
                final now = DateTime.now();
                final resolvedDateTime = DateTime(
                  _selectedDate.year,
                  _selectedDate.month,
                  _selectedDate.day,
                  now.hour,
                  now.minute,
                  now.second,
                ).toString();

                salaryCtrl.addSalary(
                  SalaryModel(
                    amount: amount,
                    createdAt: resolvedDateTime,
                    month: _getMonthName(_selectedDate.month),
                    year: _selectedDate.year,
                  ),
                );

                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
