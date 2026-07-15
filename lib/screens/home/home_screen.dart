import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/dashboard_controller.dart';
import 'package:pocket_hisab/controllers/monthly_reset_controller.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/controllers/emi_controller.dart';
import 'package:pocket_hisab/controllers/saving_controller.dart';
import 'package:pocket_hisab/controllers/person_controller.dart';
import 'package:pocket_hisab/controllers/salary_controller.dart';
import 'package:pocket_hisab/controllers/settings_controller.dart';
import 'package:pocket_hisab/controllers/transaction_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';
import 'package:pocket_hisab/screens/groups/groups_screen.dart';
import 'package:pocket_hisab/screens/home/widgets/salary_card.dart';
import 'package:pocket_hisab/screens/home/widgets/saving_card.dart';
import 'package:pocket_hisab/screens/emi/emi_screen.dart';
import 'package:pocket_hisab/screens/emi/add_emi_screen.dart';
import 'package:pocket_hisab/screens/expense/add_expense_screen.dart';
import 'package:pocket_hisab/utils/easter_egg_messages.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';
import 'package:showcaseview/showcaseview.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.tabController,
    required this.incomeKey,
  });
  final TabController tabController;
  final GlobalKey incomeKey;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) {
      return "Good morning 🌅";
    } else if (hour >= 12 && hour < 17) {
      return "Good afternoon ☀️";
    } else if (hour >= 17 && hour < 21) {
      return "Good evening 🌆";
    } else {
      return "Good night 🌙";
    }
  }

  DateTime? lastTriggered;

  @override
  Widget build(BuildContext context) {
    final dashCtrl = Get.find<DashboardController>();
    final resetCtrl = Get.find<MonthlyResetController>();
    final walletCtrl = Get.find<WalletController>();
    final emiCtrl = Get.find<EmiController>();
    final savingCtrl = Get.find<SavingController>();
    final personCtrl = Get.find<PersonController>();
    final salaryCtrl = Get.find<SalaryController>();
    final settingsCtrl = Get.find<SettingsController>();
    final transactionCtrl = Get.find<TransactionController>();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: NotificationListener(
          onNotification: (notification) {
            if (notification is ScrollNotification) {
              if (notification.metrics.pixels < -145) {
                final now = DateTime.now();

                if (lastTriggered == null ||
                    now.difference(lastTriggered!) >
                        const Duration(seconds: 5)) {
                  final randomMessage = getContextualEasterEgg(
                    salaryLeft: salaryCtrl.latestSalary != null
                        ? (salaryCtrl.latestSalary!.amount -
                              walletCtrl.totalAddedFromSalary -
                              emiCtrl.totalMonthlyEmi -
                              transactionCtrl.totalSalaryExpenses -
                              savingCtrl.totalAddedFromSalary)
                        : 0,
                    latestSalary: salaryCtrl.latestSalary?.amount ?? 0,
                    walletBalance: walletCtrl.totalBalance,
                    savings: savingCtrl.totalSavings,
                    totalEmi: emiCtrl.totalMonthlyEmi,
                    expenseCount: transactionCtrl.expenses.length,
                    daysRemaining: resetCtrl.daysRemaining,
                  );
                  lastTriggered = now;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(randomMessage),
                      duration: Duration(seconds: 4),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            }
            return false;
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Obx(() {
                final latestSalary = salaryCtrl.latestSalary?.amount ?? 0.0;
                final month = salaryCtrl.latestSalary?.month == null
                    ? DateFormat('MMM').format(DateTime.now())
                    : salaryCtrl.latestSalary!.month;

                final walletAdded = walletCtrl.totalAddedFromSalary;
                final salarySpent = transactionCtrl.totalSalaryExpenses;
                final savingAdded = savingCtrl.totalAddedFromSalary;

                final salaryLeft =
                    latestSalary -
                    walletAdded -
                    // emiPaid -
                    salarySpent -
                    savingAdded;
                final percentage = latestSalary > 0
                    ? (salaryLeft / latestSalary)
                    : 0.0;
                final displayPercent = (percentage * 100)
                    .clamp(0, 100)
                    .toStringAsFixed(0);

                final walletBalance = walletCtrl.totalBalance;
                final walletMax = settingsCtrl.maxWalletLimit.value;
                final walletPercent = walletMax > 0
                    ? (walletBalance / walletMax).clamp(0.0, 1.0)
                    : 0.0;

                final savings = dashCtrl.totalSavings;
                final savingsMax = settingsCtrl.maxSavingLimit.value;
                final savingsPercent = savingsMax > 0
                    ? (savings / savingsMax).clamp(0.0, 1.0)
                    : 0.0;

                final emiMonthly = dashCtrl.totalMonthlyEmi;
                final emiPaidTotal = emiCtrl.totalPaidAmount;
                final emiTotal = emiCtrl.totalAmount;
                final emiPercent = emiTotal > 0
                    ? (emiPaidTotal / emiTotal).clamp(0.0, 1.0)
                    : 0.0;

                final hisabBalance = personCtrl.netBalance.value;
                final isGetting = hisabBalance >= 0;

                final todayStr = DateFormat(
                  'EEEE, MMMM d',
                ).format(DateTime.now());

                return Column(
                  spacing: 16,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Hero Card (Gradient background, balance left, cycle tracker)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: isDark
                              ? [
                                  Color.alphaBlend(
                                    context.themePrimary.withValues(
                                      alpha: 0.20,
                                    ),
                                    AppColors.darkCard,
                                  ),
                                  Color.alphaBlend(
                                    context.themePrimary.withValues(
                                      alpha: 0.20,
                                    ),
                                    AppColors.darkCard,
                                  ),
                                ]
                              : [
                                  Color.alphaBlend(
                                    Colors.black.withValues(alpha: 0.15),
                                    context.themePrimary,
                                  ),
                                  context.themePrimary,
                                ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).primaryColor.withValues(alpha: 0.25),
                            blurRadius: 16,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "$month Balance Left",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    CurrencyHelper.format(salaryLeft),
                                    style: const TextStyle(
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Showcase(
                                key: widget.incomeKey,
                                title: "Add Income (આવક ઉમેરો)",
                                description:
                                    "Start by entering your monthly income to track your balance.",
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white.withValues(
                                      alpha: 0.2,
                                    ),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 8,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: Colors.white.withValues(
                                          alpha: 0.3,
                                        ),
                                      ),
                                    ),
                                  ),
                                  onPressed: () {
                                    Get.bottomSheet(
                                      const AddSalaryBottomSheet(),
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    "Add Income",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Text(
                                "Total Income: ${CurrencyHelper.format(latestSalary)}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                "$displayPercent% remaining",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: percentage.clamp(0.0, 1.0),
                              backgroundColor: Colors.white.withValues(
                                alpha: 0.25,
                              ),
                              color: percentage > 0.3
                                  ? Colors.green.shade200
                                  : Colors.red.shade300,
                              minHeight: 8,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Cycle progress row
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_today_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Cycle: ${(resetCtrl.cycleProgress * 100).toStringAsFixed(0)}%',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${resetCtrl.daysRemaining} days left',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Quick Action Hub
                    if (false)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        spacing: 12,
                        children: [
                          Text(
                            "Quick Actions",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildQuickAction(
                                context: context,
                                icon: Icons.add_card_outlined,
                                label: "Expense",
                                color: Colors.red,
                                onTap: () =>
                                    Get.to(() => const AddExpenseScreen()),
                              ),
                              _buildQuickAction(
                                context: context,
                                icon: Icons.savings_outlined,
                                label: "Saving",
                                color: Colors.green,
                                onTap: () {
                                  Get.bottomSheet(
                                    const AddSavingBottomSheet(),
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                  );
                                },
                              ),
                              _buildQuickAction(
                                context: context,
                                icon: Icons.credit_card_outlined,
                                label: "Add EMI",
                                color: Colors.blue,
                                onTap: () => Get.to(() => const AddEmiScreen()),
                              ),
                              _buildQuickAction(
                                context: context,
                                icon: Icons.account_balance_wallet_outlined,
                                label: "Add Income",
                                color: context.themePrimary,
                                onTap: () {
                                  Get.bottomSheet(
                                    const AddSalaryBottomSheet(),
                                    isScrollControlled: true,
                                    backgroundColor: Colors.transparent,
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),

                    // 3 Total Money Summary Card
                    Builder(
                      builder: (context) {
                        final totalMoney = salaryLeft + walletBalance + savings;
                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkCard : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: isDark
                                  ? Colors.grey.shade800
                                  : Colors.grey.shade100,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Total Available",
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: context.themePrimary.withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      CurrencyHelper.format(totalMoney),
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: context.themePrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (false) const SizedBox(height: 14),
                              if (false)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildMoneyBreakdown(
                                        context: context,
                                        label: "Salary Left",
                                        amount: salaryLeft,
                                        color: const Color(0xFF0F766E),
                                        icon: Icons.account_balance_rounded,
                                      ),
                                    ),
                                    const SizedBox(width: 1),
                                    Container(
                                      width: 1,
                                      height: 36,
                                      color: isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade200,
                                    ),
                                    const SizedBox(width: 1),
                                    Expanded(
                                      child: _buildMoneyBreakdown(
                                        context: context,
                                        label: "Wallet",
                                        amount: walletBalance,
                                        color: context.themePrimary,
                                        icon: Icons
                                            .account_balance_wallet_rounded,
                                      ),
                                    ),
                                    const SizedBox(width: 1),
                                    Container(
                                      width: 1,
                                      height: 36,
                                      color: isDark
                                          ? Colors.grey.shade800
                                          : Colors.grey.shade200,
                                    ),
                                    const SizedBox(width: 1),
                                    Expanded(
                                      child: _buildMoneyBreakdown(
                                        context: context,
                                        label: "Savings",
                                        amount: savings,
                                        color: Colors.teal,
                                        icon: Icons.savings_rounded,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        );
                      },
                    ),

                    // 4. Accounts / Bento Grid
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 12,
                      children: [
                        Text(
                          "Accounts & Budgets",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Column(
                          spacing: 12,
                          children: [
                            Row(
                              spacing: 12,
                              children: [
                                Expanded(
                                  child: _buildBentoCard(
                                    context: context,
                                    title: "Wallet",
                                    value: CurrencyHelper.format(walletBalance),
                                    subtitle:
                                        "${(walletPercent * 100).toStringAsFixed(0)}% Limit Used",
                                    progress: walletPercent,
                                    icon: Icons.account_balance_wallet_rounded,
                                    accentColor: Colors.green,
                                    onTap: () =>
                                        widget.tabController.animateTo(1),
                                  ),
                                ),
                                Expanded(
                                  child: _buildBentoCard(
                                    context: context,
                                    title: "Savings",
                                    value: CurrencyHelper.format(savings),
                                    subtitle:
                                        "Goal: ${CurrencyHelper.format(savingsMax)}",
                                    progress: savingsPercent,
                                    icon: Icons.savings_rounded,
                                    accentColor: Colors.teal,
                                    onTap: () {
                                      Get.bottomSheet(
                                        const AddSavingBottomSheet(),
                                        isScrollControlled: true,
                                        backgroundColor: Colors.transparent,
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              spacing: 12,
                              children: [
                                Expanded(
                                  child: _buildBentoCard(
                                    context: context,
                                    title: "Monthly EMIs",
                                    value: CurrencyHelper.format(emiMonthly),
                                    subtitle:
                                        "Paid: ${emiCtrl.paidEmisCount}/${emiCtrl.totalActiveEmisCount}",
                                    progress: emiPercent,
                                    icon: Icons.credit_card_rounded,
                                    accentColor: Colors.blue,
                                    onTap: () =>
                                        Get.to(() => const EmiScreen()),
                                  ),
                                ),
                                Expanded(
                                  child: _buildHisabCard(
                                    context: context,
                                    title: "Hisab",
                                    value: CurrencyHelper.format(
                                      hisabBalance.abs(),
                                    ),
                                    isGetting: isGetting,
                                    count: personCtrl.persons.length,
                                    onTap: () =>
                                        widget.tabController.animateTo(2),
                                  ),
                                ),
                              ],
                            ),
                            _buildBentoCard(
                              context: context,
                              title: "Group Expense",
                              value: "",
                              subtitle: "",
                              progress: 0,
                              icon: Icons.groups,
                              accentColor: Colors.purple,
                              onTap: () => Get.to(() => const GroupsScreen()),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMoneyBreakdown({
    required BuildContext context,
    required String label,
    required double amount,
    required Color color,
    required IconData icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 6),
        Text(
          CurrencyHelper.format(amount),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildQuickAction({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: (MediaQuery.of(context).size.width - 32 - 36) / 4,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBentoCard({
    required BuildContext context,
    required String title,
    required String value,
    required String subtitle,
    required double progress,
    required IconData icon,
    required Color accentColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          image: title.toLowerCase() == "group expense"
              ? DecorationImage(
                  image: AssetImage('assets/group_expense.png'),
                  alignment: .centerEnd,
                )
              : null,
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accentColor, size: 18),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: isDark
                    ? Colors.grey.shade800
                    : Colors.grey.shade100,
                color: accentColor,
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHisabCard({
    required BuildContext context,
    required String title,
    required String value,
    required bool isGetting,
    required int count,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = isGetting ? Colors.green : Colors.red;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.people_alt_rounded,
                    color: Colors.orange,
                    size: 18,
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 10,
                  color: Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
            const SizedBox(height: 8),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            //   decoration: BoxDecoration(
            //     color: statusColor.withValues(alpha: 0.1),
            //     borderRadius: BorderRadius.circular(8),
            //   ),
            //   child: Text(
            //     isGetting ? "YOU GET" : "YOU GIVE",
            //     style: TextStyle(
            //       color: statusColor,
            //       fontSize: 9,
            //       fontWeight: FontWeight.bold,
            //     ),
            //   ),
            // ),
            const SizedBox(height: 10),
            Text(
              "$count Friends active",
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }
}
