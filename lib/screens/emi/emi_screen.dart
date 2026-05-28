import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/emi_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';
import 'package:pocket_hisab/models/emi_model.dart';
import 'package:pocket_hisab/screens/emi/add_emi_screen.dart';

class EmiScreen extends StatelessWidget {
  const EmiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emiCtrl = Get.find<EmiController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My EMIs'),
        actions: [
          IconButton(
            onPressed: () => Get.to(() => const AddEmiScreen()),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Obx(() {
        if (emiCtrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (emiCtrl.emis.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_rounded,
                  size: 64,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No EMIs added yet',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 18),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => Get.to(() => const AddEmiScreen()),
                  child: const Text('Add Your First EMI'),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            _EmiSummaryHeader(
              totalRemaining: emiCtrl.totalRemainingAmount,
              monthlyTotal: emiCtrl.totalMonthlyEmi,
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: emiCtrl.emis.length,
                itemBuilder: (context, index) {
                  final emi = emiCtrl.emis[index];
                  return _EmiCard(emi: emi);
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _EmiSummaryHeader extends StatelessWidget {
  final double totalRemaining;
  final double monthlyTotal;

  const _EmiSummaryHeader({
    required this.totalRemaining,
    required this.monthlyTotal,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Total Outstanding',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  CurrencyHelper.format(totalRemaining),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 40,
            width: 1,
            color: Colors.white24,
            margin: const EdgeInsets.symmetric(horizontal: 16),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Monthly Commitment',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
                Text(
                  CurrencyHelper.format(monthlyTotal),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EmiCard extends StatelessWidget {
  final EmiModel emi;

  const _EmiCard({required this.emi});

  @override
  Widget build(BuildContext context) {
    final progress = emi.totalAmount > 0
        ? (emi.paidAmount / emi.totalAmount)
        : 0.0;
    final isCompleted = emi.status == 'completed';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        emi.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Monthly: ${CurrencyHelper.format(emi.monthlyAmount)}',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Colors.green.withValues(alpha: 0.1)
                        : AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    emi.status.toUpperCase(),
                    style: TextStyle(
                      color: isCompleted ? Colors.green : AppColors.primary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton(
                  icon: const Icon(Icons.more_vert, size: 20),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text(
                        'Delete EMI',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                  onSelected: (val) {
                    if (val == 'delete') {
                      _showDeleteConfirmation(context);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Progress',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  '${(progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: progress.clamp(0, 1),
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isCompleted ? Colors.green : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _AmountInfo(label: 'Total', amount: emi.totalAmount),
                _AmountInfo(label: 'Paid', amount: emi.paidAmount),
                _AmountInfo(
                  label: 'Remaining',
                  amount: emi.remainingAmount,
                  color: isCompleted ? Colors.green : Colors.redAccent,
                ),
              ],
            ),
            if (!isCompleted) ...[
              const Divider(height: 32),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showPayConfirmation(context),
                  icon: const Icon(Icons.check_circle_outline, size: 18),
                  label: const Text('Pay Monthly Instalment'),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete EMI'),
        content: Text(
          'Are you sure you want to delete ${emi.name}? This action cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final success = await Get.find<EmiController>().deleteEmi(
                emi.id!,
              );
              Get.back();
              if (success) {
                Get.snackbar('Deleted', 'EMI deleted successfully');
              } else {
                Get.snackbar('Error', 'Failed to delete EMI');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPayConfirmation(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Confirm Payment'),
        content: Text(
          'Are you sure you want to mark ${CurrencyHelper.format(emi.monthlyAmount)} as paid for ${emi.name}?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              final success = await Get.find<EmiController>().payInstalment(
                emi.id!,
              );
              Get.back();
              if (success) {
                Get.snackbar('Success', 'Instalment paid successfully');
              } else {
                Get.snackbar('Error', 'Failed to update payment');
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _AmountInfo extends StatelessWidget {
  final String label;
  final double amount;
  final Color? color;

  const _AmountInfo({required this.label, required this.amount, this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
        ),
        Text(
          CurrencyHelper.format(amount),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
