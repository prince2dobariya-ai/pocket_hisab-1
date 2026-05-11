import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/monthly_reset_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';
import 'package:pocket_hisab/models/monthly_archive_model.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';

class MonthlyArchiveScreen extends StatelessWidget {
  const MonthlyArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<MonthlyResetController>();

    return Scaffold(
      appBar: CustomAppBar(title: 'Monthly Archives'),
      body: Obx(() {
        if (ctrl.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (ctrl.archives.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_rounded,
                  size: 72,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No archives yet',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Completed salary cycles will appear here.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: ctrl.archives.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, i) =>
              _ArchiveTile(archive: ctrl.archives[i]),
        );
      }),
    );
  }
}

class _ArchiveTile extends StatelessWidget {
  final MonthlyArchiveModel archive;
  const _ArchiveTile({required this.archive});

  @override
  Widget build(BuildContext context) {
    final savingsRate = archive.salaryAmount > 0
        ? (archive.totalAddedToSavings / archive.salaryAmount * 100)
            .clamp(0.0, 100.0)
        : 0.0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          childrenPadding:
              const EdgeInsets.fromLTRB(16, 0, 16, 16),
          leading: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          title: Text(
            archive.label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          subtitle: Text(
            'Salary: ${CurrencyHelper.format(archive.salaryAmount)}',
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
          trailing: _SavingsChip(rate: savingsRate),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 12),
            _Row(
              icon: Icons.monetization_on_rounded,
              label: 'Salary',
              value: archive.salaryAmount,
              color: AppColors.primary,
            ),
            _Row(
              icon: Icons.receipt_long_rounded,
              label: 'Total Expenses',
              value: archive.totalExpenses,
              color: Colors.red.shade400,
            ),
            _Row(
              icon: Icons.savings_rounded,
              label: 'Added to Savings',
              value: archive.totalAddedToSavings,
              color: Colors.green,
            ),
            _Row(
              icon: Icons.account_balance_wallet_rounded,
              label: 'Added to Wallet',
              value: archive.totalAddedToWallet,
              color: Colors.orange,
            ),
            const SizedBox(height: 8),
            const Divider(height: 1),
            const SizedBox(height: 8),
            _Row(
              icon: Icons.account_balance_wallet_outlined,
              label: 'Wallet at Reset',
              value: archive.walletBalanceAtReset,
              color: Colors.blueGrey,
            ),
            _Row(
              icon: Icons.savings_outlined,
              label: 'Savings at Reset',
              value: archive.savingsBalanceAtReset,
              color: Colors.teal,
            ),
            const SizedBox(height: 8),
            // Wallet kept badge
            Align(
              alignment: Alignment.centerLeft,
              child: Chip(
                visualDensity: VisualDensity.compact,
                avatar: Icon(
                  archive.walletKept
                      ? Icons.check_circle
                      : Icons.cancel,
                  size: 14,
                  color: archive.walletKept ? Colors.green : Colors.red,
                ),
                label: Text(
                  archive.walletKept
                      ? 'Wallet balance was kept'
                      : 'Wallet was reset to ₹0',
                  style: const TextStyle(fontSize: 11),
                ),
                backgroundColor: archive.walletKept
                    ? Colors.green.shade50
                    : Colors.red.shade50,
                side: BorderSide(
                  color: archive.walletKept
                      ? Colors.green.shade200
                      : Colors.red.shade200,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final IconData icon;
  final String label;
  final double value;
  final Color color;

  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
          ),
          Text(
            CurrencyHelper.format(value),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavingsChip extends StatelessWidget {
  final double rate;
  const _SavingsChip({required this.rate});

  @override
  Widget build(BuildContext context) {
    final color = rate >= 20 ? Colors.green : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        '${rate.toStringAsFixed(0)}% saved',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
