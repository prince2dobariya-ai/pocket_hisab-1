import 'package:get/get.dart';
import 'package:pocket_hisab/models/wallet_model.dart';
import 'package:pocket_hisab/models/transaction_model.dart';
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
    wallets.value = walletRows.map(WalletModel.fromMap).toList();

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
  }) async {
    return _applyTransaction(
      walletId: walletId,
      amount: amount,
      source: source,
      type: 'credit',
      note: note,
    );
  }

  /// Deducts money from a wallet and records the transaction.
  Future<bool> debit({
    required int walletId,
    required double amount,
    required String source,
    String? note,
  }) async {
    return _applyTransaction(
      walletId: walletId,
      amount: amount,
      source: source,
      type: 'debit',
      note: note,
    );
  }

  Future<bool> _applyTransaction({
    required int walletId,
    required double amount,
    required String source,
    required String type,
    String? note,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();

      // 1. Find wallet
      final walletIdx = wallets.indexWhere((w) => w.id == walletId);
      if (walletIdx == -1) return false;
      final wallet = wallets[walletIdx];

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

  // ── Derived ─────────────────────────────────────────────────────────────

  double get totalBalance => wallets.fold(0.0, (sum, w) => sum + w.balance);

  double get totalAddedFromSalary => transactions
      .where((t) => t.type == 'credit' && t.source == 'Salary')
      .fold(0.0, (sum, t) => sum + t.amount);

  List<TransactionModel> transactionsForWallet(int walletId) =>
      transactions.where((t) => t.walletId == walletId).toList();
}
