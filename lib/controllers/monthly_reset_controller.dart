import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pocket_hisab/controllers/salary_controller.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/controllers/saving_controller.dart';
import 'package:pocket_hisab/controllers/transaction_controller.dart';
import 'package:pocket_hisab/controllers/emi_controller.dart';
import 'package:pocket_hisab/controllers/settings_controller.dart';
import 'package:pocket_hisab/models/monthly_archive_model.dart';
import 'package:pocket_hisab/services/database_service.dart';

class MonthlyResetController extends GetxController {
  static const _prefKeyLastReset = 'monthly_reset_last_ym'; // "2025-04"
  static const _archiveTable = 'monthly_archives';

  final _db = DatabaseService();
  final _settingsCtrl = Get.find<SettingsController>();

  final RxList<MonthlyArchiveModel> archives = <MonthlyArchiveModel>[].obs;
  final RxBool isLoading = false.obs;

  // Reactive flags for the dialog
  final RxBool needsReset = false.obs;
  final RxString pendingMonth = ''.obs; // "April 2025"

  @override
  void onInit() {
    super.onInit();
    _loadArchives();
  }

  // ── Archives ──────────────────────────────────────────────────────────────

  Future<void> _loadArchives() async {
    isLoading.value = true;
    final rows = await _db.getAll(_archiveTable);
    archives.value = rows.map(MonthlyArchiveModel.fromMap).toList();
    isLoading.value = false;
  }

  // ── New-month detection ───────────────────────────────────────────────────

  /// Call this on app startup (after all controllers are ready).
  /// Returns true if a reset dialog should be shown.
  Future<bool> checkIfResetNeeded() async {
    final prefs = await SharedPreferences.getInstance();
    final lastYM = prefs.getString(_prefKeyLastReset) ?? '';

    final now = DateTime.now();
    final startDay = _settingsCtrl.cycleStartDay.value;

    // If today is before the start day, we are still in the "previous" calendar month's cycle
    // But we only care about triggering a reset once we HIT or PASS the start day of a month
    // that we haven't reset for yet.
    if (now.day < startDay) return false;

    final currentYM = '${now.year}-${now.month.toString().padLeft(2, '0')}';

    if (lastYM == currentYM) return false; // already reset for this month's start day

    // The month we are archiving is logically the one that just "ended"
    // (either the previous calendar month, or the 30 days prior to today)
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];

    // Identify the month we just finished
    int finishedMonthIdx = now.month - 1; // 1 -> 0 (Jan)
    int finishedYear = now.year;

    if (finishedMonthIdx == 0) {
      finishedMonthIdx = 12;
      finishedYear--;
    }

    pendingMonth.value = '${months[finishedMonthIdx - 1]} $finishedYear';
    needsReset.value = true;
    return true;
  }

  /// Returns 0.0 to 1.0 representing how far we are into the current cycle.
  double get cycleProgress {
    final now = DateTime.now();
    final startDay = _settingsCtrl.cycleStartDay.value;

    DateTime cycleStart;
    DateTime cycleEnd;

    if (now.day >= startDay) {
      cycleStart = DateTime(now.year, now.month, startDay);
      // Next month
      int nextMonth = now.month + 1;
      int nextYear = now.year;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear++;
      }
      cycleEnd = DateTime(nextYear, nextMonth, startDay);
    } else {
      // Previous month
      int prevMonth = now.month - 1;
      int prevYear = now.year;
      if (prevMonth < 1) {
        prevMonth = 12;
        prevYear--;
      }
      cycleStart = DateTime(prevYear, prevMonth, startDay);
      cycleEnd = DateTime(now.year, now.month, startDay);
    }

    final totalDays = cycleEnd.difference(cycleStart).inDays;
    final daysPassed = now.difference(cycleStart).inDays;

    return (daysPassed / totalDays).clamp(0.0, 1.0);
  }

  int get daysRemaining {
    final now = DateTime.now();
    final startDay = _settingsCtrl.cycleStartDay.value;

    DateTime cycleEnd;
    if (now.day >= startDay) {
      int nextMonth = now.month + 1;
      int nextYear = now.year;
      if (nextMonth > 12) {
        nextMonth = 1;
        nextYear++;
      }
      cycleEnd = DateTime(nextYear, nextMonth, startDay);
    } else {
      cycleEnd = DateTime(now.year, now.month, startDay);
    }

    return cycleEnd.difference(now).inDays;
  }

  // ── Reset execution ───────────────────────────────────────────────────────

  /// Performs the full monthly reset.
  /// [keepWallet] – if true the wallet balance is carried over; if false it is
  ///               zeroed out (balance moved to expenses as a "reset entry").
  Future<void> performReset({required bool keepWallet}) async {
    isLoading.value = true;

    try {
      final salaryCtrl = Get.find<SalaryController>();
      final walletCtrl = Get.find<WalletController>();
      final savingCtrl = Get.find<SavingController>();
      final expenseCtrl = Get.find<TransactionController>();

      // ── 1. Snapshot current figures ────────────────────────────────────
      final salaryAmount = salaryCtrl.latestSalary?.amount ?? 0.0;
      final totalExpenses = expenseCtrl.totalExpenses;
      final totalAddedToSavings = savingCtrl.totalAddedFromSalary;
      final totalAddedToWallet = walletCtrl.totalAddedFromSalary;
      final walletBalance = walletCtrl.totalBalance;
      final savingsBalance = savingCtrl.totalSavings;

      final now = DateTime.now();
      const monthNames = [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December',
      ];
      final prevMonth = now.month == 1 ? 12 : now.month - 1;
      final prevYear = now.month == 1 ? now.year - 1 : now.year;

      // ── 2. Archive ─────────────────────────────────────────────────────
      final archive = MonthlyArchiveModel(
        month: monthNames[prevMonth - 1],
        year: prevYear,
        salaryAmount: salaryAmount,
        totalExpenses: totalExpenses,
        totalAddedToSavings: totalAddedToSavings,
        totalAddedToWallet: totalAddedToWallet,
        walletBalanceAtReset: walletBalance,
        savingsBalanceAtReset: savingsBalance,
        walletKept: keepWallet,
        createdAt: now.toIso8601String(),
      );
      final archiveId = await _db.insert(_archiveTable, archive.toMap());
      archives.insert(0, archive.copyWith(id: archiveId));

      // ── 3. Clear current-cycle salary records ──────────────────────────
      // We keep saving balances & saving transactions (permanent savings).
      // We delete salary-related expenses only if user chose to clear wallet.
      final db = await _db.database;
      await db.delete('salaries'); // fresh salary cycle
      await db.delete('wallet_transactions'); // clear salary-linked credits
      await db.delete('saving_transactions',
          where: "source = ?", whereArgs: ['Salary']); // clear salary→savings

      // ── 4. Wallet handling ─────────────────────────────────────────────
      if (!keepWallet) {
        // Zero out every wallet balance
        for (final wallet in walletCtrl.wallets) {
          final zeroed = wallet.copyWith(balance: 0.0);
          await _db.update('wallets', zeroed.toMap(), wallet.id!);
        }
      }
      // (If keepWallet == true the existing balance is preserved as-is)

      // ── 5. Clear this-cycle expenses (they belong to the old cycle) ────
      await db.delete('expenses');

      // ── 6. Reload all controllers ──────────────────────────────────────
      await salaryCtrl.fetchAll();
      await walletCtrl.fetchAll();
      await savingCtrl.fetchAll();
      await expenseCtrl.fetchAll();

      // ── 7. Persist reset timestamp ─────────────────────────────────────
      final prefs = await SharedPreferences.getInstance();
      final currentYM =
          '${now.year}-${now.month.toString().padLeft(2, '0')}';
      await prefs.setString(_prefKeyLastReset, currentYM);

      needsReset.value = false;
      Get.back();
      Get.snackbar(
        '🎉 New Month Started!',
        'Previous cycle archived. Fresh salary cycle begins.',
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      print("$e");
      Get.snackbar('Error', 'Reset failed: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ── Manual reset (from Settings) ─────────────────────────────────────────

  /// Triggers the reset flow manually (e.g. from the Settings screen).
  Future<void> triggerManualReset() async {
    final now = DateTime.now();
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
    ];
    pendingMonth.value = '${months[now.month - 1]} ${now.year}';
    needsReset.value = true;
  }

  // ── Derived ───────────────────────────────────────────────────────────────

  MonthlyArchiveModel? get latestArchive =>
      archives.isEmpty ? null : archives.first;

  int get totalCyclesArchived => archives.length;
}
