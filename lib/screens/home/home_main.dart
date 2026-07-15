import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pocket_hisab/constants/app_theme.dart';
import 'package:pocket_hisab/controllers/monthly_reset_controller.dart';
import 'package:pocket_hisab/screens/expense/add_expense_screen.dart';
import 'package:pocket_hisab/screens/hisab/person_screen.dart';
import 'package:pocket_hisab/screens/pro/khissu_pro_screen.dart';
import 'package:pocket_hisab/screens/home/all_transactions_screen.dart';
import 'package:pocket_hisab/screens/home/home_screen.dart';
import 'package:pocket_hisab/screens/settings/setting_screen.dart';
import 'package:pocket_hisab/screens/wallet/wallet_screen.dart';
import 'package:pocket_hisab/screens/groups/groups_screen.dart';
import 'package:pocket_hisab/widgets/custom_appbar.dart';
import 'package:get/get.dart';
import 'package:pocket_hisab/widgets/custom_text.dart';
import 'package:pocket_hisab/widgets/monthly_reset_dialog.dart';
import 'package:pocket_hisab/controllers/pro_controller.dart';
import 'package:pocket_hisab/controllers/app_update_controller.dart';
import 'package:pocket_hisab/controllers/settings_controller.dart';
import 'package:showcaseview/showcaseview.dart';

class HomeMain extends StatefulWidget {
  const HomeMain({super.key});

  @override
  State<HomeMain> createState() => _HomeMainState();
}

class _HomeMainState extends State<HomeMain>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey _incomeKey = GlobalKey();
  final GlobalKey _expenseKey = GlobalKey();
  final GlobalKey _walletKey = GlobalKey();
  final GlobalKey _hisabKey = GlobalKey();
  bool _isCheckingReset = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      if (mounted) {
        setState(() {
          _isCheckingReset = false;
        });
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
    final proCtrl = Get.find<ProController>();
    final updateCtrl = Get.put(AppUpdateController());
    final settingsCtrl = Get.find<SettingsController>();

    return ShowCaseWidget(
      builder: (innerContext) {
        return Obx(() {
          final hasSeen = settingsCtrl.hasSeenQuickGuide.value;
          if (!hasSeen && !_isCheckingReset) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Future.delayed(const Duration(milliseconds: 400), () {
                if (innerContext.mounted) {
                  ShowCaseWidget.of(innerContext).startShowCase([
                    _incomeKey,
                    _expenseKey,
                    _walletKey,
                    _hisabKey,
                  ]);
                }
              });
              settingsCtrl.setHasSeenQuickGuide(true);
            });
          }

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
                  now.difference(lastBackPressed!) >
                      const Duration(seconds: 2)) {
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
                centerTitle: false,
                titleWidget: Obx(
                  () => AppText(
                    proCtrl.isPro.value ? "Khissu Pro" : "Khissu",
                    size: 18,
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () {
                      Get.to(() => const KhissuProScreen());
                    },
                    icon: Icon(
                      Icons.diamond_rounded,
                      size: 24,
                      color: context.themePrimary,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Get.to(() => AllTransactionsScreen());
                    },
                    icon: Icon(Icons.receipt_long_outlined),
                  ),
                  IconButton(
                    onPressed: () {
                      Get.to(() => SettingScreen());
                    },
                    icon: const Icon(Icons.settings_outlined),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              body: Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        HomeScreen(
                          tabController: _tabController,
                          incomeKey: _incomeKey,
                        ),
                        const WalletScreen(),
                        const PersonScreen(),
                        const GroupsScreen(),
                      ],
                    ),
                  ),
                  Obx(() {
                    if (updateCtrl.isUpdateAvailable.value) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: context.themePrimary.withAlpha(50),
                          border: Border(
                            top: BorderSide(
                              color: context.themePrimary.withAlpha(100),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const .all(8),
                              decoration: BoxDecoration(
                                color: context.themePrimary.withAlpha(50),
                                shape: .circle,
                              ),
                              child: Icon(
                                Icons.system_update,
                                color: context.themePrimary,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const AppText(
                                    "Update Available",
                                    fontWeight: FontWeight.bold,
                                    size: 14,
                                  ),
                                  AppText(
                                    "A new version of Khissu is available.",
                                    size: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => updateCtrl.performUpdate(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: context.themePrimary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: .circular(20),
                                ),
                                padding: const .symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                minimumSize: .zero,
                              ),
                              child: const Text(
                                "UPDATE",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
              floatingActionButton: Showcase(
                key: _expenseKey,
                title: "Add Expense (ખર્ચ ઉમેરો)",
                description: "Tap this button to record any daily expenses.",
                child: FloatingActionButton(
                  tooltip: 'Expense',
                  heroTag: 'expense',
                  onPressed: () {
                    Get.to(() => AddExpenseScreen());
                  },
                  child: const Icon(Icons.add, size: 34, color: Colors.white),
                ),
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.endContained,
              bottomNavigationBar: BottomAppBar(
                shape: const CircularNotchedRectangle(),
                notchMargin: 12,
                height: 80,
                padding: const EdgeInsets.symmetric(
                  vertical: 4,
                  horizontal: 16,
                ),
                child: Row(
                  mainAxisAlignment: .spaceBetween,
                  children: [
                    IconButton(
                      tooltip: "Home",
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        setState(() {
                          _tabController.animateTo(0);
                        });
                      },
                      icon: Column(
                        children: [
                          Icon(
                            Icons.dashboard_outlined,
                            size: 30,
                            color: _tabController.index == 0
                                ? context.themePrimary
                                : Colors.grey,
                          ),
                          AppText(
                            'Home',
                            color: _tabController.index == 0
                                ? context.themePrimary
                                : Colors.grey,
                            fontWeight: _tabController.index == 0
                                ? FontWeight.bold
                                : null,
                          ),
                        ],
                      ),
                    ),
                    Showcase(
                      key: _walletKey,
                      title: "Wallet (વોલેટ)",
                      description:
                          "Track physical cash or bank accounts separately.",
                      child: IconButton(
                        tooltip: "Wallet",
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _tabController.animateTo(1);
                          });
                        },
                        icon: Column(
                          children: [
                            Icon(
                              Icons.account_balance_wallet_outlined,
                              size: 30,
                              color: _tabController.index == 1
                                  ? context.themePrimary
                                  : Colors.grey,
                            ),
                            AppText(
                              'Wallet',
                              color: _tabController.index == 1
                                  ? context.themePrimary
                                  : Colors.grey,
                              fontWeight: _tabController.index == 1
                                  ? FontWeight.bold
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    Showcase(
                      key: _hisabKey,
                      title: "Hisabs (લેતી-દેતી)",
                      description:
                          "Manage money lent to or borrowed from friends.",
                      child: IconButton(
                        tooltip: "Hisabs",
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          setState(() {
                            _tabController.animateTo(2);
                          });
                        },
                        icon: Column(
                          children: [
                            Icon(
                              Icons.group_outlined,
                              size: 30,
                              color: _tabController.index == 2
                                  ? context.themePrimary
                                  : Colors.grey,
                            ),
                            AppText(
                              'Hisabs',
                              color: _tabController.index == 2
                                  ? context.themePrimary
                                  : Colors.grey,
                              fontWeight: _tabController.index == 2
                                  ? FontWeight.bold
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.person, color: Colors.transparent),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }
}
