import 'package:get/get.dart';
import 'package:pocket_hisab/models/hisab_model.dart';
import 'package:pocket_hisab/services/database_service.dart';

class HisabController extends GetxController {
  final _db = DatabaseService();
  static const _table = 'hisab_transactions';

  final RxList<HisabModel> hisabs = <HisabModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    isLoading.value = true;
    final rows = await _db.getAll(_table);
    hisabs.value = rows.map(HisabModel.fromMap).toList();
    isLoading.value = false;
  }

  Future<bool> addHisab(HisabModel hisab) async {
    try {
      final id = await _db.insert(_table, hisab.toMap());
      hisabs.insert(0, hisab.copyWith(id: id));
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateHisab(HisabModel hisab) async {
    try {
      await _db.update(_table, hisab.toMap(), hisab.id!);
      final idx = hisabs.indexWhere((h) => h.id == hisab.id);
      if (idx != -1) hisabs[idx] = hisab;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteHisab(int id) async {
    try {
      await _db.delete(_table, id);
      hisabs.removeWhere((h) => h.id == id);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Record a partial or full payment against a hisab entry.
  Future<bool> recordPayment(int hisabId, double paidNow) async {
    final idx = hisabs.indexWhere((h) => h.id == hisabId);
    if (idx == -1) return false;
    final h = hisabs[idx];

    final newPaid = h.amountPaid + paidNow;
    final newRemaining = h.amount - newPaid;
    final newStatus = newRemaining <= 0 ? 'settled' : 'pending';

    final updated = h.copyWith(
      amountPaid: newPaid.clamp(0, h.amount),
      remainingAmount: newRemaining.clamp(0, h.amount),
      status: newStatus,
    );
    return updateHisab(updated);
  }

  // ── Derived ─────────────────────────────────────────────────────────────

  /// Total I am owed (I gave money to friends, type = 'given')
  double get totalOwedToMe => hisabs
      .where((h) => h.type == 'given' && h.status == 'pending')
      .fold(0.0, (sum, h) => sum + h.remainingAmount);

  /// Total I owe (I borrowed money, type = 'borrowed')
  double get totalIOwe => hisabs
      .where((h) => h.type == 'borrowed' && h.status == 'pending')
      .fold(0.0, (sum, h) => sum + h.remainingAmount);

  List<HisabModel> get pendingHisabs =>
      hisabs.where((h) => h.status == 'pending').toList();

  List<HisabModel> get settledHisabs =>
      hisabs.where((h) => h.status == 'settled').toList();
}
