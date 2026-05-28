import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pocket_hisab/controllers/transaction_controller.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';
import 'package:pocket_hisab/models/expense_model.dart';
import 'package:pocket_hisab/models/transaction_model.dart';
import 'package:pocket_hisab/controllers/saving_controller.dart';
import 'package:pocket_hisab/models/saving_transaction_model.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';

class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txCtrl = Get.find<TransactionController>();

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: CustomAppBar(
          title: "All Transactions",
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "All"),
              Tab(text: "Expenses"),
              Tab(text: "Wallet"),
              Tab(text: "Savings"),
            ],
          ),
        ),
        body: Obx(() {
          final walletCtrl = Get.find<WalletController>();
          final savingCtrl = Get.find<SavingController>();
          if (txCtrl.isLoading.value ||
              walletCtrl.isLoading.value ||
              savingCtrl.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final expenseItems = _getExpenseTransactions(txCtrl.expenses);
          final walletItems = _getWalletTransactions(walletCtrl.transactions);
          final savingItems = _getSavingTransactions(savingCtrl.transactions);

          final allItems = [...expenseItems, ...walletItems, ...savingItems];
          allItems.sort((a, b) => b.dateTime.compareTo(a.dateTime));

          return TabBarView(
            children: [
              _buildTransactionList(allItems),
              _buildTransactionList(expenseItems),
              _buildTransactionList(walletItems),
              _buildTransactionList(savingItems),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTransactionList(List<_AllMergedTransaction> items) {
    if (items.isEmpty) {
      return const Center(child: Text("No transactions found"));
    }

    // Grouping by date
    Map<String, List<_AllMergedTransaction>> grouped = {};
    for (var item in items) {
      if (!grouped.containsKey(item.displayDate)) {
        grouped[item.displayDate] = [];
      }
      grouped[item.displayDate]!.add(item);
    }

    final sortedDates = grouped.keys.toList();

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, dateIndex) {
        String dateStr = sortedDates[dateIndex];
        List<_AllMergedTransaction> dayItems = grouped[dateStr]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ),
            ...dayItems.map((item) => _buildTransactionCard(item)),
          ],
        );
      },
    );
  }

  List<_AllMergedTransaction> _getExpenseTransactions(
    List<ExpenseModel> expenses,
  ) {
    List<_AllMergedTransaction> list = [];
    for (var e in expenses) {
      list.add(
        _AllMergedTransaction(
          title: e.category,
          subtitle: e.note,
          amount: e.amount,
          isCredit: false,
          dateTime: DateTime.parse(e.createdAt),
          displayDate: e.date,
          icon: _getCategoryIconData(e.category),
          color: _getCategoryColor(e.category),
          source: e.paymentMethod,
        ),
      );
    }
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  List<_AllMergedTransaction> _getWalletTransactions(
    List<TransactionModel> walletTxs,
  ) {
    List<_AllMergedTransaction> list = [];
    for (var t in walletTxs) {
      bool isExpenseLinked =
          t.source.startsWith('Expense:') || t.source.startsWith('Lent to');
      if (t.type == 'credit' || (t.type == 'debit' && !isExpenseLinked)) {
        DateTime dt = DateTime.parse(t.createdAt);
        list.add(
          _AllMergedTransaction(
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
            source: 'Wallet',
          ),
        );
      }
    }
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  List<_AllMergedTransaction> _getSavingTransactions(
    List<SavingTransactionModel> savingTxs,
  ) {
    List<_AllMergedTransaction> list = [];
    for (var t in savingTxs) {
      if (t.source == 'Wallet') continue;

      DateTime dt = DateTime.parse(t.createdAt);
      list.add(
        _AllMergedTransaction(
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
          source: 'Savings',
        ),
      );
    }
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  Widget _buildTransactionCard(_AllMergedTransaction item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: item.color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(item.icon, color: item.color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (item.subtitle != null && item.subtitle!.isNotEmpty)
                  Text(
                    item.subtitle!,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "${item.isCredit ? '+' : '-'} ${CurrencyHelper.format(item.amount)}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: item.isCredit ? Colors.green : Colors.redAccent,
                ),
              ),
              Text(
                item.source,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
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
}

class _AllMergedTransaction {
  final String title;
  final String? subtitle;
  final double amount;
  final bool isCredit;
  final DateTime dateTime;
  final String displayDate;
  final IconData icon;
  final Color color;
  final String source;

  _AllMergedTransaction({
    required this.title,
    this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.dateTime,
    required this.displayDate,
    required this.icon,
    required this.color,
    required this.source,
  });
}
