import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/controllers/salary_controller.dart';
import 'package:pocket_hisab/controllers/transaction_controller.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/controllers/emi_controller.dart';
import 'package:pocket_hisab/models/salary_model.dart';

class SalaryCard extends StatelessWidget {
  const SalaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    final salaryCtrl = Get.find<SalaryController>();
    final walletCtrl = Get.find<WalletController>();
    final emiCtrl = Get.find<EmiController>();

    return Obx(() {
      final latestSalary = salaryCtrl.latestSalary?.amount ?? 0.0;
      final month =
          salaryCtrl.latestSalary?.month ?? DateTime.now().month.toString();
      final walletAdded = walletCtrl.totalAddedFromSalary;
      final emiPaid = emiCtrl.totalMonthlyEmi;

      final salaryLeft = latestSalary - walletAdded - emiPaid;

      final percentage = latestSalary > 0 ? (salaryLeft / latestSalary) : 0.0;
      final displayPercent = (percentage * 100)
          .clamp(0, 100)
          .toStringAsFixed(0);

      return Container(
        padding: .all(16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade400, Colors.purple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
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
                      "₹${latestSalary.toStringAsFixed(0)}",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                IconButton(
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
                  icon: const Icon(
                    Icons.add_circle,
                    color: Colors.white,
                    size: 30,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
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
                    "Salary Left",
                    style: TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  Text(
                    "₹${salaryLeft.toStringAsFixed(0)}",
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
                      color: Colors.white.withValues(alpha: 0.2),
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
                          "₹${walletCtrl.totalAddedFromSalary.toStringAsFixed(0)}",
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
                  child: Container(
                    margin: .only(top: 16.0),
                    padding: .all(12.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
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
                          "₹${emiCtrl.totalMonthlyEmi.toStringAsFixed(0)}",
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
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
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
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: "Enter amount (e.g. 35000)",
              prefixIcon: const Icon(Icons.currency_rupee),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            "Select Month",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _monthController.text,
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
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade400,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
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
              child: const Text(
                "Save Salary",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
