import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/helpers/snackbar_helper.dart';
import 'package:intl/intl.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/group_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';
import 'package:pocket_hisab/models/group_expense_model.dart';
import 'package:pocket_hisab/models/group_model.dart';
import 'package:pocket_hisab/screens/groups/add_group_expense_screen.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';
import 'package:pocket_hisab/widgets/custom_text.dart';

class GroupDetailScreen extends StatefulWidget {
  final int groupId;
  final String groupName;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<GroupDetailScreen> createState() => _GroupDetailScreenState();
}

class _GroupDetailScreenState extends State<GroupDetailScreen>
    with SingleTickerProviderStateMixin {
  final groupCtrl = Get.find<GroupController>();
  late TabController _tabController;

  List<GroupExpenseModel> expenses = [];
  List<SimplifiedDebt> debts = [];
  bool isLoading = true;

  GroupModel? currentGroup;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);

    currentGroup = groupCtrl.groups.firstWhereOrNull(
      (g) => g.id == widget.groupId,
    );

    expenses = await groupCtrl.getGroupExpenses(widget.groupId);
    debts = await groupCtrl.calculateSimplifiedDebts(widget.groupId);

    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.themeBackground,
      appBar: CustomAppBar(
        title: widget.groupName,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: _showDeleteDialog,
            tooltip: 'Delete Group',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: context.themePrimary.withValues(alpha: 0.15),
          ),
          splashBorderRadius: BorderRadius.circular(12),
          indicatorSize: TabBarIndicatorSize.tab,
          labelColor: context.themePrimary,
          unselectedLabelColor: Colors.grey.shade500,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          dividerColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          tabs: const [
            Tab(text: "Expenses"),
            Tab(text: "Settlements"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [_buildExpensesTab(), _buildBalancesTab()],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (currentGroup == null) return;
          await Get.to(() => AddGroupExpenseScreen(group: currentGroup!));
          _loadData();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const AppText(
          'Add Expense',
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildExpensesTab() {
    if (expenses.isEmpty) {
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
            const AppText('No Expenses Found'),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 90),
      itemCount: expenses.length,
      itemBuilder: (context, index) {
        final expense = expenses[index];
        final payer = currentGroup?.members.firstWhereOrNull(
          (m) => m.id == expense.paidByMemberId,
        );

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
          color: Colors.white,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            leading: CircleAvatar(
              backgroundColor: context.themePrimary.withValues(alpha: 0.1),
              child: Icon(Icons.receipt_long, color: context.themePrimary),
            ),
            title: AppText(expense.title, fontWeight: FontWeight.bold),
            subtitle: AppText(
              "${payer?.name ?? 'Someone'} paid ${CurrencyHelper.format(expense.totalAmount)}",
              color: Colors.grey.shade600,
              size: 13,
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AppText(
                  CurrencyHelper.format(expense.totalAmount),
                  fontWeight: FontWeight.bold,
                  size: 16,
                ),
                AppText(
                  DateFormat('dd MMM yyyy').format(expense.createdAt),
                  color: Colors.grey.shade500,
                  size: 11,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBalancesTab() {
    if (debts.isEmpty) {
      return const Center(
        child: AppText("Everyone is settled up!", color: Colors.green),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 90),
      itemCount: debts.length,
      itemBuilder: (context, index) {
        final debt = debts[index];
        final debtor = currentGroup?.members.firstWhereOrNull(
          (m) => m.id == debt.debtorId,
        );
        final creditor = currentGroup?.members.firstWhereOrNull(
          (m) => m.id == debt.creditorId,
        );

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.red.shade50,
                child: Text(
                  debtor?.name[0].toUpperCase() ?? '?',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppText(
                          debtor?.name ?? '?',
                          fontWeight: FontWeight.bold,
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8.0),
                          child: Icon(
                            Icons.arrow_forward_rounded,
                            size: 16,
                            color: Colors.grey,
                          ),
                        ),
                        AppText(
                          creditor?.name ?? '?',
                          fontWeight: FontWeight.bold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      "Owes ${CurrencyHelper.format(debt.amount)}",
                      color: Colors.grey.shade600,
                      size: 13,
                    ),
                  ],
                ),
              ),
              AppText(
                CurrencyHelper.format(debt.amount),
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text("Delete Trip/Group"),
        content: Text(
          "Are you sure you want to delete '${widget.groupName}'? This will remove all associated expenses and splits.",
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          TextButton(
            onPressed: () async {
              Get.back();
              await groupCtrl.deleteGroup(widget.groupId);
              Get.back(); // close the detail screen
              showCustomSnackbar("Success", "Trip/Group deleted successfully");
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
