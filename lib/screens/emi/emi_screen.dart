import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/helpers/snackbar_helper.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/emi_controller.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';
import 'package:pocket_hisab/models/emi_model.dart';
import 'package:pocket_hisab/controllers/dashboard_controller.dart';
import 'package:pocket_hisab/screens/emi/add_emi_screen.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';
import 'package:pocket_hisab/widgets/custom_text.dart';

class EmiScreen extends StatelessWidget {
  const EmiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emiCtrl = Get.find<EmiController>();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'My EMIs',
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
              spacing: 24,
              mainAxisAlignment: .center,
              children: [
                Container(
                  padding: const .all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: .circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 56,
                    color: context.themePrimary.withValues(alpha: 0.5),
                  ),
                ),
                const AppText('No EMIs Found'),
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
          colors: [
            context.themePrimary,
            context.themePrimary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.themePrimary.withValues(alpha: 0.3),
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
    final emiCtrl = Get.find<EmiController>();
    final isPaidThisMonth = emiCtrl.isPaidInCurrentCycle(emi);

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (isPaidThisMonth && !isCompleted)
                      Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Text(
                          "PAID THIS CYCLE",
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
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
                            : context.themePrimary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        emi.status.toUpperCase(),
                        style: TextStyle(
                          color: isCompleted
                              ? Colors.green
                              : context.themePrimary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _DueStatusBadge(dueStatus: emi.dueStatus),
                  ],
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
                  isCompleted ? Colors.green : context.themePrimary,
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
                  onPressed: isPaidThisMonth
                      ? () => _showAlreadyPaidWarning(context)
                      : () => _showPayConfirmation(context),
                  icon: Icon(
                    isPaidThisMonth
                        ? Icons.check_circle
                        : Icons.check_circle_outline,
                    size: 18,
                    color: isPaidThisMonth ? Colors.green : null,
                  ),
                  label: Text(
                    isPaidThisMonth
                        ? 'Paid for this Cycle'
                        : 'Pay Monthly Instalment',
                    style: TextStyle(
                      color: isPaidThisMonth ? Colors.green : null,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: isPaidThisMonth
                        ? const BorderSide(color: Colors.green)
                        : null,
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

  void _showAlreadyPaidWarning(BuildContext context) {
    Get.dialog(
      AlertDialog(
        title: const Text('Already Paid'),
        content: Text(
          'You have already marked an instalment as paid for "${emi.name}" in this cycle. Do you want to pay another one?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _showPayConfirmation(context);
            },
            child: const Text('Pay Again'),
          ),
        ],
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
                showCustomSnackbar('Deleted', 'EMI deleted successfully');
              } else {
                showCustomSnackbar('Error', 'Failed to delete EMI');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showPayConfirmation(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.bottomSheetDark : AppColors.bottomSheet,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
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
                  'Confirm Payment',
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
            const SizedBox(height: 12),
            Text(
              'How did you pay ${CurrencyHelper.format(emi.monthlyAmount)} for ${emi.name}?',
              style: TextStyle(
                color: isDark ? Colors.white70 : Colors.grey.shade600,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _PaymentMethodOption(
                    icon: Icons.payments_outlined,
                    label: 'Salary',
                    color: Colors.blue,
                    onTap: () => _processPayment('Salary'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _PaymentMethodOption(
                    icon: Icons.account_balance_wallet_outlined,
                    label: 'Wallet',
                    color: Colors.orange,
                    onTap: () => _processPayment('Wallet'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  void _processPayment(String method) async {
    final emiCtrl = Get.find<EmiController>();

    // If paying via wallet, we need to debit the first wallet (matching AddExpense logic)
    if (method == 'Wallet') {
      final walletCtrl = Get.find<WalletController>();
      if (walletCtrl.wallets.isNotEmpty) {
        final available = walletCtrl.getBalanceByPaymentType('Cash');
        if (emi.monthlyAmount > available) {
          showCustomSnackbar(
            'Error',
            'Insufficient Wallet (Cash) balance (${CurrencyHelper.format(available)})',
          );
          return;
        }

        final walletId = walletCtrl.wallets.first.id!;
        await walletCtrl.debit(
          walletId: walletId,
          amount: emi.monthlyAmount,
          source: 'EMI: ${emi.name}',
          note: 'Monthly instalment paid',
        );
      }
    } else if (method == 'Salary') {
      final dashCtrl = Get.find<DashboardController>();
      final available = dashCtrl.salaryLeft;
      if (emi.monthlyAmount > available) {
        showCustomSnackbar(
          'Error',
          'Insufficient Salary balance (${CurrencyHelper.format(available)})',
        );
        return;
      }
    }

    final success = await emiCtrl.payInstalment(emi.id!, paymentMethod: method);
    Get.back(); // close bottom sheet

    if (success) {
      showCustomSnackbar(
        'Success',
        'Instalment marked as paid via $method',
        backgroundColor: Colors.green.withValues(alpha: 0.1),
        colorText: Colors.green.shade900,
      );
    } else {
      showCustomSnackbar('Error', 'Failed to update payment');
    }
  }
}

class _PaymentMethodOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _PaymentMethodOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade200),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
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

class _DueStatusBadge extends StatelessWidget {
  final String dueStatus;

  const _DueStatusBadge({required this.dueStatus});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    if (dueStatus == 'Due Today') {
      bgColor = Colors.orange.shade100;
      textColor = Colors.orange.shade800;
    } else if (dueStatus == 'Overdue') {
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade800;
    } else if (dueStatus.startsWith('Due in')) {
      bgColor = Colors.amber.shade100;
      textColor = Colors.amber.shade900;
    } else if (dueStatus == 'Completed') {
      bgColor = Colors.green.shade100;
      textColor = Colors.green.shade800;
    } else {
      bgColor = Colors.blue.shade50;
      textColor = Colors.blue.shade700;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        dueStatus,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
