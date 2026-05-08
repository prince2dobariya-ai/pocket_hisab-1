import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';
import 'package:pocket_hisab/screens/expense/add_expense_screen.dart';
import 'package:pocket_hisab/screens/wallet/wallet_card.dart';
import 'package:pocket_hisab/widgets/custom_text.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walletCtrl = Get.find<WalletController>();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0).copyWith(top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const WalletCard(),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const HeadingText(
                  "Recent Transactions",
                ),
                AppText("See All"),
              ],
            ),
            Expanded(
              child: Obx(() {
                if (walletCtrl.transactions.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 60.0),
                      child: Column(
                        children: [
                          Icon(
                            Icons.receipt_long_outlined,
                            size: 64,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "No transactions yet",
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final groupedTransactions = groupBy(
                  walletCtrl.transactions,
                      (tx) {
                    final date = DateTime.parse(tx.createdAt);
                    return DateTime(date.year, date.month, date.day);
                  },
                );
                final sortedDates = groupedTransactions.keys.toList()
                  ..sort((a, b) => b.compareTo(a));
                return ListView.separated(
                  shrinkWrap: true,
                  itemCount: sortedDates.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1,color: AppColors.border,),
                  itemBuilder: (context, index) {
                    final date = sortedDates[index];
                    final transactions = groupedTransactions[date]!;
                    return Column(
                      crossAxisAlignment: .start,
                      children: [
                        /// Date Header
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: HeadingText(
                            getDateTitle(date),
                          ),
                        ),

                        /// Transactions
                      ...transactions.map((tx){
                        final isCredit = tx.type == "credit";
                        final txDate = DateTime.parse(tx.createdAt);
                        return Column(
                          children: [
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: isCredit
                                      ? Colors.green.withValues(alpha: 0.1)
                                      : Colors.red.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  isCredit ? Icons.add : Icons.remove,
                                  color: isCredit ? Colors.green : Colors.red,
                                  size: 20,
                                ),
                              ),
                              title: AppText(tx.source),
                              subtitle: Text(
                                DateFormat('hh:mm a').format(txDate),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              trailing: Text(
                                "${isCredit ? '+' : '-'}${CurrencyHelper.format(tx.amount)}",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isCredit ? Colors.green : Colors.red,
                                ),
                              ),
                            ),

                            const Divider(
                              height: 1,
                              color: AppColors.border,
                            ),
                          ],
                        );
                        }
                      )],
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: (){
        Get.to(() => const AddExpenseScreen());
      }, label: Text('+Add Expense')),
    );
  }
}
