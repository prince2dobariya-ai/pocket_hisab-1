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
import 'package:pocket_hisab/controllers/hisab_controller.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/widgets/custom_text.dart';

class AllTransactionsScreen extends StatelessWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final txCtrl = Get.find<TransactionController>();

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: CustomAppBar(
          title: "All Transactions",
          bottom: TabBar(
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
            splashBorderRadius: BorderRadius.circular(12),
            indicatorSize: TabBarIndicatorSize.tab,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey.shade500,
            labelStyle: const TextStyle(fontWeight: FontWeight.bold),
            dividerColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            tabs: const [
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
              _buildTransactionList(expenseItems, context),
              _WalletTransactionsTab(
                walletItems: walletItems,
                listBuilder: _buildTransactionList,
              ),
              _buildTransactionList(savingItems, context),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTransactionList(
    List<_AllMergedTransaction> items,
    BuildContext context,
  ) {
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
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: sortedDates.length,
      itemBuilder: (context, dateIndex) {
        String dateStr = sortedDates[dateIndex];
        List<_AllMergedTransaction> dayItems = grouped[dateStr]!;

        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AppText(
                      getDateTitle(dayItems.first.dateTime),
                      size: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: isDark ? Colors.grey.shade800 : AppColors.border,
                    ),
                  ),
                ],
              ),
            ),
            ...dayItems.map((item) => _buildTransactionCard(item, context)),
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
          id: e.id,
          title: e.category,
          subtitle: e.note,
          amount: e.amount,
          isCredit: false,
          dateTime: DateTime.parse(e.createdAt),
          displayDate: e.date,
          icon: _getCategoryIconData(e.category),
          color: _getCategoryColor(e.category),
          source: e.paymentMethod,
          type: 'expense',
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
            id: t.id,
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
            type: 'wallet',
            paymentType: t.paymentType,
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
          id: t.id,
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
          type: 'saving',
        ),
      );
    }
    list.sort((a, b) => b.dateTime.compareTo(a.dateTime));
    return list;
  }

  Widget _buildTransactionCard(
    _AllMergedTransaction item,
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    String timeStr = DateFormat('hh:mm a').format(item.dateTime);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onLongPress: () {
            if (item.id != null) {
              _showDeleteDialog(item);
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: item.color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
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
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          if (false && item.paymentType != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: item.paymentType == 'UPI'
                                    ? Colors.blue.withValues(alpha: 0.1)
                                    : Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.paymentType!,
                                style: TextStyle(
                                  color: item.paymentType == 'UPI'
                                      ? Colors.blue
                                      : Colors.green,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                          ],
                          Expanded(
                            child: Text(
                              item.subtitle != null && item.subtitle!.isNotEmpty
                                  ? item.subtitle!
                                  : item.source,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: item.isCredit
                            ? Colors.green.shade600
                            : Colors.redAccent.shade400,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(_AllMergedTransaction item) {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Transaction"),
        content: const Text(
          "Are you sure you want to delete this transaction?",
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Get.back();
              bool success = false;
              if (item.type == 'expense') {
                success = await Get.find<TransactionController>().deleteExpense(
                  item.id!,
                );
              } else if (item.type == 'wallet') {
                if (item.title.startsWith('Hisab: ')) {
                  final personName = item.title.replaceFirst('Hisab: ', '');
                  final hisabCtrl = Get.find<HisabController>();
                  final linkedHisab = hisabCtrl.hisabs.firstWhereOrNull(
                    (h) =>
                        h.personName == personName && h.amount == item.amount,
                  );
                  if (linkedHisab != null) {
                    success = await hisabCtrl.deleteHisab(linkedHisab.id!);
                  } else {
                    success = await Get.find<WalletController>()
                        .deleteTransaction(item.id!);
                  }
                } else {
                  success = await Get.find<WalletController>()
                      .deleteTransaction(item.id!);
                }
              } else if (item.type == 'saving') {
                success = await Get.find<SavingController>().deleteTransaction(
                  item.id!,
                );
              }

              if (success) {
                Get.snackbar("Success", "Transaction deleted");
              } else {
                Get.snackbar("Error", "Failed to delete transaction");
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
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
  final int? id;
  final String title;
  final String? subtitle;
  final double amount;
  final bool isCredit;
  final DateTime dateTime;
  final String displayDate;
  final IconData icon;
  final Color color;
  final String source;
  final String type; // 'expense', 'wallet', 'saving'
  final String? paymentType;

  _AllMergedTransaction({
    this.id,
    required this.title,
    this.subtitle,
    required this.amount,
    required this.isCredit,
    required this.dateTime,
    required this.displayDate,
    required this.icon,
    required this.color,
    required this.source,
    required this.type,
    this.paymentType,
  });
}

class _WalletTransactionsTab extends StatefulWidget {
  final List<_AllMergedTransaction> walletItems;
  final Widget Function(List<_AllMergedTransaction>, BuildContext) listBuilder;

  const _WalletTransactionsTab({
    required this.walletItems,
    required this.listBuilder,
  });

  @override
  State<_WalletTransactionsTab> createState() => _WalletTransactionsTabState();
}

class _WalletTransactionsTabState extends State<_WalletTransactionsTab> {
  int _selectedIndex = 0; // 0 for UPI, 1 for Cash

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final upiItems = widget.walletItems
        .where((i) => i.paymentType == 'UPI')
        .toList();
    final cashItems = widget.walletItems
        .where((i) => i.paymentType == 'Cash')
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedIndex = 0),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 0
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.darkCard
                                : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedIndex == 0
                            ? AppColors.primary
                            : (isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade300),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "UPI",
                      style: TextStyle(
                        color: _selectedIndex == 0
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: _selectedIndex == 0
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedIndex = 1),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _selectedIndex == 1
                          ? AppColors.primary
                          : (isDark
                                ? AppColors.darkCard
                                : Colors.grey.shade200),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedIndex == 1
                            ? AppColors.primary
                            : (isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade300),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      "Cash",
                      style: TextStyle(
                        color: _selectedIndex == 1
                            ? Colors.white
                            : (isDark ? Colors.white70 : Colors.black87),
                        fontWeight: _selectedIndex == 1
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.listBuilder(
            _selectedIndex == 0 ? upiItems : cashItems,
            context,
          ),
        ),
      ],
    );
  }
}
