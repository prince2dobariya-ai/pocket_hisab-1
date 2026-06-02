import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/controllers/transaction_controller.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';
import 'package:pocket_hisab/models/expense_model.dart';
import 'package:pocket_hisab/models/transaction_model.dart';
import 'package:pocket_hisab/controllers/saving_controller.dart';
import 'package:pocket_hisab/models/saving_transaction_model.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/screens/home/all_transactions_screen.dart';
import 'package:intl/intl.dart';

class RecentTransactions extends StatelessWidget {
  const RecentTransactions({super.key});

  @override
  Widget build(BuildContext context) {
    final txCtrl = Get.find<TransactionController>();

    return Column(
      crossAxisAlignment: .start,
      children: [
        Row(
          mainAxisAlignment: .spaceBetween,
          children: [
            Text(
              "Recent Transactions",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black87,
              ),
            ),
            TextButton(
              onPressed: () => Get.to(() => const AllTransactionsScreen()),
              child: const Text("View All"),
            ),
          ],
        ),
        Obx(() {
          final walletCtrl = Get.find<WalletController>();
          final savingCtrl = Get.find<SavingController>();
          if (txCtrl.isLoading.value ||
              walletCtrl.isLoading.value ||
              savingCtrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          var mergedItems = _getMergedTransactions(
            txCtrl.expenses,
            walletCtrl.transactions,
            savingCtrl.transactions,
          );

          if (mergedItems.isEmpty) {
            return _buildEmptyState(context);
          }

          // Grouping by date
          Map<String, List<_MergedTransaction>> grouped = {};
          if (mergedItems.length > 10) {
            mergedItems = mergedItems.take(10).toList();
          }
          for (var item in mergedItems) {
            if (!grouped.containsKey(item.displayDate)) {
              grouped[item.displayDate] = [];
            }
            grouped[item.displayDate]!.add(item);
          }

          final sortedDates = grouped.keys.toList();

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: sortedDates.length > 5 ? 5 : sortedDates.length,
            itemBuilder: (context, dateIndex) {
              String dateStr = sortedDates[dateIndex];
              List<_MergedTransaction> items = grouped[dateStr]!;

              return Column(
                crossAxisAlignment: .start,
                children: [
                  _buildDateHeader(dateStr),
                  ...items.map((item) => _buildMergedItem(context, item)),
                ],
              );
            },
          );
        }),
      ],
    );
  }

  Widget _buildDateHeader(String dateStr) {
    return Padding(
      padding: .symmetric(vertical: 8.0),
      child: Text(
        dateStr,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  List<_MergedTransaction> _getMergedTransactions(
    List<ExpenseModel> expenses,
    List<TransactionModel> walletTxs,
    List<SavingTransactionModel> savingTxs,
  ) {
    List<_MergedTransaction> merged = [];

    // Add Expenses
    for (var e in expenses) {
      merged.add(
        _MergedTransaction(
          id: 'exp_${e.id}',
          title: e.category,
          subtitle: e.note,
          amount: e.amount,
          isCredit: false,
          dateTime: DateTime.parse(e.createdAt),
          displayDate: e.date,
          icon: _getCategoryIconData(e.category),
          color: _getCategoryColor(e.category),
        ),
      );
    }

    // Add Wallet Transactions (only those that are NOT expenses to avoid duplication)
    for (var t in walletTxs) {
      bool isExpenseLinked =
          t.source.startsWith('Expense:') || t.source.startsWith('Lent to');

      // We only want to show:
      // 1. Credits (Money added to wallet)
      // 2. Debits that are NOT from an expense (e.g. manual adjustment)
      if (t.type == 'credit' || (t.type == 'debit' && !isExpenseLinked)) {
        DateTime dt = DateTime.parse(t.createdAt);
        merged.add(
          _MergedTransaction(
            id: 'tx_${t.id}',
            title: t.source,
            subtitle: t.note,
            amount: t.amount,
            isCredit: t.type == 'credit',
            dateTime: dt,
            displayDate: DateFormat('d/M/yyyy').format(dt),
            icon: t.type == 'credit'
                ? Icons.add_circle_outline
                : Icons.remove_circle_outline,
            color: t.type == 'credit' ? Colors.green : Colors.blueGrey,
          ),
        );
      }
    }

    // Add Saving Transactions (skip Wallet transfers to avoid duplicates with wallet debit)
    for (var t in savingTxs) {
      if (t.source == 'Wallet') continue;

      DateTime dt = DateTime.parse(t.createdAt);
      merged.add(
        _MergedTransaction(
          id: 'sav_${t.id}',
          title: 'Saving (${t.source})',
          subtitle: t.note,
          amount: t.amount,
          isCredit: t.type == 'credit',
          dateTime: dt,
          displayDate: DateFormat('d/M/yyyy').format(dt),
          icon: t.type == 'credit'
              ? Icons.savings_outlined
              : Icons.money_off_outlined,
          color: t.type == 'credit' ? Colors.teal : Colors.deepOrange,
        ),
      );
    }

    // Sort by most recent first
    merged.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return merged;
  }

  Widget _buildMergedItem(BuildContext context, _MergedTransaction item) {
    return Container(
      margin: .only(bottom: 12),
      padding: .all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.darkCard
            : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: .all(10),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: .start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontWeight: .bold, fontSize: 15),
                ),
                if (item.subtitle != null && item.subtitle!.isNotEmpty)
                  Text(
                    item.subtitle!,
                    maxLines: 1,
                    overflow: .ellipsis,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          Text(
            "${item.isCredit ? '+' : '-'} ${CurrencyHelper.format(item.amount)}",
            style: TextStyle(
              fontWeight: .bold,
              fontSize: 16,
              color: item.isCredit ? Colors.green : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIconData(String category) {
    switch (category) {
      case 'Food':
        return Icons.restaurant;
      case 'Transport':
        return Icons.directions_bus;
      case 'Rent':
        return Icons.home;
      case 'Shopping':
        return Icons.shopping_bag;
      case 'Entertainment':
        return Icons.movie;
      case 'Bills':
        return Icons.receipt;
      case 'Medical':
        return Icons.medical_services;
      case 'Friend':
        return Icons.person;
      default:
        return Icons.category;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return Colors.orange;
      case 'Transport':
        return Colors.blue;
      case 'Rent':
        return Colors.purple;
      case 'Shopping':
        return Colors.pink;
      case 'Entertainment':
        return Colors.red;
      case 'Bills':
        return Colors.cyan;
      case 'Medical':
        return Colors.green;
      case 'Friend':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  Widget _buildEmptyState(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const .all(24),
      width: .infinity,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.grey.shade50,
        borderRadius: .circular(20),
        border: .all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          style: .solid,
        ),
      ),
      child: Column(
        spacing: 12,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 48,
            color: Colors.grey.shade300,
          ),
          Text(
            "No transactions yet",
            style: TextStyle(color: Colors.grey.shade500, fontWeight: .w500),
          ),
        ],
      ),
    );
  }
}

class _MergedTransaction {
  final String id;
  final String title;
  final String? subtitle;
  final double amount;
  final bool isCredit;
  final DateTime dateTime;
  final String displayDate;
  final IconData icon;
  final Color color;

  _MergedTransaction({
    required this.id,
    required this.title,
    this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.dateTime,
    required this.displayDate,
    required this.icon,
    required this.color,
  });
}
