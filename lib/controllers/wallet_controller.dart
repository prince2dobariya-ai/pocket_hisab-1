import 'package:get/get.dart';
import 'package:pocket_hisab/controllers/salary_controller.dart';
import 'package:pocket_hisab/controllers/saving_controller.dart';
import 'package:pocket_hisab/helpers/currency_helper.dart';
import 'package:pocket_hisab/models/wallet_model.dart';
import 'package:pocket_hisab/models/transaction_model.dart';
import 'package:pocket_hisab/controllers/dashboard_controller.dart';
import 'package:pocket_hisab/services/database_service.dart';

class WalletController extends GetxController {
  final _db = DatabaseService();
  static const _walletsTable = 'wallets';
  static const _txTable = 'wallet_transactions';

  final RxList<WalletModel> wallets = <WalletModel>[].obs;
  final RxList<TransactionModel> transactions = <TransactionModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    final walletRows = await _db.getAll(_walletsTable);

    if (walletRows.isEmpty) {
      // Create a default wallet if none exist
      final defaultWallet = WalletModel(
        walletName: "Main Wallet",
        balance: 0.0,
        createdAt: DateTime.now().toIso8601String(),
      );
      await addWallet(defaultWallet);
    } else {
      wallets.value = walletRows.map(WalletModel.fromMap).toList();
    }

    final txRows = await _db.getAll(_txTable);
    transactions.value = txRows.map(TransactionModel.fromMap).toList();
    isLoading.value = false;
  }

  // ── Wallets ─────────────────────────────────────────────────────────────

  Future<bool> addWallet(WalletModel wallet) async {
    try {
      final id = await _db.insert(_walletsTable, wallet.toMap());
      wallets.insert(0, wallet.copyWith(id: id));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteWallet(int id) async {
    try {
      await _db.delete(_walletsTable, id);
      wallets.removeWhere((w) => w.id == id);
      transactions.removeWhere((t) => t.walletId == id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Transactions (credit / debit) ───────────────────────────────────────

  /// Adds money to a wallet and records the transaction.
  Future<bool> credit({
    required int walletId,
    required double amount,
    required String source,
    String? note,
    String paymentType = 'Cash',
    String? createdAt,
  }) async {
    return _applyTransaction(
      walletId: walletId,
      amount: amount,
      source: source,
      type: 'credit',
      note: note,
      paymentType: paymentType,
      createdAt: createdAt,
    );
  }

  /// Deducts money from a wallet and records the transaction.
  Future<bool> debit({
    required int walletId,
    required double amount,
    required String source,
    String? note,
    String paymentType = 'Cash',
    String? createdAt,
  }) async {
    return _applyTransaction(
      walletId: walletId,
      amount: amount,
      source: source,
      type: 'debit',
      note: note,
      paymentType: paymentType,
      createdAt: createdAt,
    );
  }

  Future<bool> _applyTransaction({
    required int walletId,
    required double amount,
    required String source,
    required String type,
    String? note,
    required String paymentType,
    String? createdAt,
  }) async {
    try {
      final now = createdAt ?? DateTime.now().toIso8601String();

      // 1. Find wallet
      final walletIdx = wallets.indexWhere((w) => w.id == walletId);
      if (walletIdx == -1) return false;
      final wallet = wallets[walletIdx];

      if (type == 'credit' && source == 'Salary') {
        final dashCtrl = Get.find<DashboardController>();
        final available = dashCtrl.salaryLeft;

        if (amount > available) {
          Get.snackbar(
            'Error',
            'Amount exceeds available salary (${CurrencyHelper.format(available)})',
          );
          return false;
        }
      }

      if (type == 'credit' && source == 'Saving') {
        final savingCtrl = Get.find<SavingController>();
        if (savingCtrl.savings.isEmpty) {
          Get.snackbar('Error', 'No savings account found to transfer from');
          return false;
        }

        final mainSaving = savingCtrl.savings.first;
        if (mainSaving.balance < amount) {
          Get.snackbar('Error', 'Insufficient balance in savings');
          return false;
        }

        await savingCtrl.debit(
          savingId: mainSaving.id!,
          amount: amount,
          source: 'Transfer to Wallet',
          note: 'Transferred to wallet',
        );
      }

      if (type == 'debit') {
        final available = getBalanceByPaymentType(paymentType);
        if (amount > available) {
          Get.snackbar(
            'Error',
            'Insufficient $paymentType balance (${CurrencyHelper.format(available)})',
          );
          return false;
        }
      }

      // 2. Update balance
      final newBalance = type == 'credit'
          ? wallet.balance + amount
          : wallet.balance - amount;
      final updatedWallet = wallet.copyWith(balance: newBalance);
      await _db.update(_walletsTable, updatedWallet.toMap(), walletId);
      wallets[walletIdx] = updatedWallet;

      // 3. Record transaction
      final tx = TransactionModel(
        walletId: walletId,
        type: type,
        amount: amount,
        source: source,
        note: note,
        paymentType: paymentType,
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
      final tx = transactions.firstWhereOrNull((t) => t.id == id);
      if (tx == null) return false;

      // 1. Find wallet
      final walletIdx = wallets.indexWhere((w) => w.id == tx.walletId);
      if (walletIdx != -1) {
        final wallet = wallets[walletIdx];
        // 2. Revert balance
        final newBalance = tx.type == 'credit'
            ? wallet.balance - tx.amount
            : wallet.balance + tx.amount;
        final updatedWallet = wallet.copyWith(balance: newBalance);
        await _db.update(_walletsTable, updatedWallet.toMap(), tx.walletId);
        wallets[walletIdx] = updatedWallet;
      }

      // 3. Delete transaction record
      await _db.delete(_txTable, id);
      transactions.removeWhere((t) => t.id == id);
      return true;
    } catch (_) {
      return false;
    }
  }

  // ── Derived ─────────────────────────────────────────────────────────────

  double get totalBalance => wallets.fold(0.0, (sum, w) => sum + w.balance);

  double get totalAddedFromSalary => transactions
      .where((t) => t.type == 'credit' && t.source == 'Salary')
      .fold(0.0, (sum, t) => sum + t.amount);

  double getBalanceByPaymentType(String paymentType) {
    return transactions
        .where((t) => t.paymentType == paymentType)
        .fold(0.0, (s, t) => s + (t.type == 'credit' ? t.amount : -t.amount));
  }

  List<TransactionModel> transactionsForWallet(int walletId) =>
      transactions.where((t) => t.walletId == walletId).toList();
}
