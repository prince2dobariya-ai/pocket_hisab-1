import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pocket_hisab/controllers/transaction_controller.dart';
import 'package:pocket_hisab/controllers/settings_controller.dart';
import 'package:pocket_hisab/models/expense_model.dart';
import 'package:pocket_hisab/models/emi_model.dart';
import 'package:pocket_hisab/services/database_service.dart';

class EmiController extends GetxController {
  final _db = DatabaseService();
  static const _table = 'emis';

  final RxList<EmiModel> emis = <EmiModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    final rows = await _db.getAll(_table);
    emis.value = rows.map(EmiModel.fromMap).toList();
    isLoading.value = false;
  }

  Future<bool> addEmi(EmiModel emi) async {
    try {
      final id = await _db.insert(_table, emi.toMap());
      emis.insert(0, emi.copyWith(id: id));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateEmi(EmiModel emi) async {
    try {
      await _db.update(_table, emi.toMap(), emi.id!);
      final idx = emis.indexWhere((e) => e.id == emi.id);
      if (idx != -1) emis[idx] = emi;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteEmi(int id) async {
    try {
      await _db.delete(_table, id);
      emis.removeWhere((e) => e.id == id);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Mark one month's instalment as paid.
  Future<bool> payInstalment(int emiId, {String paymentMethod = 'Salary'}) async {
    final idx = emis.indexWhere((e) => e.id == emiId);
    if (idx == -1) return false;
    final emi = emis[idx];

    final newPaid = emi.paidAmount + emi.monthlyAmount;
    final newRemaining = emi.totalAmount - newPaid;
    final newStatus = newRemaining <= 0 ? 'completed' : 'active';

    final updated = emi.copyWith(
      paidAmount: newPaid.clamp(0, emi.totalAmount),
      remainingAmount: newRemaining.clamp(0, emi.totalAmount),
      status: newStatus,
      lastPaidAt: DateTime.now().toIso8601String(),
    );
    final success = await updateEmi(updated);
    if (success) {
      try {
        final txCtrl = Get.find<TransactionController>();
        await txCtrl.addExpense(
          ExpenseModel(
            category: 'EMI',
            amount: emi.monthlyAmount,
            note: 'EMI Payment: ${emi.name}',
            date: DateFormat('d/M/yyyy').format(DateTime.now()),
            createdAt: DateTime.now().toIso8601String(),
            paymentMethod: paymentMethod,
          ),
        );
      } catch (e) {
        print('Error adding EMI expense: $e');
      }
    }
    return success;
  }

  // ── Derived ─────────────────────────────────────────────────────────────

  List<EmiModel> get activeEmis =>
      emis.where((e) => e.status == 'active').toList();

  double get totalMonthlyEmi =>
      activeEmis.fold(0.0, (sum, e) => sum + e.monthlyAmount);

  double get totalRemainingAmount =>
      activeEmis.fold(0.0, (sum, e) => sum + e.remainingAmount);

  double get totalPaidAmount =>
      activeEmis.fold(0.0, (sum, e) => sum + e.paidAmount);

  double get totalAmount =>
      activeEmis.fold(0.0, (sum, e) => sum + e.totalAmount);

  // ── Cycle Tracking ──────────────────────────────────────────────────────

  bool isPaidInCurrentCycle(EmiModel emi) {
    if (emi.lastPaidAt == null) return false;

    final lastPaid = DateTime.parse(emi.lastPaidAt!);
    final now = DateTime.now();

    // Get cycle start day from settings
    int startDay = 1;
    try {
      final settings = Get.find<SettingsController>();
      startDay = settings.cycleStartDay.value;
    } catch (_) {}

    DateTime cycleStart;
    if (now.day >= startDay) {
      cycleStart = DateTime(now.year, now.month, startDay);
    } else {
      int prevMonth = now.month - 1;
      int prevYear = now.year;
      if (prevMonth < 1) {
        prevMonth = 12;
        prevYear--;
      }
      cycleStart = DateTime(prevYear, prevMonth, startDay);
    }

    return lastPaid.isAfter(cycleStart) || lastPaid.isAtSameMomentAs(cycleStart);
  }

  int get paidEmisCount =>
      activeEmis.where((e) => isPaidInCurrentCycle(e)).length;

  int get totalActiveEmisCount => activeEmis.length;
}
