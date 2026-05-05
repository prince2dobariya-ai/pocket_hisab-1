/*
* Add Salary
* update salary
* calculate salary left
* salary analytics
*/

import 'package:get/get.dart';
import 'package:pocket_hisab/models/salary_model.dart';
import 'package:pocket_hisab/services/database_service.dart';

class SalaryController extends GetxController {
  final _db = DatabaseService();
  static const _table = 'salaries';

  final RxList<SalaryModel> salaries = <SalaryModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxDouble totalExpenses =
      0.0.obs; // set externally by DashboardController

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  // ── CRUD ────────────────────────────────────────────────────────────────

  Future<void> fetchAll() async {
    isLoading.value = true;
    final rows = await _db.getAll(_table);
    salaries.value = rows.map(SalaryModel.fromMap).toList();
    isLoading.value = false;
  }

  Future<bool> addSalary(SalaryModel salary) async {
    try {
      final id = await _db.insert(_table, salary.toMap());
      salaries.insert(0, salary.copyWith(id: id));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateSalary(SalaryModel salary) async {
    try {
      await _db.update(_table, salary.toMap(), salary.id!);
      final idx = salaries.indexWhere((s) => s.id == salary.id);
      if (idx != -1) salaries[idx] = salary;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteSalary(int id) async {
    try {
      await _db.delete(_table, id);
      salaries.removeWhere((s) => s.id == id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Analytics ────────────────────────────────────────────────────────────

  /// Most recently added salary entry.
  SalaryModel? get latestSalary => salaries.isEmpty ? null : salaries.first;

  /// Total salary received across all records.
  double get totalSalaryReceived =>
      salaries.fold(0.0, (sum, s) => sum + s.amount);

  /// Salary left after deducting expenses (requires totalExpenses to be set).
  double get salaryLeft => (latestSalary?.amount ?? 0.0) - totalExpenses.value;

  /// Spending percentage relative to the latest salary (0–100).
  double get spendingPercentage {
    final salary = latestSalary?.amount ?? 0.0;
    if (salary == 0) return 0;
    return ((totalExpenses.value / salary) * 100).clamp(0, 100);
  }

  /// Salary breakdown per month (for charts / analytics).
  Map<String, double> get salaryByMonth {
    final Map<String, double> map = {};
    for (final s in salaries) {
      final key = '${s.month} ${s.year}';
      map[key] = (map[key] ?? 0) + s.amount;
    }
    return map;
  }

  /// Average salary across all records.
  double get averageSalary {
    if (salaries.isEmpty) return 0;
    return totalSalaryReceived / salaries.length;
  }
}
