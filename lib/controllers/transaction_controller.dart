import 'package:get/get.dart';
import 'package:pocket_hisab/models/expense_model.dart';
import 'package:pocket_hisab/services/database_service.dart';

class TransactionController extends GetxController {
  final _db = DatabaseService();
  static const _table = 'expenses';

  final RxList<ExpenseModel> expenses = <ExpenseModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    final rows = await _db.getAll(_table);
    expenses.value = rows.map(ExpenseModel.fromMap).toList();
    isLoading.value = false;
  }

  Future<bool> addExpense(ExpenseModel expense) async {
    try {
      final id = await _db.insert(_table, expense.toMap());
      expenses.insert(0, expense.copyWith(id: id));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateExpense(ExpenseModel expense) async {
    try {
      await _db.update(_table, expense.toMap(), expense.id!);
      final idx = expenses.indexWhere((e) => e.id == expense.id);
      if (idx != -1) expenses[idx] = expense;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteExpense(int id) async {
    try {
      await _db.delete(_table, id);
      expenses.removeWhere((e) => e.id == id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Derived values ──────────────────────────────────────────────────────

  double get totalExpenses => expenses.fold(0.0, (sum, e) => sum + e.amount);

  Map<String, double> get expensesByCategory {
    final Map<String, double> map = {};
    for (final e in expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }
}
