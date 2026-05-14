import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/controllers/dashboard_controller.dart';
import 'package:pocket_hisab/controllers/emi_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';
import 'package:pocket_hisab/screens/emi/add_emi_screen.dart';
import 'package:pocket_hisab/screens/emi/emi_screen.dart';

class EmiCard extends StatelessWidget {
  const EmiCard({super.key});

  @override
  Widget build(BuildContext context) {
    final dashCtrl = Get.find<DashboardController>();
    final emiCtrl = Get.find<EmiController>();

    return Card(
      color: Colors.blue.shade50,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Get.to(() => const EmiScreen()),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(() {
            final monthlyEmi = dashCtrl.totalMonthlyEmi;
            final outstanding = emiCtrl.totalRemainingAmount;
            final totalPaid = emiCtrl.totalPaidAmount;
            final totalAmount = emiCtrl.totalAmount;

            final progress = totalAmount > 0 ? (totalPaid / totalAmount) : 0.0;
            final displayPercent = (progress * 100).toStringAsFixed(0);

            return Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          spacing: 5,
                          children: [
                            Icon(
                              Icons.credit_card,
                              color: Colors.blue,
                              size: 20,
                            ),
                            Text(
                              "Monthly EMIs",
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          CurrencyHelper.format(monthlyEmi),
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
                        foregroundColor: Colors.blue,
                      ),
                      onPressed: () => Get.to(() => const AddEmiScreen()),
                      icon: const Icon(Icons.add, color: Colors.blue, size: 18),
                      label: const Text("Add EMI"),
                    ),
                  ],
                ),
                LinearProgressIndicator(
                  value: progress,
                  color: progress > 0.5 ? Colors.blue : Colors.lightBlue,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(12),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$displayPercent% Paid',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      'Outstanding: ${CurrencyHelper.format(outstanding)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
