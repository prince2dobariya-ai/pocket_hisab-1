import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:pocket_hisab/controllers/dashboard_controller.dart';
import 'package:pocket_hisab/controllers/hisab_controller.dart';
import 'package:pocket_hisab/screens/hisab/add_hisab_screen.dart';
import 'package:pocket_hisab/screens/hisab/person_hisab_history_screen.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';

class HisabScreen extends StatelessWidget {
  const HisabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dashCtrl = Get.find<DashboardController>();
    final hisabCtrl = Get.find<HisabController>();

    return Scaffold(
      appBar: const CustomAppBar(title: "Friends Hisab"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary Cards
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      title: "You Owe",
                      amount: "₹${dashCtrl.totalIOwe.toStringAsFixed(0)}",
                      color: Colors.red.shade400,
                      icon: Icons.arrow_downward,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      title: "You are Owed",
                      amount: "₹${dashCtrl.totalOwedToMe.toStringAsFixed(0)}",
                      color: Colors.green.shade400,
                      icon: Icons.arrow_upward,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Recent Transactions",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                TextButton(onPressed: () {}, child: const Text("See All")),
              ],
            ),
            const SizedBox(height: 8),

            // Dynamic Transaction List
            Obx(() {
              final items = hisabCtrl.hisabs;
              if (items.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text("No transactions yet")),
                );
              }
              return Column(
                children: items.map((item) {
                  return _buildTransactionItem(
                    name: item.personName,
                    note: item.note ?? '',
                    amount: "₹${item.amount.toStringAsFixed(0)}",
                    date: item.createdAt.split('T').first,
                    isBorrowed: item.type == 'borrowed',
                  );
                }).toList(),
              );
            }),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddHisabScreen()),
          );
        },
        backgroundColor: Colors.amber.shade700,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text("Add New", style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem({
    required String name,
    required String note,
    required String amount,
    required String date,
    required bool isBorrowed,
  }) {
    final color = isBorrowed ? Colors.red.shade400 : Colors.green.shade400;
    return InkWell(
      onTap: () {
        Get.to(() => PersonHisabHistoryScreen(personName: name));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.1),
              child: Text(
                name.isNotEmpty ? name[0] : '?',
                style: TextStyle(color: color, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    note,
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  amount,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  date,
                  style: const TextStyle(color: Colors.black38, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
