import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/controllers/transaction_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';
import 'package:pocket_hisab/models/transaction_model.dart';
import 'package:pocket_hisab/controllers/hisab_controller.dart';
import 'package:pocket_hisab/screens/wallet/wallet_card.dart';
import 'package:pocket_hisab/widgets/custom_text.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletCtrl = Get.find<WalletController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ── Hero Balance Card ─────────────────────────────────────
          const WalletCard(),

          // ── Transactions Header ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const AppText(
                  'Wallet Transactions',
                  fontWeight: FontWeight.bold,
                  size: 17,
                ),
                const Spacer(),
                Obx(
                  () => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AppText(
                      '${walletCtrl.transactions.length} records',
                      size: 11,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Transaction List ──────────────────────────────────────
          Expanded(
            child: Obx(() {
              if (walletCtrl.transactions.isEmpty) {
                return _buildEmptyState();
              }

              final grouped = groupBy(walletCtrl.transactions, (tx) {
                final date = DateTime.parse(tx.createdAt);
                return DateTime(date.year, date.month, date.day);
              });
              final sortedDates = grouped.keys.toList()
                ..sort((a, b) => b.compareTo(a));

              return ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 90, top: 4),
                itemCount: sortedDates.length,
                itemBuilder: (context, index) {
                  final date = sortedDates[index];
                  final txs = grouped[date]!;
                  return _DateGroup(date: date, transactions: txs);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
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
              color: AppColors.primary.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          const AppText(
            'No Transactions Yet',
            fontWeight: FontWeight.bold,
            size: 17,
          ),
          const SizedBox(height: 6),
          AppText(
            'Add money to your wallet to get started.',
            size: 13,
            color: AppColors.textLight,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ── Date group ────────────────────────────────────────────────────────────────

class _DateGroup extends StatelessWidget {
  final DateTime date;
  final List<TransactionModel> transactions;

  const _DateGroup({required this.date, required this.transactions});

  @override
  Widget build(BuildContext context) {
    final double totalIncome = transactions
        .where((e) => e.type == 'credit')
        .map((e) => e.amount)
        .fold(0, (a, b) => a + b);
    final double totalExpense = transactions
        .where((e) => e.type == 'debit')
        .map((e) => e.amount)
        .fold(0, (a, b) => a + b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
          child: Row(
            spacing: 8,
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
                  getDateTitle(date),
                  size: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Expanded(child: Container(height: 1, color: AppColors.border)),
              AppText(
                '+${totalIncome == 0 ? 0 : CurrencyHelper.format(totalIncome)}',
                size: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
              AppText(
                '-${CurrencyHelper.format(totalExpense > 0 ? totalExpense : 0)}',
                size: 12,
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ],
          ),
        ),

        // Transaction cards
        ...transactions.map((tx) => _TransactionCard(tx: tx)),
      ],
    );
  }
}

// ── Single transaction card ───────────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  final TransactionModel tx;

  const _TransactionCard({required this.tx});

  @override
  Widget build(BuildContext context) {
    final isCredit = tx.type == 'credit';
    final color = isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444);
    final bgColor = isCredit
        ? const Color(0xFF10B981).withValues(alpha: 0.08)
        : const Color(0xFFEF4444).withValues(alpha: 0.08);
    final icon = isCredit
        ? Icons.arrow_circle_down_rounded
        : Icons.arrow_circle_up_rounded;
    final txDate = DateTime.parse(tx.createdAt);
    final timeStr = DateFormat('hh:mm a').format(txDate);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onLongPress: () {
            if (tx.id != null) {
              Get.dialog(
                AlertDialog(
                  title: const Text("Delete Transaction"),
                  content: const Text(
                    "Are you sure you want to delete this transaction?",
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () async {
                        Get.back();
                        bool success = false;
                        if (tx.source.startsWith('Hisab: ')) {
                          final personName = tx.source.replaceFirst(
                            'Hisab: ',
                            '',
                          );
                          final hisabCtrl = Get.find<HisabController>();
                          final linkedHisab = hisabCtrl.hisabs.firstWhereOrNull(
                            (h) =>
                                h.personName == personName &&
                                h.amount == tx.amount,
                          );
                          if (linkedHisab != null) {
                            success = await hisabCtrl.deleteHisab(
                              linkedHisab.id!,
                            );
                          } else {
                            success = await Get.find<WalletController>()
                                .deleteTransaction(tx.id!);
                          }
                        } else if (tx.source.startsWith('Expense: ') ||
                            tx.source.startsWith('Lent to ')) {
                          final txCtrl = Get.find<TransactionController>();
                          final linkedExpense = txCtrl.expenses
                              .firstWhereOrNull(
                                (e) =>
                                    e.amount == tx.amount &&
                                    (tx.source == 'Expense: ${e.category}' ||
                                        tx.source.startsWith('Lent to ')),
                              );
                          if (linkedExpense != null) {
                            success = await txCtrl.deleteExpense(
                              linkedExpense.id!,
                            );
                          } else {
                            success = await Get.find<WalletController>()
                                .deleteTransaction(tx.id!);
                          }
                        } else {
                          success = await Get.find<WalletController>()
                              .deleteTransaction(tx.id!);
                        }

                        if (success) {
                          Get.snackbar("Success", "Transaction deleted");
                        } else {
                          Get.snackbar("Error", "Failed to delete transaction");
                        }
                      },
                      child: const Text(
                        "Delete",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            }
          },
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 6,
          ),
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: bgColor, shape: .circle),
            child: Icon(icon, color: color, size: 22),
          ),
          title: AppText(tx.source, size: 14, fontWeight: .w600),
          subtitle: Padding(
            padding: const .only(top: 2),
            child: Row(
              children: [
                if (tx.paymentType != null) ...[
                  Container(
                    padding: const .symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: tx.paymentType == 'UPI'
                          ? Colors.blue.withValues(alpha: 0.1)
                          : Colors.green.withValues(alpha: 0.1),
                      borderRadius: .circular(4),
                    ),
                    child: Text(
                      tx.paymentType,
                      style: TextStyle(
                        color: tx.paymentType == 'UPI'
                            ? Colors.blue
                            : Colors.green,
                        fontSize: 10,
                        fontWeight: .bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],
                if (tx.note != null && tx.note!.isNotEmpty) ...[
                  Flexible(
                    child: AppText(
                      tx.note!,
                      size: 11,
                      color: AppColors.textLight,
                      maxLines: 1,
                    ),
                  ),
                ],
              ],
            ),
          ),
          trailing: Column(
            mainAxisAlignment: .spaceEvenly,
            children: [
              Text(
                '${isCredit ? '+' : '-'}${CurrencyHelper.format(tx.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: color,
                  letterSpacing: -0.3,
                ),
              ),
              Row(
                mainAxisSize: .min,
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 11,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 3),
                  AppText(timeStr, size: 11, color: AppColors.textLight),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
