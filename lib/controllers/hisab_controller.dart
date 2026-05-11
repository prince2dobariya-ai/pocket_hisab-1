import 'package:get/get.dart';
import 'package:pocket_hisab/models/hisab_model.dart';
import 'package:pocket_hisab/models/person_model.dart';
import 'package:pocket_hisab/services/database_service.dart';

class HisabController extends GetxController {
  final _db = DatabaseService();
  static const _tableTransactions = 'hisab_transactions';
  static const _tablePersons = 'persons';

  final RxList<HisabModel> hisabs = <HisabModel>[].obs;
  final RxList<PersonModel> persons = <PersonModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshData();
  }

  Future<void> refreshData() async {
    isLoading.value = true;
    await fetchPersons();
    await fetchTransactions();
    isLoading.value = false;
  }

  Future<void> fetchPersons() async {
    final rows = await _db.getAll(_tablePersons);
    persons.value = rows.map(PersonModel.fromMap).toList();
  }

  Future<void> fetchTransactions() async {
    // Join with persons table to get person_name
    final rows = await _db.rawQuery('''
      SELECT t.*, p.person_name 
      FROM $_tableTransactions t
      JOIN $_tablePersons p ON t.person_id = p.id
      ORDER BY t.id DESC
    ''');
    hisabs.value = rows.map(HisabModel.fromMap).toList();
  }

  Future<int> getOrCreatePerson(String name) async {
    final existing = persons.firstWhereOrNull(
      (p) => p.personName.toLowerCase() == name.toLowerCase(),
    );
    if (existing != null) return existing.id!;

    final newPerson = PersonModel(
      personName: name,
      createdAt: DateTime.now().toIso8601String(),
    );
    final id = await _db.insert(_tablePersons, newPerson.toMap());
    await fetchPersons();
    return id;
  }

  Future<bool> addHisab(HisabModel hisab) async {
    try {
      final id = await _db.insert(_tableTransactions, hisab.toMap());
      // Re-fetch to get joined data (personName)
      await fetchTransactions();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateHisab(HisabModel hisab) async {
    try {
      await _db.update(_tableTransactions, hisab.toMap(), hisab.id!);
      await fetchTransactions();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteHisab(int id) async {
    try {
      await _db.delete(_tableTransactions, id);
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
