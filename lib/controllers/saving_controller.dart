import 'package:get/get.dart';
import 'package:pocket_hisab/controllers/dashboard_controller.dart';
import 'package:pocket_hisab/controllers/salary_controller.dart';
import 'package:pocket_hisab/controllers/wallet_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';
import 'package:pocket_hisab/models/saving_model.dart';
import 'package:pocket_hisab/models/saving_transaction_model.dart';
import 'package:pocket_hisab/screens/home/widgets/salary_card.dart';
import 'package:pocket_hisab/services/database_service.dart';
import 'package:pocket_hisab/controllers/hisab_controller.dart';
import 'package:pocket_hisab/models/hisab_model.dart';

class SavingController extends GetxController {
  final _db = DatabaseService();
  static const _savingsTable = 'savings';
  static const _txTable = 'saving_transactions';

  final RxList<SavingModel> savings = <SavingModel>[].obs;
  final RxList<SavingTransactionModel> transactions =
      <SavingTransactionModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    final savingRows = await _db.getAll(_savingsTable);

    if (savingRows.isEmpty) {
      // Create a default saving goal if none exist
      final defaultSaving = SavingModel(
        savingName: "Main Saving",
        balance: 0.0,
        createdAt: DateTime.now().toIso8601String(),
      );
      await addSaving(defaultSaving);
    } else {
      savings.value = savingRows.map(SavingModel.fromMap).toList();
    }

    final txRows = await _db.getAll(_txTable);
    transactions.value = txRows.map(SavingTransactionModel.fromMap).toList();
    isLoading.value = false;
  }

  // ── Savings ─────────────────────────────────────────────────────────────

  Future<bool> addSaving(SavingModel saving) async {
    try {
      final id = await _db.insert(_savingsTable, saving.toMap());
      savings.insert(0, saving.copyWith(id: id));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteSaving(int id) async {
    try {
      await _db.delete(_savingsTable, id);
      savings.removeWhere((s) => s.id == id);
      transactions.removeWhere((t) => t.savingId == id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Transactions (credit / debit) ───────────────────────────────────────

  Future<bool> credit({
    required int savingId,
    required double amount,
    required String source,
    String? note,
  }) async {
    return _applyTransaction(
      savingId: savingId,
      amount: amount,
      source: source,
      type: 'credit',
      note: note,
    );
  }

  Future<bool> debit({
    required int savingId,
    required double amount,
    required String source,
    String? note,
  }) async {
    return _applyTransaction(
      savingId: savingId,
      amount: amount,
      source: source,
      type: 'debit',
      note: note,
    );
  }

  Future<bool> _applyTransaction({
    required int savingId,
    required double amount,
    required String source,
    required String type,
    String? note,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();

      // 1. Find saving
      final savingIdx = savings.indexWhere((s) => s.id == savingId);
      if (savingIdx == -1) return false;
      final saving = savings[savingIdx];

      // 2. Update balance
      final newBalance = type == 'credit'
          ? saving.balance + amount
          : saving.balance - amount;
      final updatedSaving = saving.copyWith(balance: newBalance);
      await _db.update(_savingsTable, updatedSaving.toMap(), savingId);
      savings[savingIdx] = updatedSaving;

      // 3. Record transaction
      final tx = SavingTransactionModel(
        savingId: savingId,
        type: type,
        amount: amount,
        source: source,
        note: note,
        createdAt: now,
      );
      final txId = await _db.insert(_txTable, tx.toMap());
      transactions.insert(0, tx.copyWith(id: txId));

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTransaction(int id) async {
    try {
      await _db.delete(_txTable, id);
      transactions.removeWhere((t) => t.id == id);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addToSaving({
    required double amount,
    required String source,
    String? selectedPerson,
  }) async {
    if (savings.isEmpty) {
      Get.snackbar('Error', 'No savings account found');
      return false;
    }

    if (source == 'Friend' && selectedPerson == null) {
      Get.snackbar('Error', 'Please select a friend');
      return false;
    }

    if (source == "Salary") {
      final dashCtrl = Get.find<DashboardController>();
      final available = dashCtrl.salaryLeft;
      if (available < amount) {
        Get.snackbar(
          'Error',
          'Insufficient balance in salary (${CurrencyHelper.format(available)})',
        );
        return false;
      }
    }

    // If source is Wallet, we need to debit the wallet
    if (source == 'Wallet') {
      final walletCtrl = Get.find<WalletController>();
      if (walletCtrl.wallets.isEmpty) {
        Get.snackbar('Error', 'No wallet found to transfer from');
        return false;
      }
      final mainWallet = walletCtrl.wallets.first;
      if (mainWallet.balance < amount) {
        Get.snackbar('Error', 'Insufficient balance in wallet');
        return false;
      }

      await walletCtrl.debit(
        walletId: mainWallet.id!,
        amount: amount,
        source: 'Transfer to Savings',
        note: 'Transferred to savings from wallet',
      );
    }

    final targetSavingId = savings.first.id!;

    // 1. Credit to saving
    await credit(
      savingId: targetSavingId,
      amount: amount,
      source: source == 'Friend' ? 'From Friend: $selectedPerson' : source,
      note: "Added from $source",
    );

    // 2. Record in Hisab if it's from a friend (Borrowing)
    if (source == 'Friend') {
      final hisabCtrl = Get.find<HisabController>();
      final personId = await hisabCtrl.getOrCreatePerson(selectedPerson!);
      await hisabCtrl.addHisab(
        HisabModel(
          personId: personId,
          personName: selectedPerson,
          type: 'borrowed',
          amount: amount,
          amountPaid: 0.0,
          remainingAmount: amount,
          status: 'pending',
          note: "Borrowed from friend for savings",
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
    }
    return true;
  }

  // ── Derived ─────────────────────────────────────────────────────────────

  double get totalSavings => savings.fold(0.0, (sum, s) => sum + s.balance);

  double get totalAddedFromSalary => transactions
      .where((t) => t.type == 'credit' && t.source == 'Salary')
      .fold(0.0, (sum, t) => sum + t.amount);

  List<SavingTransactionModel> transactionsForSaving(int savingId) =>
      transactions.where((t) => t.savingId == savingId).toList();
}
