import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/controllers/dashboard_controller.dart';
import 'package:pocket_hisab/controllers/salary_controller.dart';

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
            final percentage = latestSalary > 0 ? (savings / latestSalary).clamp(0.0, 1.0) : 0.0;
            final displayPercent = (percentage * 100).toStringAsFixed(0);

            return Column(
              spacing: 8,
              crossAxisAlignment: .start,
              children: [
                Row(spacing: 5, children: const [Icon(Icons.savings), Text("Savings")]),
                Text(
                  "₹${savings.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                LinearProgressIndicator(
                  value: percentage,
                  color: percentage > 0.2 ? Colors.green : Colors.orange,
                  minHeight: 12,
                  borderRadius: BorderRadius.circular(12),
                ),
                Text('$displayPercent% Saved', style: const TextStyle(fontSize: 14)),
              ],
            );
          }),
        ),
      ),
    );
  }
}
