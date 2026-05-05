import 'package:get/get.dart';
import 'package:pocket_hisab/controllers/emi_controller.dart';
import 'package:pocket_hisab/controllers/hisab_controller.dart';
import 'package:pocket_hisab/controllers/salary_controller.dart';
import 'package:pocket_hisab/controllers/transaction_controller.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';

/// Aggregates data from all feature controllers to power the home dashboard.
class DashboardController extends GetxController {
  late final TransactionController _expenseCtrl;
  late final WalletController _walletCtrl;
  late final SalaryController _salaryCtrl;
  late final EmiController _emiCtrl;
  late final HisabController _hisabCtrl;

  @override
  void onInit() {
    super.onInit();
    _expenseCtrl = Get.find<TransactionController>();
    _walletCtrl = Get.find<WalletController>();
    _salaryCtrl = Get.find<SalaryController>();
    _emiCtrl = Get.find<EmiController>();
    _hisabCtrl = Get.find<HisabController>();
  }

  // ── Summary getters ─────────────────────────────────────────────────────

  double get totalWalletBalance => _walletCtrl.totalBalance;

  double get totalExpenses => _expenseCtrl.totalExpenses;

  double get latestSalary => _salaryCtrl.latestSalary?.amount ?? 0.0;

  double get totalMonthlyEmi => _emiCtrl.totalMonthlyEmi;

  double get totalOwedToMe => _hisabCtrl.totalOwedToMe;

  double get totalIOwe => _hisabCtrl.totalIOwe;

  /// Net savings = latest salary − expenses − wallet additions − EMIs
  double get netSavings =>
      latestSalary - _walletCtrl.totalAddedFromSalary - totalMonthlyEmi;
}
