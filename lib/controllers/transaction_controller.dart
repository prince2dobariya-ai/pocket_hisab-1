import 'package:get/get.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
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
      final expense = expenses.firstWhereOrNull((e) => e.id == id);
      if (expense == null) return false;

      // 1. If it was a Wallet payment, revert wallet balance/transaction
      if (expense.paymentMethod == 'Wallet') {
        final walletCtrl = Get.find<WalletController>();
        // Find the linked transaction in wallet
        // The source is "Expense: ${expense.category}" or "Lent to ${person}"
        // To be safe, we can look for a transaction with same amount and roughly same time,
        // but it's better to just credit the wallet back if we can't find the exact one.
        // For now, let's try to find it by source pattern.
        final linkedTx = walletCtrl.transactions.firstWhereOrNull(
          (t) =>
              t.amount == expense.amount &&
              (t.source == 'Expense: ${expense.category}' ||
                  t.source.startsWith('Lent to')),
        );

        if (linkedTx != null) {
          await walletCtrl.deleteTransaction(linkedTx.id!);
        } else if (walletCtrl.wallets.isNotEmpty) {
          // Fallback: just credit the amount back to main wallet
          await walletCtrl.credit(
            walletId: walletCtrl.wallets.first.id!,
            amount: expense.amount,
            source: 'Revert: ${expense.category}',
            note: 'Reverted deleted expense',
          );
        }
      }

      // 2. If it was a Friend category, we should ideally remove the hisab too.
      // But hisab entries are more complex to find without a direct link.

      // 3. Delete expense record
      await _db.delete(_table, id);
      expenses.removeWhere((e) => e.id == id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Derived values ──────────────────────────────────────────────────────

  double get totalExpenses => expenses.fold(0.0, (sum, e) => sum + e.amount);

  double get totalSalaryExpenses => expenses
      .where((e) => e.paymentMethod == 'Salary')
      .fold(0.0, (sum, e) => sum + e.amount);

  Map<String, double> get expensesByCategory {
    final Map<String, double> map = {};
    for (final e in expenses) {
      map[e.category] = (map[e.category] ?? 0) + e.amount;
    }
    return map;
  }
}
