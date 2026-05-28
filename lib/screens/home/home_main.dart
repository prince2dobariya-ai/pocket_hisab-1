import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/monthly_reset_controller.dart';
import 'package:pocket_hisab/screens/expense/add_expense_screen.dart';
import 'package:pocket_hisab/screens/hisab/person_screen.dart';
import 'package:pocket_hisab/screens/home/all_transactions_screen.dart';
import 'package:pocket_hisab/screens/home/home_screen.dart';
import 'package:pocket_hisab/screens/settings/setting_screen.dart';
import 'package:pocket_hisab/screens/wallet/wallet_screen.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/widgets/custom_text.dart';
import 'package:pocket_hisab/widgets/monthly_reset_dialog.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    // Check for monthly reset after first frame so everything is rendered
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final resetCtrl = Get.find<MonthlyResetController>();
      final needed = await resetCtrl.checkIfResetNeeded();
      if (needed) {
        await MonthlyResetDialog.show();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  DateTime? lastBackPressed;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (_tabController.index != 0) {
          setState(() {
            _tabController.animateTo(0);
          });
          return;
        }

        final now = DateTime.now();

        if (lastBackPressed == null ||
            now.difference(lastBackPressed!) > const Duration(seconds: 2)) {
          lastBackPressed = now;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit'),
              duration: Duration(seconds: 2),
            ),
          );

          return;
        }

        SystemNavigator.pop();
      },
      child: Scaffold(
        appBar: CustomAppBar(
          title: "Khissu",
          actions: [
            IconButton(
              onPressed: () {
                Get.to(() => AllTransactionsScreen());
              },
              icon: Icon(Icons.history_outlined),
            ),
            IconButton(
              onPressed: () {
                Get.to(() => SettingScreen());
              },
              icon: Icon(Icons.settings_outlined),
            ),
          ],
        ),
        body: TabBarView(
          controller: _tabController,
          physics: NeverScrollableScrollPhysics(),
          children: [
            HomeScreen(tabController: _tabController),
            WalletScreen(),
            PersonScreen(),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          tooltip: 'Expense',
          heroTag: 'expense',
          onPressed: () {
            Get.to(() => AddExpenseScreen());
          },
          child: Icon(Icons.add, size: 34),
        ),
        floatingActionButtonLocation: .endContained,
        bottomNavigationBar: BottomAppBar(
          shape: CircularNotchedRectangle(),
          notchMargin: 6,
          height: 82,
          padding: .symmetric(vertical: 4, horizontal: 16),
          child: Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    _tabController.animateTo(0);
                  });
                },
                icon: Column(
                  children: [
                    Icon(
                      Icons.dashboard_outlined,
                      size: 34,
                      color: _tabController.index == 0
                          ? AppColors.primary
                          : Colors.grey,
                    ),
                    AppText(
                      'Home',
                      color: _tabController.index == 0
                          ? AppColors.primary
                          : Colors.grey,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _tabController.animateTo(1);
                  });
                },
                icon: Column(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      size: 34,
                      color: _tabController.index == 1
                          ? AppColors.primary
                          : Colors.grey,
                    ),
                    AppText(
                      'Wallet',
                      color: _tabController.index == 1
                          ? AppColors.primary
                          : Colors.grey,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    _tabController.animateTo(2);
                  });
                },
                icon: Column(
                  children: [
                    Icon(
                      Icons.group_outlined,
                      size: 34,
                      color: _tabController.index == 2
                          ? AppColors.primary
                          : Colors.grey,
                    ),
                    AppText(
                      'Hisabs',
                      color: _tabController.index == 2
                          ? AppColors.primary
                          : Colors.grey,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.person, color: Colors.transparent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
