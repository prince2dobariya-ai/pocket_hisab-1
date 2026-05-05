import 'package:get/get.dart';
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
  Future<bool> payInstalment(int emiId) async {
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
    );
    return updateEmi(updated);
  }

  // ── Derived ─────────────────────────────────────────────────────────────

  List<EmiModel> get activeEmis =>
      emis.where((e) => e.status == 'active').toList();

  double get totalMonthlyEmi =>
      activeEmis.fold(0.0, (sum, e) => sum + e.monthlyAmount);

  double get totalRemainingAmount =>
      activeEmis.fold(0.0, (sum, e) => sum + e.remainingAmount);
}
